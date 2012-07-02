#ifndef __DMS_GAMEINFO_H__
#define __DMS_GAMEINFO_H__

struct DmsGameInfo{
    int idx;
    const char* name;
};

const DmsGameInfo* dmsGetGameInfo(int gameid);


#endif //__DMS_H__