#include "dms.h"
#include "dmsError.h"
#include "cJSON.h"
#include "dmsLocalDB.h"
#include <time.h>
#import <GameKit/GameKit.h>
#include "dmsUI.h"

#define RANKS_PER_PAGE 10

void onLogin(int error, int userid, const char* gcid, const char* username, const char* datetime, int topResultId, int unread);
void onHeartBeat(int error, const char* datetime, int topResultId, int unread);
void onGetTodayGames(int error, const std::vector<DmsGame>& games);
void onStartGame(int error, const char* token, int gameid);
void onSubmitScore(int error, int gameid, int score);
void onGetTimeline(int error, const std::vector<DmsRank>& ranks);
void onGetRanks(int error, const std::vector<DmsRank>& ranks);

void dmsLogin(const char* gcid, const char* username);
void dmsRelogin();

@class DmsMain;

namespace {
    struct Data{
        Data():pHttpClient(NULL), isLogin(false){}
        std::string appSecret;
        bool isLogin;
        bool isOnline;
        lw::HTTPClient* pHttpClient;
        std::list<DmsCallback*> listeners;
        std::string gameStartToken;
        DmsMain* dmsMain;
        DmsLocalDB* pLocalDB;
        int tHeartBeat;
        int timeDiff;
    };
    
    Data* _pd = NULL;
    
    void netErrorCallback(){
        if ( _pd ){
            _pd->isOnline = false;
            std::list<DmsCallback*>::iterator it = _pd->listeners.begin();
            std::list<DmsCallback*>::iterator itend = _pd->listeners.end();
            for ( ; it != itend; ++it ){
                (*it)->onNetError();
            }
        }
    }
    void netOKCallback(){
        if ( _pd ){
            _pd->isOnline = true;
        }
    }
}

@interface DmsMain : NSObject {
@private
    
}
@end

@implementation DmsMain

- (id)init
{
    if ( self =[super init] ){
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAdvanced:) userInfo:nil repeats:YES];
        _pd->tHeartBeat = 0;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)timerAdvanced:(NSTimer *)timer{
    if ( _pd ){
        ++_pd->tHeartBeat;
        if ( _pd->tHeartBeat >= HEART_BEAT_SECOND ){
            _pd->tHeartBeat = 0;
            if ( _pd->isLogin ){
                dmsHeartBeat();
            }else{
                dmsRelogin();
            }
        }
    }
    
    //        //test
    //        time_t localT;
    //        time(&localT);
    //        time_t serverT = localT + _pd->timeDiff;
    //        tm* p = localtime(&serverT);
    //        lwinfo(p->tm_year+1900 <<","<< p->tm_mon+1 <<","<< p->tm_mday <<","<< p->tm_hour<<","<< p->tm_min<<","<< p->tm_sec);
}

@end

namespace {
    
    cJSON* parseMsg(const char* strMsg, int& error){
        error = DMSERR_NONE;
        cJSON *json=cJSON_Parse(strMsg);
        if ( !json ){
            error = DMSERR_JSON;
        }else{
            cJSON *jerror = cJSON_GetObjectItem(json, "error");
            if ( jerror && jerror->valueint){
                error = jerror->valueint;
            }
        }
        return json;
    }
    int getJsonInt(cJSON* json, const char* key, int& error){
        if ( error != DMSERR_NONE ){
            return 0;
        }
        cJSON* jint=cJSON_GetObjectItem(json, key);
        if ( !jint ){
            error = DMSERR_JSON;
        }else{
            if ( jint->type == cJSON_Number ){
                return jint->valueint;
            }else{
                error = DMSERR_JSON;
            }
        }
        return 0;
    }
    bool getJsonBool(cJSON* json, const char* key, int& error){
        if ( error != DMSERR_NONE ){
            return false;
        }
        cJSON* jitem=cJSON_GetObjectItem(json, key);
        if ( !jitem ){
            error = DMSERR_JSON;
        }else{
            if ( jitem->type == cJSON_False ){
                return false;
            }else if ( jitem->type == cJSON_True ){
                return true;
            }else{
                error = DMSERR_JSON;
            }
        }
        return false;
    }
    const char* _getJsonString(cJSON* json, const char* key, int& error){
        if ( error != DMSERR_NONE ){
            return NULL;
        }
        cJSON* jobj=cJSON_GetObjectItem(json, key);
        if ( !jobj ){
            error = DMSERR_JSON;
        }else{
            if ( jobj->type == cJSON_String ){
                return jobj->valuestring;
            }else{
                error = DMSERR_JSON;
            }
        }
        return NULL;
    }
    
