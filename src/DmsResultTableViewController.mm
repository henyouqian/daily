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

-(void)onGetTimeLineWithError:(int)error ranks:(const std::vector<DmsRank>&)ranks{
    if ( error != DMSERR_NONE ){
        lwerror("onGetTimeLineWithError:" << error);
        [self stopLoading];
        return;
    }
    
    if ( _ranks.empty() ){
        _ranks = ranks;
        [self updateIdxs];
        [self.tableView reloadData];
        [self stopLoading];
        return;
    }
    if ( ranks.front().idx <= _ranks.front().idx && ranks.back().idx >= _ranks.back().idx ){
        [self stopLoading];
        return;
    }
    
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
    [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    
    [sections release];
    [indexPaths release];
    
    [self stopLoading];
}


- (void)refresh{
    dmsGetTimeline(DmsLocalDB::s().getTopRankId(), 10);
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

    dmsGetTimeline(DmsLocalDB::s().getTopRankId(), 1);
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
            return _ranks.size()-_sectionIdxs[section];
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
        NSString* str = [[[NSString alloc] initWithFormat:@"%s", _ranks[rankIdx].date.c_str()] autorelease];
        return str;
    }
    
    return @"error";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    DmsRank& rank = _ranks[_sectionIdxs[section]+row];
    NSString* str = [[NSString alloc] initWithFormat:@"%d  %d", rank.gameid, rank.idx];
    cell.textLabel.text = str;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [str release];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [parentVC.navigationController pushViewController:_rankVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if ( _ranks.empty() ){
        dmsGetTimeline(DmsLocalDB::s().getTopRankId(), 1);
        return;
    }
    int y = scrollView.contentOffset.y;
    int maxy = scrollView.contentSize.height - scrollView.frame.size.height;
    maxy = std::max(maxy, 0);
    if ( y > maxy ){
        dmsGetTimeline(_ranks.back().idx-1, 10);
    }else if ( y < 0 ){
        //dmsGetTimeline(DmsLocalDB::s().getTopRankId(), 10);
    }
}


@end
