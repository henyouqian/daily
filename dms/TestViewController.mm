//
//  TestViewController.m
//  daily
//
//  Created by Li Wei on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestViewController.h"
#import "TestTableViewController.h"
#include "dmsUI.h"

@implementation TestViewController

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
    [_testTableVC release];
    _testTableVC = nil;
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
    _testTableVC = [[TestTableViewController alloc] init];
    [self.view insertSubview:_testTableVC.tableView atIndex:0];
    _testTableVC.tableView.frame = CGRectMake(0, 50, 320, 480-50);
    
    self.title = @"Results";
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"close" style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
    self.navigationItem.rightBarButtonItem = closeButton;
    [closeButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_testTableVC release];
    _testTableVC = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