    bool getJsonString(std::string& strout, cJSON* json, const char* key, int& error){
        const char* c = _getJsonString(json, key, error);
        if ( c ){
            strout = c;
            return true;
        }
        return false;
    }
    
    cJSON* getJsonArray(cJSON* json, const char* key, int& error){
        if ( error != DMSERR_NONE ){
            return NULL;
        }
        cJSON* jobj=cJSON_GetObjectItem(json, key);
        if ( !jobj ){
            error = DMSERR_JSON;
        }else{
            if ( jobj->type == cJSON_Array ){
                return jobj;
            }else{
                error = DMSERR_JSON;
            }
        }
        return NULL;
    }
    
    void errorDefaultProc(int error){
        if ( error == DMSERR_LOGIN ){
            _pd->isLogin = false;
            dmsRelogin();
        }
    }
    
    class MsgLogin : public lw::HTTPMsg{
    public:
        MsgLogin(const char* gcid, const char* username)
        :lw::HTTPMsg("/dmsapi/user/login", _pd->pHttpClient, true){
            std::stringstream ss;
            ss << "?gcid=" << gcid << "&appsecretkey=" << _pd->appSecret << "&username=" << username;
            addParam(ss.str().c_str());
            _gcid = gcid;
            _username = username;
        }
        virtual void onRespond(int error){
            int userid = 0;
            std::string datetime;
            int topid = 0;
            int unread = 0;
            
            if ( error == LWHTTPERR_NONE ){
                error = DMSERR_NONE;
                cJSON *json=parseMsg(_buff.c_str(), error);
                if ( error == DMSERR_NONE ){
                    userid = getJsonInt(json, "userid", error);
                    getJsonString(datetime, json, "datetime", error);
                    topid = getJsonInt(json, "topid", error);
                    unread = getJsonInt(json, "unread", error);
                }
                if ( error == DMSERR_NONE ){
                    _pd->isLogin = true;
                    _pd->tHeartBeat = 0;
                }
                
                cJSON_Delete(json);
            }
            onLogin(error, userid, _gcid.c_str(), _username.c_str(), datetime.c_str(), topid, unread);
        }
    private:
        std::string _gcid;
        std::string _username;
    };
    
    class MsgHeartBeat : public lw::HTTPMsg{
    public:
        MsgHeartBeat()
        :lw::HTTPMsg("/dmsapi/user/heartbeat", _pd->pHttpClient, false){
        }
        virtual void onRespond(int error){
            std::string datetime;
            int topid = 0;
            int unread = 0;
            
            if ( error == LWHTTPERR_NONE ){
                error = DMSERR_NONE;
            
                cJSON *json=parseMsg(_buff.c_str(), error);
                if ( error == DMSERR_NONE ){
                    getJsonString(datetime, json, "datetime", error);
                    topid = getJsonInt(json, "topid", error);
                    unread = getJsonInt(json, "unread", error);
                }
                if ( error == DMSERR_NONE ){
                    _pd->isLogin = true;
                    _pd->tHeartBeat = 0;
                }
                errorDefaultProc(error);
                cJSON_Delete(json);
            }
            onHeartBeat(error, datetime.c_str(), topid, unread);
        }
    };
    
