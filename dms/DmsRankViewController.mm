//
//  DmsRankViewController.m
//  daily
//
//  Created by Li Wei on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DmsRankViewController.h"
#import "dms.h"

namespace {
    std::list<UIActivityIndicatorView*> _spinners;
    const int RANKS_PER_PAGE = 20;
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

@implementation DmsRankViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.tableView.allowsSelection = NO;
    }
    return self;
}

- (void)setGameid:(int)gameid date:(const char* )date
{
    if ( gameid != _gameid || _date.compare(date) != 0 ){
        _gameid = gameid;
        _date = date;
        _ranks.clear();
        [self.tableView reloadData];
        dmsGetRanks(gameid, date, 0, RANKS_PER_PAGE);
        [BottomCell startSpin];
    }else{
        self.tableView.contentOffset = CGPointZero;
    }
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Ranks";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _ranks.size()+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *BottomIdentifier = @"Bottom";
    
    UITableViewCell *cell = nil;
    
    int row = indexPath.row;
    if ( row != _ranks.size() ){
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        DmsRank& rank = _ranks[indexPath.row];
        NSString* str = [[NSString alloc] initWithFormat:@"%d %s rk:%d scr:%d", rank.row, rank.username.c_str(), rank.rank, rank.score];
        cell.textLabel.text = str;
        [str release];
    }else{
        cell = [[[BottomCell alloc] initWithReuseIdentifier:BottomIdentifier] autorelease];
        cell.textLabel.text = @"bottom";
    }
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

-(void)onGetRankError:(int)error ranks:(const std::vector<DmsRank>&)ranks{
    @autoreleasepool {
        [BottomCell stopSpin];
        std::vector<DmsRank> ranksold = _ranks;
        _ranks.clear();
        std::vector<DmsRank>::const_iterator itold = ranksold.begin();
        std::vector<DmsRank>::const_iterator itoldend = ranksold.end();
        std::vector<DmsRank>::const_iterator it = ranks.begin();
        std::vector<DmsRank>::const_iterator itend = ranks.end();
        std::vector<DmsRank>::const_iterator* pitwin = NULL;
        NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
        int currrow = 0;
        while ( true ) {
            if ( itold == itoldend && it == itend ){
                break;
            }
            if ( itold == itoldend ){
                pitwin = &it;
            }else if ( it == itend ){
                pitwin = &itold;
            }else{
                if ( it->row < itold->row ){
                    pitwin = &it;
                }else if ( it->row > itold->row ){
                    pitwin = &itold;
                }else{
                    pitwin = &itold;
                    ++it;
                }
            }
            if ( *pitwin == it ){
                [indexPaths addObject:[NSIndexPath indexPathForRow:currrow inSection:0]];
            }
            _ranks.push_back(**pitwin);
            ++(*pitwin);
            ++currrow;
        }
        
        [self.tableView beginUpdates];
        if ( !ranksold.empty() ){
            NSIndexPath* ipath = [NSIndexPath indexPathForRow:ranksold.size() inSection:0];
            NSArray* rows = [[NSArray alloc]initWithObjects: ipath, nil];
            [self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
            [rows release];
            [indexPaths addObject:[NSIndexPath indexPathForRow:_ranks.size() inSection:0]];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
    }
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    int y = scrollView.contentOffset.y;
    int maxy = scrollView.contentSize.height - scrollView.frame.size.height;
    maxy = std::max(maxy, 0);
    if ( y > maxy ){
        [BottomCell startSpin];
        if ( _ranks.empty() ){
            dmsGetRanks(_gameid, _date.c_str(), 0, RANKS_PER_PAGE);
            return;
        }else{
            dmsGetRanks(_gameid, _date.c_str(), _ranks.size(), RANKS_PER_PAGE);
        }
    }else if ( y < 0 ){
        //dmsGetTimeline(DmsLocalDB::s().getTopRankId(), 10);
    }
}

@end
