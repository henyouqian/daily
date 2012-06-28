//
//  RobotVC.m
//  daily
//
//  Created by Li Wei on 12-6-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RobotVC.h"
#include "taskYesOrNo.h"
#include "save.h"

namespace {
    const char* RBT_IDX = "rbt_idx";
    const char* RBT_DATE = "rbt_date";
    RobotVC* gRobotVC = nil;
    RobotCallback* gRobotCallback = NULL;
    const int GAME_IDS[] = {
        5, 10, 11
    };
    const int GAME_NUM = sizeof(GAME_IDS)/sizeof(GAME_IDS[0]);
}



void robotView(){
    lw::srand();
    UIView* parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    if ( !gRobotVC ){
        gRobotVC = [[RobotVC alloc] initWithNibName:@"RobotVC" bundle:nil];
    }
    if ( !gRobotCallback ){
        gRobotCallback = new RobotCallback();
    }
    dmsAddListener(gRobotCallback);
    
    [parentView addSubview:gRobotVC.view];
    
    int w = parentView.frame.size.width;
    int h = parentView.frame.size.height;
    gRobotVC.view.frame = CGRectMake(0, h, w, h);
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:gRobotVC];
    [UIView setAnimationDidStopSelector:@selector(didOpen)];
    gRobotVC.view.frame = CGRectMake(0, 0, w, h);
    [UIView commitAnimations];
}

void robotViewDestroy(){
    if ( gRobotVC ){
        [gRobotVC release];
        gRobotVC = nil;
    }
    dmsRemoveListener(gRobotCallback);
    if ( gRobotCallback ){
        delete gRobotCallback;
        gRobotCallback = NULL;
    }
}

@implementation RobotVC
@synthesize tvOutput;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)close{
    UIView* parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    int w = parentView.frame.size.width;
    int h = parentView.frame.size.height;
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.frame = CGRectMake(0, h, w, h);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didClose)];
    [UIView commitAnimations];
    dmsRemoveListener(gRobotCallback);
}

-(void)didClose{
    [self.view removeFromSuperview];
    robotViewDestroy();
    TaskYesOrNo::s().show(true);
}

-(void)didOpen{
    gRobotCallback->startRobot();
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    gRobotCallback->setTextView(self.tvOutput);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

RobotCallback::RobotCallback():_pTextView(NULL){
    _str = [[NSMutableString alloc] init];
}

RobotCallback::~RobotCallback(){
    [_str release];
}

void RobotCallback::setTextView(UITextView* pTextView){
    _pTextView = pTextView;
}

void RobotCallback::startRobot(){
    std::string ov;
    bool b = svGet(RBT_IDX, ov);
    if ( !b ){
        _robotIdx = 0;
        svSet(RBT_IDX, "0");
    }else{
        svValue(_robotIdx, ov);
    }
    std::stringstream ss;
    ss << "_r" << _robotIdx;
    dmsTestLogin(ss.str().c_str(), ss.str().c_str());
}

void RobotCallback::startNextRobot(){
    ++_robotIdx;
    svSet(RBT_IDX, svString(_robotIdx));
    startRobot();
}

void RobotCallback::onNetError(){
    addlog("Net error!");
}

void RobotCallback::onError(const char* error){
    if ( error ){
        std::stringstream ss;
        ss << "Error: " << error;
        addlog(ss.str().c_str());
    }
}
void RobotCallback::onLogin(int error, int userid, const char* gcid, const char* username, const char* datetime, int topRankId, int unread){
    if ( error ){
        addlog("Login error!");
        startNextRobot();
    }else{
        char serverDate[32];
        sscanf(datetime, "%s ", serverDate);
        
        std::string date;
        bool b = svGet(RBT_DATE, date);
        if ( !b ){
            date = serverDate;
            svSet(RBT_DATE, serverDate);
        }
        if ( date.compare(serverDate) != 0 ){
            svSet(RBT_IDX, "0");
            svSet(RBT_DATE, serverDate);
            startRobot();
            return;
        }
        addlog("----------------------");
        std::stringstream ss;
        ss << "Login OK: id=" << gcid;
        addlog(ss.str().c_str());
        dmsStartGame(GAME_IDS[0]);
        _gameIdx = 0;
    }
}
void RobotCallback::onHeartBeat(int error, const char* datetime, int topRankId, int unread){
    
}
void RobotCallback::onGetTodayGames(int error, const std::vector<DmsGame>& games){
    
}
void RobotCallback::onStartGame(int error, int gameid){
    if ( error ){
        addlog("Start game error!");
        startNextRobot();
    }else{
        int score = rand()%10000;
        dmsSubmitScore(gameid, score);
    }
}
void RobotCallback::onSubmitScore(int error, int gameid, int score){
    if ( error ){
        addlog("Submit score error!");
        startNextRobot();
    }else{
        ++_gameIdx;
        if ( _gameIdx == GAME_NUM ){
            startNextRobot();
        }else{
            dmsStartGame(GAME_IDS[_gameIdx]);
        }
        std::stringstream ss;
        ss << "Score submited: game=" << gameid << " score=" << score;
        addlog(ss.str().c_str());
    }
}
void RobotCallback::onGetUnread(int error, int unread, int topid){
    
}
void RobotCallback::onGetTimeline(int error, const std::vector<DmsRank>& ranks){
    
}

void RobotCallback::addlog(const char* text){
    NSString* str = [[NSString alloc] initWithFormat:@"+%s\n", text];
    [_str insertString:str atIndex:0];
    int len = _str.length;
    int limit = 2000;
    if ( len > limit ){
        NSRange r;
        r.location = limit;
        r.length = len -limit;
        [_str deleteCharactersInRange:r];
    }
    
    [str release];
    _pTextView.text = _str;
}