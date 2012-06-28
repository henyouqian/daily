//
//  DmsResultViewController.h
//  daily
//
//  Created by Li Wei on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DmsResultTableViewController;
@interface DmsResultViewController : UIViewController{
    DmsResultTableViewController* _tableVC;
}

@property(nonatomic, readonly) DmsResultTableViewController *tableVC;

@end
