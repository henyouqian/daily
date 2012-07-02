#include "dmsGameInfo.h"

const DmsGameInfo DMS_GAME_INFOS[] = {
    {11, "game11"},
    {10, "game10"},
    {5, "game5"},
};

const int DMS_GAME_NUM = sizeof(DMS_GAME_INFOS)/sizeof(DMS_GAME_INFOS[0]);

const DmsGameInfo* dmsGetGameInfo(int gameid){
    for ( int i = 0; i < DMS_GAME_NUM; ++i ){
        if ( DMS_GAME_INFOS[i].idx == gameid ){
            return DMS_GAME_INFOS + i;
        }
    }
    return NULL;
}

