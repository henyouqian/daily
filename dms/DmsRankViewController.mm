//
//  DmsRankViewController.m
//  daily
//
//  Created by Li Wei on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DmsRankViewController.h"
#import "dmsUI.h"

@implementation DmsRankViewController

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Ranks";
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
        self.navigationItem.rightBarButtonItem = backButton;
        [backButton release];
    }
    return self;
}

-(void)dealloc{
    NSLog(@"dealloc");
}

-(void)onClose{
    dmsUIClose();
}

-(void)loadData{
    dmsGetTimeline(0, 10);
    dmsGetTimeline(3, 1);
    
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
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

-(void)onGetTimeLine:(const std::vector<DmsRank>&)ranks{
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

@end
