//
//  RobotVC.h
//  daily
//
//  Created by Li Wei on 12-6-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dms.h"

@interface RobotVC : UIViewController

-(IBAction)close;
@property(nonatomic, retain) IBOutlet UITextView *tvOutput;

@end

void robotView();
void robotViewDestroy();

class RobotCallback : public DmsCallback{
public:
    RobotCallback();
    ~RobotCallback();
    void setTextView(UITextView* pTextView);
    void startRobot();
    void startNextRobot();
    virtual void onNetError();
    virtual void onError(const char* error);
    virtual void onLogin(int error, int userid, const char* gcid, const char* username, const char* datetime, int topRankId, int unread);
    virtual void onHeartBeat(int error, const char* datetime, int topRankId, int unread);
    virtual void onGetTodayGames(int error, const std::vector<DmsGame>& games);
    virtual void onStartGame(int error, int gameid);
    virtual void onSubmitScore(int error, int gameid, int score);
    virtual void onGetUnread(int error, int unread, int topid);
    virtual void onGetTimeline(int error, const std::vector<DmsRank>& ranks);
    
    
private:
    void addlog(const char* text);
    UITextView* _pTextView;
    NSMutableString* _str;
    int _robotIdx;
    int _gameIdx;
};

