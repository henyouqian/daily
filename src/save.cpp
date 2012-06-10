#include "stdafx.h"
#include "save.h"

bool svGet(const char* key, std::string& outValue){
    outValue = "";
    sqlite3_stmt* pStmt = NULL;
    std::stringstream ss;
    ss << "SELECT value FROM KVDatas WHERE key='" << key << "';";
    int r = sqlite3_prepare_v2(g_pSaveDb, ss.str().c_str(), -1, &pStmt, NULL);
    lwassert(r == SQLITE_OK);
    bool b = false;
    while ( 1 ){
        r = sqlite3_step(pStmt);
        if ( r == SQLITE_ROW ){
            outValue = (const char*)sqlite3_column_text(pStmt, 0);
            b = true;
            break;
        }else if ( r == SQLITE_DONE ){
            break;
        }else{
            break;
        }
    }
    sqlite3_finalize(pStmt);
    return b;
}

bool svSet(const char* key, const char* value){
    lwassert(key && value);
    std::stringstream ss;
    ss << "REPLACE INTO KVDatas (key, value) values('" << key << "', '" << value << "');";
    int r = sqlite3_exec(g_pSaveDb, ss.str().c_str(), NULL, NULL, NULL);
	if ( r != SQLITE_OK ){
        lwerror(r);
        return false;
    }
    return true;
}