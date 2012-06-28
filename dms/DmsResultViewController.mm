//
//  DmsResultViewController.m
//  daily
//
//  Created by Li Wei on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DmsResultViewController.h"
#import "DmsResultTableViewController.h"
#include "dmsUI.h"

@implementation DmsResultViewController
@synthesize tableVC = _tableVC;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [_tableVC release];
    _tableVC = nil;
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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tableVC = [[DmsResultTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _tableVC.parentVC = self;
    [self.view insertSubview:_tableVC.tableView atIndex:0];
    
    self.title = @"Results";
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
    self.navigationItem.rightBarButtonItem = closeButton;
    [closeButton release];
    
    int y = 40;
    _tableVC.tableView.autoresizingMask = UIViewAutoresizingNone;
    [_tableVC.tableView setFrame:CGRectMake(0, y, 320, 480-y-self.navigationController.navigationBar.frame.size.height)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_tableVC release];
    _tableVC = nil;
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
    [_tableVC viewWillAppear:animated];
}

@end
