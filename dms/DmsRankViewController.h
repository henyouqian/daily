//
//  DmsRankViewController.h
//  daily
//
//  Created by Li Wei on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "dms.h"

@interface DmsRankViewController : UITableViewController{
@private
    std::vector<DmsRank> _ranks;
    std::vector<int> _sectionIdxs;  //first rank index per section
}

-(void)loadData;
-(void)onGetTimeLine:(const std::vector<DmsRank>&)ranks;
    
@end