    class MsgGetTodayGames : public lw::HTTPMsg{
    public:
        MsgGetTodayGames()
        :lw::HTTPMsg("/dmsapi/user/gettodaygames", _pd->pHttpClient, false){
            
        }
        virtual void onRespond(int error){
            std::vector<DmsGame> games;
            if ( error == LWHTTPERR_NONE ){
                error = DMSERR_NONE;
                cJSON *json=parseMsg(_buff.c_str(), error);
                cJSON *jgames = NULL;
                if ( error == DMSERR_NONE ){
                    jgames = getJsonArray(json, "games", error);
                }

                if ( error == DMSERR_NONE ){
                    int sz = cJSON_GetArraySize(jgames);
                    for ( int i = 0; i < sz; ++i ){
                        DmsGame game;
                        cJSON* jitem = cJSON_GetArrayItem(jgames,i);
                        game.gameid = getJsonInt(jitem, "gameid", error);
                        if ( error == DMSERR_NONE ){
                            game.score = getJsonInt(jitem, "score", error);
                        }
                        if ( error == DMSERR_NONE ){
                            getJsonString(game.time, jitem, "time", error);
                        }
                        if ( error == DMSERR_NONE ){
                            games.push_back(game);
                        }
                    }
                }
                errorDefaultProc(error);
                cJSON_Delete(json);
            }
            onGetTodayGames(error, games);
        }
    };
    
    class MsgStartGame : public lw::HTTPMsg{
    public:
        MsgStartGame(int gameid)
        :lw::HTTPMsg("/dmsapi/user/startgame", _pd->pHttpClient, false), _gameID(gameid){
            std::stringstream ss;
            ss << "?gameid=" << gameid;
            addParam(ss.str().c_str());
        }
        virtual void onRespond(int error){
            if ( error == LWHTTPERR_NONE ){
                error = DMSERR_NONE;
                cJSON *json=parseMsg(_buff.c_str(), error);
                if ( error == DMSERR_NONE ){
                    getJsonString(_pd->gameStartToken, json, "token", error);
                }
                errorDefaultProc(error);
                cJSON_Delete(json);
            }
            onStartGame(error, _pd->gameStartToken.c_str(), _gameID);
        }
    private:
        int _gameID;
    };
    
    class MsgSubmitScore : public lw::HTTPMsg{
    public:
        MsgSubmitScore(int gameid, int score)
        :lw::HTTPMsg("/dmsapi/user/submitscore", _pd->pHttpClient, false){
            std::stringstream ss;
            ss << "?token=" << _pd->gameStartToken << "&gameid=" << gameid << "&score=" << score;
            addParam(ss.str().c_str());
        }
        virtual void onRespond(int error){
            _pd->gameStartToken.clear();
            int gameid = -1;
            int score = 0;
            if ( error == LWHTTPERR_NONE ){
                error = DMSERR_NONE;
                cJSON *json=parseMsg(_buff.c_str(), error);
                if ( error == DMSERR_NONE ){
                    gameid = getJsonInt(json, "gameid", error);
                    score = getJsonInt(json, "score", error);
                }
                errorDefaultProc(error);
                cJSON_Delete(json);
            }
            onSubmitScore(error, gameid, score);
        }
    };
    
    class MsgGetTimeline : public lw::HTTPMsg{
    public:
        MsgGetTimeline(int topid, int limit)
        :lw::HTTPMsg("/dmsapi/user/gettimeline", _pd->pHttpClient, false){
            std::stringstream ss;
            ss << "?topid=" << topid << "&limit=" << limit;
            addParam(ss.str().c_str());
        }
        virtual void onRespond(int error){
            std::vector<DmsRank> ranks;
            if ( error == LWHTTPERR_NONE ){
                error = DMSERR_NONE;
                cJSON *json=parseMsg(_buff.c_str(), error);
                if ( error == DMSERR_NONE ){
                    cJSON *jRanks = getJsonArray(json, "ranks", error);
                    if ( jRanks && error == DMSERR_NONE ){
                        int sz = cJSON_GetArraySize(jRanks);
                        for ( int i = 0; i < sz; ++i ){
                            cJSON* jRank = cJSON_GetArrayItem(jRanks, i);
                            DmsRank rank;
                            rank.idx = getJsonInt(jRank, "idx", error);
                            rank.userid = getJsonInt(jRank, "userid", error);
                            rank.gameid = getJsonInt(jRank, "gameid", error);
                            rank.row = getJsonInt(jRank, "row", error);
                            rank.rank = getJsonInt(jRank, "rank", error);
                            rank.score = getJsonInt(jRank, "score", error);
                            rank.nationality = getJsonInt(jRank, "nationality", error);
                            getJsonString(rank.date, jRank, "date", error);
                            getJsonString(rank.time, jRank, "time", error);
                            getJsonString(rank.username, jRank, "username", error);
                            if ( error == DMSERR_NONE ){
                                ranks.push_back(rank);
                            }
                        }
                    }
                }
                errorDefaultProc(error);
                cJSON_Delete(json);
            }
            onGetTimeline(error, ranks);
        }
    };
    
