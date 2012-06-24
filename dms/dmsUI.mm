#include "dmsUI.h"
//#include "DmsMyRankViewController.h"
//#include "DmsCountryRankViewController.h"
#include "DmsRankViewController.h"

//UITabBarController* gTabBarController = nil;


@interface Dele : NSObject {
@private
    
}

@end

class DmsUICallback : public DmsCallback{
public:
    DmsUICallback();
    ~DmsUICallback();
    virtual void onNetError();
    virtual void onError(const char* error);
    virtual void onLogin(int error, int userid, const char* gcid, const char* username, const char* datetime, int topRankId, int unread);
    virtual void onHeartBeat(int error, const char* datetime, int topRankId, int unread);
    virtual void onGetTodayGames(int error, const std::vector<DmsGame>& games);
    virtual void onStartGame(int error, int gameid);
    virtual void onSubmitScore(int error, int gameid, int score);
    virtual void onGetUnread(int error, int unread, int topid);
    virtual void onGetTimeline(int error, const std::vector<DmsRank>& ranks);
};

namespace {
    UINavigationController* gRootNavCtrler = nil;
    DmsRankViewController* gRankVC = nil;
    FnDmsUICallback g_fnDmsUIWillAppear = NULL;
    FnDmsUICallback g_fnDmsUIDidAppear = NULL;
    FnDmsUICallback g_fnDmsUIWillDisappear = NULL;
    FnDmsUICallback g_fnDmsUIDidDisappear = NULL;
    Dele* gDele = nil;
    DmsUICallback* gDmsUICallback = nil;
}

@implementation Dele

-(void)onDidappear{
    if ( g_fnDmsUIDidAppear ){
        g_fnDmsUIDidAppear();
    }
    [UIView setAnimationDelegate:nil];
}

-(void)onDidDisappear{
    if ( g_fnDmsUIDidDisappear ){
        g_fnDmsUIDidDisappear();
    }
    dmsUIDestroy();
}

@end

void dmsUI(){
    UIView* parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    if ( !gRootNavCtrler ){
        gDmsUICallback = new DmsUICallback();
        dmsAddListener(gDmsUICallback);
        gRankVC = [[DmsRankViewController alloc] init];
        [gRankVC loadData];
        gRootNavCtrler = [[UINavigationController alloc] initWithRootViewController:gRankVC];
        gDele = [[Dele alloc] init];
    }

//    if ( !gTabBarController ){
//        if ( !gDele ){
//            gDele = [[Dele alloc] init];
//        }
//        gTabBarController = [[UITabBarController alloc] init];
//        
//        DmsMyRankViewController* myVC = [[DmsMyRankViewController alloc] init];
//        UINavigationController *myNavigation = [[UINavigationController alloc] initWithRootViewController:myVC];
//        UITabBarItem *tabBarItem = [myNavigation tabBarItem];
//        tabBarItem.title = @"Me";
//        
//        DmsCountryRankViewController* countryVC = [[DmsCountryRankViewController alloc] init];
//        UINavigationController *countryNavigation = [[UINavigationController alloc] initWithRootViewController:countryVC];
//        tabBarItem = [countryNavigation tabBarItem];
//        tabBarItem.title = @"Country";
//        
//        NSArray *viewControllerArray = [[NSArray alloc] initWithObjects:myNavigation,countryNavigation,nil];
//        gTabBarController.viewControllers = viewControllerArray;
//        
//        [viewControllerArray release];
//        [myVC release];
//        [countryVC release];
//        [myNavigation release];
//        [countryNavigation release];
//    }
    
    [parentView addSubview:gRootNavCtrler.view];
    
    int w = parentView.frame.size.width;
    int h = parentView.frame.size.height;
    gRootNavCtrler.view.frame = CGRectMake(0, h, w, h);
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    gRootNavCtrler.view.frame = CGRectMake(0, 0, w, h);
    [UIView setAnimationDelegate:gDele];
    [UIView setAnimationDidStopSelector:@selector(onDidappear)];
    [UIView commitAnimations];
    
    if ( g_fnDmsUIWillAppear ){
        g_fnDmsUIWillAppear();
    }
}

void dmsUIClose(){
    UIView* parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    int w = parentView.frame.size.width;
    int h = parentView.frame.size.height;
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    gRootNavCtrler.view.frame = CGRectMake(0, h, w, h);
    [UIView setAnimationDelegate:gDele];
    [UIView setAnimationDidStopSelector:@selector(onDidDisappear)];
    [UIView commitAnimations];
    
    if ( g_fnDmsUIWillDisappear ){
        g_fnDmsUIWillDisappear();
    }
}

void dmsUIDestroy(){
    if ( gRootNavCtrler ){
        [UIView setAnimationDelegate:nil];
        [gRankVC release];
        gRankVC = nil;
        [gRootNavCtrler release];
        gRootNavCtrler = nil;
        [gDele release];
        gDele = nil;
        dmsRemoveListener(gDmsUICallback);
        delete gDmsUICallback;
        gDmsUICallback = NULL;
    }
}

void setDmsUIWillAppear(FnDmsUICallback fn){
    g_fnDmsUIWillAppear = fn;
}
void setDmsUIDidAppear(FnDmsUICallback fn){
    g_fnDmsUIDidAppear = fn;
}
void setDmsUIWillDisappear(FnDmsUICallback fn){
    g_fnDmsUIWillDisappear = fn;
}
void setDmsUIDidDisappear(FnDmsUICallback fn){
    g_fnDmsUIDidDisappear = fn;
}

DmsUICallback::DmsUICallback(){
    
}
DmsUICallback::~DmsUICallback(){
    
}

void DmsUICallback::onNetError(){
    
}
void DmsUICallback::onError(const char* error){
    
}
void DmsUICallback::onLogin(int error, int userid, const char* gcid, const char* username, const char* datetime, int topRankId, int unread){
    
}
void DmsUICallback::onHeartBeat(int error, const char* datetime, int topRankId, int unread){
    
}
void DmsUICallback::onGetTodayGames(int error, const std::vector<DmsGame>& games){
    
}
void DmsUICallback::onStartGame(int error, int gameid){
    
}
void DmsUICallback::onSubmitScore(int error, int gameid, int score){
    
}
void DmsUICallback::onGetUnread(int error, int unread, int topid){
    
}
void DmsUICallback::onGetTimeline(int error, const std::vector<DmsRank>& ranks){
    [gRankVC onGetTimeLine:ranks];
}
