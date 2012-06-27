//
//  DmsRootViewController.h
//  daily
//
//  Created by Li Wei on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "dms.h"

@class DmsRankViewController;

@interface DmsRootViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
@private
    std::vector<DmsRank> _ranks;
    std::vector<int> _sectionIdxs;  //first rank index per section
    DmsRankViewController* _rankVC;
}

@property(nonatomic, retain) IBOutlet UITableView *tableview;
-(void)onGetTimeLineWithError:(int)error ranks:(const std::vector<DmsRank>&)ranks;
-(void)onGetTimeLineWithError2:(int)error ranks:(const std::vector<DmsRank>&)ranks;

@end
