//
//  DmsRankViewController.h
//  daily
//
//  Created by Li Wei on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomCell : UITableViewCell {
@private
    UIActivityIndicatorView* _spinner;
}
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
-(void)startSpin;
-(void)stopSpin;
@end

struct DmsRank;
@interface DmsRankViewController : UITableViewController{
    std::vector<DmsRank> _ranks;
    int _gameid;
    std::string _date;
    bool _isLoading;
}

-(void)onGetRankError:(int)error ranks:(const std::vector<DmsRank>&)ranks;
- (void)setGameid:(int)gameid date:(const char* )date;
@end


