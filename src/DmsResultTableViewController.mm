//
//  DmsResultTableViewController.m
//  daily
//
//  Created by Li Wei on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DmsResultTableViewController.h"
#import "DmsResultViewController.h"
#import "DmsRankViewController.h"
#include "dmsUI.h"
#include "dmsError.h"
#include "dmsLocalDB.h"
#include "dmsGameInfo.h"

namespace {
    std::list<UIActivityIndicatorView*> _spinners;
}

@implementation BottomCell
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.frame = CGRectMake(200, 3, 20, 20);
        _spinner.hidesWhenStopped = YES;
        [self addSubview:_spinner];
        _spinner.hidden = YES;
        _spinners.push_back(_spinner);
    }
    return self;
}

-(void)dealloc{
    _spinners.remove(_spinner);
    [super dealloc];
    [_spinner release];
}

+(void)startSpin{
    std::list<UIActivityIndicatorView*>::iterator it = _spinners.begin();
    std::list<UIActivityIndicatorView*>::iterator itend = _spinners.end();
    for ( ; it != itend; ++it ){
        [*it startAnimating];
    }
}

+(void)stopSpin{
    std::list<UIActivityIndicatorView*>::iterator it = _spinners.begin();
    std::list<UIActivityIndicatorView*>::iterator itend = _spinners.end();
    for ( ; it != itend; ++it ){
        [*it stopAnimating];
    }
}

@end

@interface ResultCell : UITableViewCell {
@private
    //UIImageView* _icon;
    UILabel* _game;
    UILabel* _score;
    UILabel* _rank;
    UILabel* _percent;
}

@end

@implementation ResultCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        int x = 10;
        int y = 0;
        int w = 120;
        int h = 20;
        _game = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _game.backgroundColor = [UIColor clearColor];
        [self addSubview:_game];
        y += h-2;
        _rank = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _rank.backgroundColor = [UIColor clearColor];
        [self addSubview:_rank];
        x += w;
        _score = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _score.backgroundColor = [UIColor clearColor];
        [self addSubview:_score];
        x += w;
        _percent = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _percent.backgroundColor = [UIColor clearColor];
        [self addSubview:_percent];
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
    [_game release];
    [_score release];
    [_rank release];
    [_percent release];
}

-(void)setGameName:(const char*)name score:(int)score rank:(int)rank percent:(int)percent{
    @autoreleasepool {
        _game.text = [NSString stringWithUTF8String:name];
        _score.text = [NSString stringWithFormat:@"score:%d", score];
        _rank.text = [NSString stringWithFormat:@"rank:%d", rank];
        _percent.text = [NSString stringWithFormat:@"%d%%", percent];
    }
}

@end


@implementation DmsResultTableViewController
@synthesize parentVC;

-(void)updateIdxs{
    if ( !_ranks.empty() ){
        _sectionIdxs.clear();
        std::vector<DmsRank>::iterator it = _ranks.begin();
        std::vector<DmsRank>::iterator itend = _ranks.end();
        std::string currDate = it->date;
        _sectionIdxs.push_back(0);
        for ( int i = 0; it != itend; ++it, ++i ){
            if ( currDate.compare(it->date) != 0 ){
                currDate = it->date;
                _sectionIdxs.push_back(i);
            }
        }
    }
}

-(int)getBottomSection{
    return _sectionIdxs.size()-1;
}

-(int)getBottomRow{
    return _ranks.size()-_sectionIdxs[_sectionIdxs.size()-1];
}