    class MsgGetRanks : public lw::HTTPMsg{
    public:
        MsgGetRanks(int gameid, const char* date, int offset, int limit)
        :lw::HTTPMsg("/dmsapi/user/getranks", _pd->pHttpClient, false){
            std::stringstream ss;
            ss << "?gameid=" << gameid << "&date=" << date << "&offset=" << offset << "&limit=" << limit;
            addParam(ss.str().c_str());
        }
        virtual void onRespond(int error){
            std::vector<DmsRank> ranks;
            if ( error == LWHTTPERR_NONE ){
                error = DMSERR_NONE;
                cJSON *json=parseMsg(_buff.c_str(), error);
                if ( error == DMSERR_NONE ){
                    cJSON *jRanks = getJsonArray(json, "ranks", error);
                    if ( jRanks && error == DMSERR_NONE ){
                        int sz = cJSON_GetArraySize(jRanks);
                        for ( int i = 0; i < sz; ++i ){
                            cJSON* jRank = cJSON_GetArrayItem(jRanks, i);
                            DmsRank rank;
                            rank.idx = getJsonInt(jRank, "idx", error);
                            rank.userid = getJsonInt(jRank, "userid", error);
                            rank.gameid = getJsonInt(jRank, "gameid", error);
                            rank.row = getJsonInt(jRank, "row", error);
                            rank.rank = getJsonInt(jRank, "rank", error);
                            rank.score = getJsonInt(jRank, "score", error);
                            rank.nationality = getJsonInt(jRank, "nationality", error);
                            getJsonString(rank.date, jRank, "date", error);
                            getJsonString(rank.time, jRank, "time", error);
                            getJsonString(rank.username, jRank, "username", error);
                            if ( error == DMSERR_NONE ){
                                ranks.push_back(rank);
                            }
                        }
                    }
                }
                errorDefaultProc(error);
                cJSON_Delete(json);
            }
            onGetRanks(error, ranks);
        }
    };
    
}//namespace



void dmsInit(const char* appSecret){
    lwassert(_pd==NULL && appSecret);
    _pd = new Data;
    _pd->appSecret = appSecret;
    _pd->isLogin = false;
    _pd->isOnline = false;
    _pd->pHttpClient = new lw::HTTPClient("192.168.1.8:8000");
    _pd->pHttpClient->enableHTTPS(false);
    _pd->dmsMain = [[DmsMain alloc] init];
    _pd->pLocalDB = new DmsLocalDB();
    _pd->timeDiff = 0;
    
    lw::setHTTPErrorCallback(netErrorCallback);
    lw::setHTTPOKCallback(netOKCallback);
    
//    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
//    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
//        if (localPlayer.isAuthenticated)
//        {
//            dmsLogin([localPlayer.playerID UTF8String], [localPlayer.alias UTF8String]);
//        }
//    }];
    
    //test
    dmsTestLogin("_r5", "_r5");
}

void dmsDestroy(){
    lwassert(_pd);
    dmsUIDestroy();
    delete _pd->pHttpClient;
    [_pd->dmsMain release];
    delete _pd->pLocalDB;
    delete _pd;
    _pd = NULL;
}

