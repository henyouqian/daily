#ifndef __DMS_H__
#define __DMS_H__

#define HEART_BEAT_SECOND 60

class DmsCallback;

void dmsInit(const char* appSecret);
void dmsDestroy();
void dmsAddListener(DmsCallback* pCallback);
void dmsRemoveListener(DmsCallback* pCallback);

void dmsTestLogin(const char* gcid, const char* username); //重大安全隐患
void dmsHeartBeat();
void dmsGetTodayGames();
void dmsStartGame(int gameid);
bool dmsSubmitScore(int gameid, int score);
void dmsGetUnread();
void dmsGetTimeline(int offset, int limit);

struct DmsRank{
    int idx;
    int userid;
    int gameid;
    int row;
    int rank;
    int score;
    int nationality;
    std::string date;
    std::string time;
    std::string username;
};

struct DmsGame{
    int gameid;
    int score;
    std::string time;
};

class DmsCallback{
public:
    virtual ~DmsCallback(){};
    virtual void onNetError(){};
    virtual void onError(const char* error) {};
    virtual void onLogin(int error, int userid, const char* gcid, const char* username, const char* datetime, int topRankId, int unread) {};
    virtual void onHeartBeat(int error, const char* datetime, int topRankId, int unread) {};
    virtual void onGetTodayGames(int error, const std::vector<DmsGame>& games) {};
    virtual void onStartGame(int error, int gameid) {};
    virtual void onSubmitScore(int error, int gameid, int score) {};
    virtual void onGetUnread(int error, int unread, int topid) {};
    virtual void onGetTimeline(int error, const std::vector<DmsRank>& ranks) {};
};


#endif //__DMS_H__