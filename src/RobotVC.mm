//
//  RobotVC.m
//  daily
//
//  Created by Li Wei on 12-6-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RobotVC.h"
#include "taskYesOrNo.h"

RobotVC* gRobotVC;

void robotView(){
    UIView* parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    if ( !gRobotVC ){
        gRobotVC = [[RobotVC alloc] initWithNibName:@"RobotVC" bundle:nil];
    }
    
    [parentView addSubview:gRobotVC.view];
    
    int w = parentView.frame.size.width;
    int h = parentView.frame.size.height;
    gRobotVC.view.frame = CGRectMake(0, h, w, h);
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    gRobotVC.view.frame = CGRectMake(0, 0, w, h);
    [UIView commitAnimations];
}

@implementation RobotVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)close{
    UIView* parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    int w = parentView.frame.size.width;
    int h = parentView.frame.size.height;
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.frame = CGRectMake(0, h, w, h);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onClose)];
    [UIView commitAnimations];
}

-(void)onClose{
    TaskYesOrNo::s().show(true);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end