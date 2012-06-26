//
//  DmsRootViewController.m
//  daily
//
//  Created by Li Wei on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DmsRootViewController.h"
#import "dmsUI.h"
#import "DmsRankViewController.h"
#include "dmsError.h"
#include "dmsLocalDB.h"

@implementation DmsRootViewController
@synthesize tableView;

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _rankVC = [[DmsRankViewController alloc] init];
    }
    return self;
}

-(void)dealloc{
    [_rankVC release];
}

-(void)onClose{
    dmsUIClose();
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
    _n = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Results";
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
    self.navigationItem.rightBarButtonItem = closeButton;
    [closeButton release];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _isUpdating = false;
    
    dmsGetTimelineFromId(DmsLocalDB::s().getTopRankId(), 1);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    _ranks.clear();
    _sectionIdxs.clear();
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath: [self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"sectionnnnnnnnn");
    return _sectionIdxs.size();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"rowwwwwwwwwww");
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
    NSLog(@"titleeeeeeeeee");
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
    NSString* str = [[NSString alloc] initWithFormat:@"%d", _ranks[_sectionIdxs[section]+row].gameid];
    cell.textLabel.text = str;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [str release];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ( _n == 0 ){
//        dmsGetTimelineFromId(DmsLocalDB::s().getTopRankId()-5, 2);
//    }else if ( _n == 1 ){
//        dmsGetTimelineFromId(DmsLocalDB::s().getTopRankId()-1, 30);
//    }
//    ++_n;
    
    [self.navigationController pushViewController:_rankVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(void)onGetTimeLineWithError2:(int)error ranks:(const std::vector<DmsRank>&)ranks{
    _isUpdating = false;
    if ( error != DMSERR_NONE ){
        lwerror("onGetTimeLineWithError:" << error);
        return;
    }
    
    if ( _ranks.empty() ){
        _ranks = ranks;
        [self updateIdxs];
        [self.tableView reloadData];
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
}

-(void)onGetTimeLineWithError:(int)error ranks:(const std::vector<DmsRank>&)ranks{
    _isUpdating = false;
    
    if ( error != DMSERR_NONE ){
        lwerror("onGetTimeLineWithError:" << error);
    }
    if ( _ranks.empty() ){
        _ranks = ranks;
        [self updateIdxs];
        [self.tableView reloadData];
        return;
    }
    int _maxidx = _ranks.front().idx;
    int _minidx = _ranks.back().idx;
    int maxidx = ranks.front().idx;
    int minidx = ranks.back().idx;
    
    
    if ( maxidx > _maxidx ){
        std::string currdate;
        int currsec = -1;
        int currrow = -1;
        std::string _maxdate = _ranks.front().date;
        NSMutableIndexSet* sections = [[NSMutableIndexSet alloc] init];
        NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
        
        std::vector<DmsRank>::const_iterator it = ranks.begin();
        std::vector<DmsRank>::const_iterator itend = ranks.end();
        for ( ; it != itend; ++it ){
            if ( it->idx == _maxidx ){
                break;
            }
            if ( it->date.compare(currdate) != 0 ){
                ++currsec;
                currdate = it->date;
                currrow = 0;
                if ( currdate.compare(_maxdate) != 0 ){
                    [sections addIndex:currsec];
                }
                [indexPaths addObject:[NSIndexPath indexPathForRow:currrow inSection:currsec]];
            }else{
                ++currrow;
                [indexPaths addObject:[NSIndexPath indexPathForRow:currrow inSection:currsec]];
            }
        }
        _ranks.insert(_ranks.begin(), ranks.begin(), it);
        [self updateIdxs];
        [self.tableView beginUpdates];
        [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
        
        [sections release];
        [indexPaths release];
    }
    
    if ( minidx < _minidx ){
        std::string currdate = _ranks.back().date;
        int currsec = _sectionIdxs.size()-1;
        int currrow = _ranks.size() - _sectionIdxs.back()-1;
        NSMutableIndexSet* sections = [[NSMutableIndexSet alloc] init];
        NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
        
        std::vector<DmsRank>::const_iterator it = ranks.begin();
        std::vector<DmsRank>::const_iterator itend = ranks.end();
        for ( ; it != itend; ++it ){
            if ( it->idx < _minidx ){
                if ( it->date.compare(currdate) != 0 ){
                    currdate = it->date;
                    currrow = 0;
                    ++currsec;
                    [sections addIndex:currsec];
                    [indexPaths addObject:[NSIndexPath indexPathForRow:currrow inSection:currsec]];
                }else{
                    ++currrow;
                    [indexPaths addObject:[NSIndexPath indexPathForRow:currrow inSection:currsec]];
                }
                _ranks.push_back(*it);
            }
        }
        [self updateIdxs];
        [self.tableView beginUpdates];
        [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
        
        [sections release];
        [indexPaths release];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //lwinfo(scrollView.contentOffset.y << "|" << scrollView.contentSize.height - scrollView.frame.size.height );
    int y = scrollView.contentOffset.y;
    int maxy = scrollView.contentSize.height - scrollView.frame.size.height;
    if ( !_isUpdating ){
        if ( y > maxy ){
            _isUpdating = true;
            //_ranks.back()
            dmsGetTimelineFromId(_ranks.back().idx+1, 10);
        }else if ( y < 0 ){
            _isUpdating = true;
            dmsGetTimelineFromId(DmsLocalDB::s().getTopRankId(), 10);
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

@end
