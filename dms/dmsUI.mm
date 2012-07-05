#include "dmsUI.h"
#include "dms.h"
#import "DmsResultViewController.h"
#import "DmsResultTableViewController.h"
#import "DmsRankViewController.h"

@interface Dele : NSObject<UINavigationControllerDelegate> {
@private
    
}

@end

namespace {
    UINavigationController* gRootNavCtrler = nil;
    DmsResultViewController* gResultVC = nil;
    FnDmsUICallback g_fnDmsUIWillAppear = NULL;
    FnDmsUICallback g_fnDmsUIDidAppear = NULL;
    FnDmsUICallback g_fnDmsUIWillDisappear = NULL;
    FnDmsUICallback g_fnDmsUIDidDisappear = NULL;
    Dele* gDele = nil;
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

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
    [viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController 
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
    [viewController viewDidAppear:animated];
}

@end



void dmsUI(){
    UIView* parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    if ( !gRootNavCtrler ){
        gResultVC = [[DmsResultViewController alloc] initWithNibName:@"DmsResultViewController" bundle:nil];
        gRootNavCtrler = [[UINavigationController alloc] initWithRootViewController:gResultVC];
        gDele = [[Dele alloc] init];
        [gRootNavCtrler setDelegate:gDele];
    }
    
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
        [gResultVC release];
        gResultVC = nil;
        [gRootNavCtrler release];
        gRootNavCtrler = nil;
        [gDele release];
        gDele = nil;
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

void dmsUIOnGetTimeline(int error, const std::vector<DmsRank>& ranks){
    [gResultVC.tableVC onGetTimeLineWithError:error ranks:ranks];
}

void dmsUIOnGetRanks(int error, const std::vector<DmsRank>& ranks){
    [gResultVC.tableVC.rankVC onGetRankError:error ranks:ranks];
}