-(void)onGetTimeLineWithError:(int)error ranks:(const std::vector<DmsRank>&)ranks{
    if ( error != DMSERR_NONE ){
        lwerror("onGetTimeLineWithError:" << error);
        [self stopLoading];
        [BottomCell stopSpin];
        return;
    }
    
    if ( ranks.empty() ){
        [self stopLoading];
        [BottomCell stopSpin];
        return;
    }
    
    if ( _ranks.empty() ){
        _ranks = ranks;
        [self updateIdxs];
        [self.tableView reloadData];
        [self stopLoading];
        [BottomCell stopSpin];
        return;
    }
    
    int btmSecOld = [self getBottomSection];
    int btmRowOld = [self getBottomRow];
    
    std::vector<DmsRank> ranksold = _ranks;
    _ranks.clear();
    std::vector<DmsRank>::const_iterator itold = ranksold.begin();
    std::vector<DmsRank>::const_iterator itoldend = ranksold.end();
    std::vector<DmsRank>::const_iterator it = ranks.begin();
    std::vector<DmsRank>::const_iterator itend = ranks.end();
    std::vector<DmsRank>::const_iterator* pitwin = NULL;
    std::string currdate;
    int currsec = -1;
    int currrow = -1;
    NSMutableIndexSet* sections = [[NSMutableIndexSet alloc] init];
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    while ( true ) {
        if ( itold == itoldend && it == itend ){
            break;
        }
        if ( itold == itoldend ){
            pitwin = &it;
        }else if ( it == itend ){
            pitwin = &itold;
        }else{
            if ( it->idx > itold->idx ){
                pitwin = &it;
            }else if ( it->idx < itold->idx ){
                pitwin = &itold;
            }else{
                pitwin = &itold;
                ++it;
            }
        }
        if ( currdate.compare((*pitwin)->date) != 0 ){
            currdate = (*pitwin)->date;
            currrow = 0;
            ++currsec;
        }else{
            ++currrow;
        }
        if ( *pitwin == it ){
            if ( currrow == 0 ){
                //看这个日期是不是原先有，没有就是新的section
                bool isnewsec = true;
                if ( itold != itoldend ){
                    if ( itold->date.compare(it->date) == 0 ){
                        isnewsec = false;
                    }
                }
                if ( isnewsec ){
                    [sections addIndex:currsec];
                }
            }
            [indexPaths addObject:[NSIndexPath indexPathForRow:currrow inSection:currsec]];
        }
        _ranks.push_back(**pitwin);
        ++(*pitwin);
    }
    
    [self updateIdxs];
    [self.tableView beginUpdates];
    int btmSec = [self getBottomSection];
    int btmRow = [self getBottomRow];
    if ( btmSec != btmSecOld || btmRow != btmRowOld ){
        NSIndexPath* ipath = [NSIndexPath indexPathForRow:btmRowOld inSection:btmSecOld];
        NSArray* rows = [[NSArray alloc]initWithObjects: ipath, nil];
        [self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
        [rows release];
        [indexPaths addObject:[NSIndexPath indexPathForRow:btmRow inSection:btmSec]]; 
    }
    [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    
    [sections release];
    [indexPaths release];
    
    [self stopLoading];
    [BottomCell stopSpin];
}


- (void)refresh{
    dmsGetTimeline(DmsLocalDB::s().getTopResultId(), 5);
    //[self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _rankVC = [[DmsRankViewController alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [_rankVC release];
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

    dmsGetTimeline(DmsLocalDB::s().getTopResultId(), 1);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _ranks.clear();
    _sectionIdxs.clear();
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionIdxs.size();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int size = _sectionIdxs.size();
    if ( section < size ){
        if ( section == size-1 ){
            return _ranks.size()-_sectionIdxs[section]+1;
        }else{
            return _sectionIdxs[section+1]-_sectionIdxs[section];
        }
    }else{
        lwerror("section out of range");
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( section < _sectionIdxs.size() ){
        int rankIdx = _sectionIdxs[section];
        NSString* str = [NSString stringWithFormat:@"%s", _ranks[rankIdx].date.c_str()];
        return str;
    }
    
    return @"error";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    // Configure the cell...
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    static NSString *IDBOTTOM = @"Bottom";
    static NSString *IDCELL = @"Cell";
    if ( section == [self getBottomSection] && row == [self getBottomRow] ){    //bottom
        cell = [tableView dequeueReusableCellWithIdentifier:IDBOTTOM];
        if (cell == nil) {
            cell = [[[BottomCell alloc] initWithReuseIdentifier:IDBOTTOM] autorelease];
            cell.textLabel.text = @"bottom";
        }
    }else{  //common
        ResultCell* rcell = [tableView dequeueReusableCellWithIdentifier:IDCELL];
        if (cell == nil) {
            rcell = [[[ResultCell alloc] initWithReuseIdentifier:IDCELL] autorelease];
        }
        cell = rcell;
        
        DmsRank& rank = _ranks[_sectionIdxs[section]+row];
        //NSString* str = [[NSString alloc] initWithFormat:@"%d  %d", rank.gameid, rank.idx];
        //rcell.textLabel.text = str;
        rcell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //[str release];
        
        const DmsGameInfo* pinfo = dmsGetGameInfo(rank.gameid);
        if ( pinfo ){
            [rcell setGameName:pinfo->name score:rank.score rank:rank.rank percent:0];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if ( section == [self getBottomSection] && row == [self getBottomRow] ){
        [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow] animated:YES];
    }else{
        [parentVC.navigationController pushViewController:_rankVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( indexPath.section == [self getBottomSection] && indexPath.row == [self getBottomRow] ){
        return 30;
    }else{
        return 40;
    }
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if ( _ranks.empty() ){
        dmsGetTimeline(DmsLocalDB::s().getTopResultId(), 1);
        return;
    }
    int y = scrollView.contentOffset.y;
    int maxy = scrollView.contentSize.height - scrollView.frame.size.height;
    maxy = std::max(maxy, 0);
    if ( y > maxy ){
        [BottomCell startSpin];
        dmsGetTimeline(_ranks.back().idx-1, 10);
    }else if ( y < 0 ){
        //dmsGetTimeline(DmsLocalDB::s().getTopRankId(), 10);
    }
}


@end