void dmsAddListener(DmsCallback* pCallback){
    lwassert(_pd);
    _pd->listeners.remove(pCallback);
    _pd->listeners.push_back(pCallback);
    
}

void dmsRemoveListener(DmsCallback* pCallback){
    lwassert(_pd);
    _pd->listeners.remove(pCallback);
}

void dmsLogin(const char* gcid, const char* username){
    lwassert(_pd);
    //todo
}

void dmsRelogin(){
    _pd->gameStartToken.clear();
    const char* gcid = _pd->pLocalDB->getGcid();
    const char* username = _pd->pLocalDB->getUserName();
    if ( gcid && username && strlen(gcid) != 0 ){
        lw::HTTPMsg* pMsg = new MsgLogin(gcid, username);
        pMsg->send();
    }else{
        lwerror("relogin");
    }
}

void dmsTestLogin(const char* gcid, const char* username){
    lwassert(_pd && gcid && username);
    
    if ( strcmp(_pd->pLocalDB->getGcid(), gcid) != 0 ){
        _pd->gameStartToken.clear();
        _pd->isLogin = false;
    }
    lw::HTTPMsg* pMsg = new MsgLogin(gcid, username);
    pMsg->send();
}

void dmsHeartBeat(){
    lwassert(_pd);
    lw::HTTPMsg* pMsg = new MsgHeartBeat();
    pMsg->send();
}

void dmsGetTodayGames(){
    lwassert(_pd);
    lw::HTTPMsg* pMsg = new MsgGetTodayGames();
    pMsg->send();
}

void dmsStartGame(int gameid){
    lwassert(_pd);
    _pd->gameStartToken.clear();
    lw::HTTPMsg* pMsg = new MsgStartGame(gameid);
    pMsg->send();
}

bool dmsSubmitScore(int gameid, int score){
    lwassert(_pd);
    if ( _pd->gameStartToken.empty() ){
        lwerror("dmsStartGame first");
        std::list<DmsCallback*>::iterator it = _pd->listeners.begin();
        std::list<DmsCallback*>::iterator itend = _pd->listeners.end();
        for ( ; it != itend; ++it ){
            (*it)->onError("dmsStartGame first");
        }
        return false;
    }
    lw::HTTPMsg* pMsg = new MsgSubmitScore(gameid, score);
    pMsg->send();
    return true;
}

void dmsGetTimeline(int fromid, int limit){
    std::vector<DmsRank> ranks;
    if ( fromid < 0 || limit <=0 ){
        lwerror("offset < 0 || limit <=0");
        onGetTimeline(DMSERR_PARAM, ranks);
        return;
    }
    limit = std::min(fromid, limit);
    if ( limit <=0 ){
        onGetTimeline(DMSERR_NONE, ranks);
        return;
    }
    _pd->pLocalDB->getTimeline(ranks, fromid, limit);
    if ( ranks.size() == limit ){
        onGetTimeline(DMSERR_NONE, ranks);
    }else{
        lw::HTTPMsg* pMsg = new MsgGetTimeline(fromid, limit);
        pMsg->send();
    }
}

void dmsGetRanks(int gameid, const char* date, int offset, int limit){
    std::vector<DmsRank> ranks;
    if ( offset < 0 || limit <=0 ){
        lwerror("offset < 0 || limit <=0");
        onGetRanks(DMSERR_PARAM, ranks);
        return;
    }
    _pd->pLocalDB->getRanks(ranks, gameid, date, offset, limit);
    if ( ranks.size() == limit ){
        onGetRanks(DMSERR_NONE, ranks);
    }else{
        lw::HTTPMsg* pMsg = new MsgGetRanks(gameid, date, offset, limit);
        pMsg->send();
    }
}

