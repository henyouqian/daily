//
//  RobotVC.m
//  daily
//
//  Created by Li Wei on 12-6-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RobotVC.h"
#include "taskYesOrNo.h"

RobotVC* gRobotVC = nil;
RobotCallback* gRobotCallback = NULL;

void robotView(){
    UIView* parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    if ( !gRobotVC ){
        gRobotVC = [[RobotVC alloc] initWithNibName:@"RobotVC" bundle:nil];
    }
    if ( !gRobotCallback ){
        gRobotCallback = new RobotCallback;
    }
    dmsSetCallback(gRobotCallback);
    
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
    dmsSetCallback(NULL);
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
    dmsSetCallback(NULL);
}

-(void)didClose{
    [self.view removeFromSuperview];
    robotViewDestroy();
    TaskYesOrNo::s().show(true);
}

-(void)didOpen{
    dmsLogin("robot1", "robot1");
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

void RobotCallback::onNetError(){
    
}
void RobotCallback::onError(const char* error){
    
}
void RobotCallback::onLogin(int error, int userid, const char* gcid, const char* datetime, int topRankId, int unread){
    
}
void RobotCallback::onHeartBeat(int error, const char* datetime, int topRankId, int unread){
    
}
void RobotCallback::onGetTodayGames(int error, const std::vector<DmsGame>& games){
    
}
void RobotCallback::onStartGame(int error, int gameid){
    
}
void RobotCallback::onSubmitScore(int error, int gameid, int score){
    
}
void RobotCallback::onGetUnread(int error, int unread, int topid){
    
}
void RobotCallback::onGetTimeline(int error, const std::vector<DmsRank>& ranks){
    
}