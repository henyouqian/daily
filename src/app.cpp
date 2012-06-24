#include "stdafx.h"
#include "app.h"
#include "taskYesOrNo.h"
#include "option.h"
#include "weibo.h"
#include "store.h"
#include "adView.h"
#include "dms.h"

LWApp::LWApp(){
	_config.orientation = lw::App::ORIENTATION_UP;
	_config.maxFPS = 60;
	_config.title = L"Micro Vol1";

#ifdef WIN32
	lw::FileSys::addDirectory("data", true);
#endif

	int r = 0;
	r = sqlite3_open(_f("data.db"), &g_pDataDb);
	lwassert(r == SQLITE_OK);
#ifdef WIN32
	r = sqlite3_open(_f("save.sqlite"), &g_pSaveDb);
	lwassert(r == SQLITE_OK);
#endif
#ifdef __APPLE__
	std::string docDir = lw::getDocDir();
    docDir += "/save.sqlite";
	FILE* pf = fopen(docDir.c_str(), "rb");
	if ( pf == NULL ){
		pf = fopen(_f("save.sqlite"), "rb");
		lwassert(pf);
		fseek(pf, 0, SEEK_END);
		int len = ftell(pf);
		char buf[len];
		fseek(pf, 0, SEEK_SET);
		fread(buf, len, 1, pf);
		fclose(pf);
		FILE* pOut = fopen(docDir.c_str(), "wb");
		lwassert(pOut);
		fwrite(buf, len, 1, pOut);
		fclose(pOut);
	}

	r = sqlite3_open(docDir.c_str(), &g_pSaveDb);
	lwassert(r == SQLITE_OK);
#endif
	
}

LWApp::~LWApp(){
    
}

void LWApp::vInit(){
    new lw::SoundMgr(5);
    new TaskYesOrNo();
    dmsInit("6aa3b06bda37465ba506639d7035a763");
    //TaskNeverSeen::s().start(0);
    TaskYesOrNo::s().start(0);
    weiboInit();
    //storeInit();
    createAdmob();
    setFrameInterval(1);
}

void LWApp::vQuit(){
    delete TaskYesOrNo::ps();
    delete lw::SoundMgr::ps();
    weiboQuit();
    //storeQuit();
    deleteAdmob();
    sqlite3_close(g_pDataDb);
	sqlite3_close(g_pSaveDb);
    dmsDestroy();
}

void LWApp::vMain(){
	lw::SoundMgr::s().main(25);
}