void onLogin(int error, int userid, const char* gcid, const char* username, const char* datetime, int topResultId, int unread){
    if ( error ){
        lwerror(getDmsErrorString(error));
    }else{
        _pd->pLocalDB->loginOk(gcid, username, userid, topResultId, unread);
    }
    std::list<DmsCallback*>::iterator it = _pd->listeners.begin();
    std::list<DmsCallback*>::iterator itend = _pd->listeners.end();
    for ( ; it != itend; ++it ){
        (*it)->onLogin(error, userid, gcid, username, datetime, topResultId, unread);
    }
}

void onHeartBeat(int error, const char* datetime, int topResultId, int unread){
    if ( error ){
        lwerror(getDmsErrorString(error));
    }else{
        int oldTopResultId = _pd->pLocalDB->getTopResultId();
        _pd->pLocalDB->setTopResultId(topResultId);
        _pd->pLocalDB->setUnread(unread);
        if ( topResultId != oldTopResultId ){
            int limit = std::min(RANKS_PER_PAGE, topResultId-_pd->pLocalDB->getLocalTopResultId());
            dmsGetTimeline(topResultId, limit);
        }
        int year, month, day, hour, minute, second;
        sscanf(datetime, "%d-%d-%d %d:%d:%d.", &year, &month, &day, &hour, &minute, &second);
        tm t;
        t.tm_year = year-1900;
        t.tm_mon = month-1;
        t.tm_mday = day;
        t.tm_hour = hour;
        t.tm_min = minute;
        t.tm_sec = second;
        t.tm_isdst = false;
        time_t serverT = mktime(&t);
        time_t localT;
        time(&localT);
        _pd->timeDiff = serverT - localT;
    }
    
    std::list<DmsCallback*>::iterator it = _pd->listeners.begin();
    std::list<DmsCallback*>::iterator itend = _pd->listeners.end();
    for ( ; it != itend; ++it ){
        (*it)->onHeartBeat(error, datetime, topResultId, unread);
    }
}

void onGetTodayGames(int error, const std::vector<DmsGame>& games){
    if ( error ){
        lwerror(getDmsErrorString(error));
    }
    std::list<DmsCallback*>::iterator it = _pd->listeners.begin();
    std::list<DmsCallback*>::iterator itend = _pd->listeners.end();
    for ( ; it != itend; ++it ){
        (*it)->onGetTodayGames(error, games);
    }
}

void onStartGame(int error, const char* token, int gameid){
    if ( error ){
        lwerror(getDmsErrorString(error));
    }
    std::list<DmsCallback*>::iterator it = _pd->listeners.begin();
    std::list<DmsCallback*>::iterator itend = _pd->listeners.end();
    for ( ; it != itend; ++it ){
        (*it)->onStartGame(error, gameid);
    }
}

void onSubmitScore(int error, int gameid, int score){
    if ( error ){
        lwerror(getDmsErrorString(error));
    }
    std::list<DmsCallback*>::iterator it = _pd->listeners.begin();
    std::list<DmsCallback*>::iterator itend = _pd->listeners.end();
    for ( ; it != itend; ++it ){
        (*it)->onSubmitScore(error, gameid, score);
    }
}

void onGetTimeline(int error, const std::vector<DmsRank>& ranks){
    if ( error ){
        lwerror(getDmsErrorString(error));
    }else{
        _pd->pLocalDB->addRanks(ranks);
    }
    dmsUIOnGetTimeline(error, ranks);
    std::list<DmsCallback*>::iterator it = _pd->listeners.begin();
    std::list<DmsCallback*>::iterator itend = _pd->listeners.end();
    for ( ; it != itend; ++it ){
        (*it)->onGetTimeline(error, ranks);
    }
}

void onGetRanks(int error, const std::vector<DmsRank>& ranks){
    if ( error ){
        lwerror(getDmsErrorString(error));
    }else{
        _pd->pLocalDB->addRanks(ranks);
    }
    dmsUIOnGetRanks(error, ranks);
    std::list<DmsCallback*>::iterator it = _pd->listeners.begin();
    std::list<DmsCallback*>::iterator itend = _pd->listeners.end();
    for ( ; it != itend; ++it ){
        (*it)->onGetRanks(error, ranks);
    }
}