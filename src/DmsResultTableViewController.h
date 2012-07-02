//
//  DmsResultTableViewController.h
//  daily
//
//  Created by Li Wei on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#include "dms.h"

@class DmsRankViewController;
@class DmsResultViewController;

@interface BottomCell : UITableViewCell {
@private
    UIActivityIndicatorView* _spinner;
}

+(void)startSpin;
+(void)stopSpin;
@end

@interface DmsResultTableViewController : PullRefreshTableViewController{
@private
    std::vector<DmsRank> _ranks;
    std::vector<int> _sectionIdxs;  //first rank index per section
    DmsRankViewController* _rankVC;
}
@property(nonatomic, assign) DmsResultViewController *parentVC;

-(void)onGetTimeLineWithError:(int)error ranks:(const std::vector<DmsRank>&)ranks;

@end
