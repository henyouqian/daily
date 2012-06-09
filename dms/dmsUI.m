#include "dmsUI.h"
#include "DmsMyRankViewController.h"
#include "DmsCountryRankViewController.h"

UITabBarController* gTabBarController = nil;

@interface Dele : NSObject {
@private
    
}

@end

@implementation Dele

-(void)onClose{
    if ( gTabBarController ){
        [UIView setAnimationDelegate:nil];
        [gTabBarController.view removeFromSuperview];
        [gTabBarController release];
        gTabBarController = nil;
    }
}

@end

Dele* gDele = nil;

void dmsUI(){
    UIView* parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    if ( !gTabBarController ){
        if ( !gDele ){
            gDele = [[Dele alloc] init];
        }
        gTabBarController = [[UITabBarController alloc] init];
        
        DmsMyRankViewController* myVC = [[DmsMyRankViewController alloc] init];
        UINavigationController *myNavigation = [[UINavigationController alloc] initWithRootViewController:myVC];
        UITabBarItem *tabBarItem = [myNavigation tabBarItem];
        tabBarItem.title = @"Me";
        
        DmsCountryRankViewController* countryVC = [[DmsCountryRankViewController alloc] init];
        UINavigationController *countryNavigation = [[UINavigationController alloc] initWithRootViewController:countryVC];
        tabBarItem = [countryNavigation tabBarItem];
        tabBarItem.title = @"Country";
        
        NSArray *viewControllerArray = [[NSArray alloc] initWithObjects:myNavigation,countryNavigation,nil];
        gTabBarController.viewControllers = viewControllerArray;
        
        [viewControllerArray release];
        [myVC release];
        [countryVC release];
        [myNavigation release];
        [countryNavigation release];
    }
    
    [parentView addSubview:gTabBarController.view];
    
    int w = parentView.frame.size.width;
    int h = parentView.frame.size.height;
    gTabBarController.view.frame = CGRectMake(0, h, w, h);
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    gTabBarController.view.frame = CGRectMake(0, 0, w, h);
    [UIView setAnimationDelegate:gDele];
    [UIView commitAnimations];
}

void dmsUIClose(){
    UIView* parentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    int w = parentView.frame.size.width;
    int h = parentView.frame.size.height;
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    gTabBarController.view.frame = CGRectMake(0, h, w, h);
    [UIView setAnimationDelegate:gDele];
    [UIView setAnimationDidStopSelector:@selector(onClose)];
    [UIView commitAnimations];
}

void dmsUIDestroy(){
    if ( gTabBarController ){
        [UIView setAnimationDelegate:nil];
        [gTabBarController.view removeFromSuperview];
        [gTabBarController release];
        gTabBarController = nil;
    }
}
