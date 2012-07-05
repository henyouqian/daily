#ifndef __DMS_LOCALDB_H__
#define __DMS_LOCALDB_H__

struct sqlite3;
struct DmsRank;

class DmsLocalDB : public lw::Singleton<DmsLocalDB>{
public:
    DmsLocalDB();
    ~DmsLocalDB();
    void login(const char* gcid, const char* username);
    void loginOk(const char* gcid, const char* username, int userid, int topResultId, int unread); 
    
    void setTopResultId(int topid);
    void setUnread(int unread);
    
    const char* getGcid();
    const char* getUserName();
    int getUserId();
    int getTopResultId();
    int getLocalTopResultId();
    int getUnread();
    
    void addRanks(const std::vector<DmsRank>& ranks);
    void getTimeline(std::vector<DmsRank>& ranks, int fromid, int limit);
    
    void getRanks(std::vector<DmsRank>& ranks, int gameid, const char* date, int offset, int limit);
    
    
private:
    bool setKVInt(const char* k, int v);
    bool setKVString(const char* k, const char* v);
    bool getKVInt(const char* k, int &v, int defaultV = 0);
    bool getKVString(const char* k, std::string& str, const char* defaultStr = "");
    const char* makeUserKey(const char* key);
    
    sqlite3* _db;
    int _topResultId;
    int _unread;
    int _userid;
    std::string _gcid;
    std::string _username;
};

#endif //__DMS_LOCALDB_H__