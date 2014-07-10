//
//  UIState.m
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import "UIState.h"

@implementation UIState

@synthesize uiElementsArray;


- (void)setAllUIElements:(UIViewController*)currentViewController  {
	
	NSMutableArray *elements = [[NSMutableArray alloc] init];
	if ([currentViewController isKindOfClass:[UITableViewController class]]) {
		UITableViewController* thisTableViewController = (UITableViewController*)currentViewController;
		[elements addObject:[UIElement addUIElement:thisTableViewController.tableView]];
    }
	else if ([currentViewController.view isKindOfClass:[UITableView class]])
		[elements addObject:[UIElement addUIElement:currentViewController.view]];
    
    else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
		UITabBarController* thisTabBarController = (UITabBarController*)currentViewController;
		[elements addObject:[UIElement addUIElement:thisTabBarController.tabBar]];
	}
    else
        [self addAllSubviewsOfView:currentViewController.view toArray:elements];
	
    // If this view controller is inside a navigation controller or tab bar controller, or has been presented modally by another view controller, return it.
    if (currentViewController.navigationController || ([currentViewController.parentViewController isKindOfClass:[UINavigationController class]])) {
        
        UINavigationController* thisNav = (UINavigationController*)currentViewController.parentViewController;
        if (!currentViewController.navigationController.navigationBar.hidden || !thisNav.navigationBar.hidden) {
            
            if (currentViewController.navigationItem.rightBarButtonItem)
                [elements addObject:[UIElement addNavigationItem:currentViewController.navigationItem.rightBarButtonItem withAction:@"RightBarButtonItem"]];
            if (currentViewController.navigationItem.leftBarButtonItem)
                [elements addObject:[UIElement addNavigationItem:currentViewController.navigationItem.leftBarButtonItem withAction:@"LeftBarButtonItem"]];
            else if (currentViewController.navigationItem.backBarButtonItem
                     && !currentViewController.navigationItem.hidesBackButton
                     && currentViewController.navigationItem.backBarButtonItem.width>0)
                [elements addObject:[UIElement addNavigationItem:currentViewController.navigationItem.backBarButtonItem withAction:@"BackBarButtonItem"]];
            else if (!thisNav.navigationBar.hidden) {
                NSArray *thisArray = thisNav.navigationBar.items;
                for (UINavigationItem *item in thisArray) {
                    UIView *thisBackButtonView = [item valueForKey:@"_backButtonView"];
                    if (item.backBarButtonItem && !item.hidesBackButton && item.backBarButtonItem.width>0)
                        [elements addObject:[UIElement addNavigationItem:item.backBarButtonItem withAction:@"BackBarButtonItem"]];
                    else if (thisBackButtonView && !(thisBackButtonView.frame.origin.x <0 || thisBackButtonView.frame.origin.y <0))
                        [elements addObject:[UIElement addNavigationItemView:thisBackButtonView withAction:@"UndefinedBackButtonItem"]];
                    else if (item.leftBarButtonItem)
                        [elements addObject:[UIElement addNavigationItem:item.leftBarButtonItem withAction:@"LeftBarButtonItem"]];
                }
            }
        }
    }
    
    //detecting if a UIAlert is open
    UIAlertView* alertView = [self doesAlertViewExist];
    if (alertView)
        [elements addObject:alertView];
    
    //detecting if a UIActionSheet is open
    //UIActionSheet* actionView = [UIElement doesActionSheetExist];
    //if (actionView)
    //    [elements addObject:actionView];
    
	self.uiElementsArray = elements;
}


- (void)addAllSubviewsOfView:(UIView*)thisView toArray:(NSMutableArray*)elements {
	
	NSArray *views = [thisView subviews];
	for(UIView *subview in views) {
		if (!subview.hidden) {
            
            if ([subview isKindOfClass:[UINavigationBar class]]) {
                UINavigationBar* thisNavigationBar = (UINavigationBar*)subview;
                NSArray *thisArray = thisNavigationBar.items;
                
                for (UINavigationItem *item in thisArray) {
                    UIView *thisBackButtonView = [item valueForKey:@"_backButtonView"];
                    if (item.backBarButtonItem && !item.hidesBackButton && item.backBarButtonItem.width>0)
                        [elements addObject:[UIElement addNavigationItem:(UIBarButtonItem*)item.backBarButtonItem withAction:@"BackBarButtonItem"]];
                    else if (thisBackButtonView && !(thisBackButtonView.frame.origin.x <0 || thisBackButtonView.frame.origin.y <0))
                        [elements addObject:[UIElement addNavigationItemView:thisBackButtonView withAction:@"UndefinedBackButtonItem"]];
                    else if (item.leftBarButtonItem)
                        [elements addObject:[UIElement addNavigationItem:(UIBarButtonItem*)item.leftBarButtonItem withAction:@"LeftBarButtonItem"]];
                    else if (item.rightBarButtonItem)
                        [elements addObject:[UIElement addNavigationItem:(UIBarButtonItem*)item.rightBarButtonItem withAction:@"RightBarButtonItem"]];
                    else if ([self isBarButtonAdded]) {
                        UINavigationItem *item = [ICrawlerController sharedICrawler].navItem;
                        if (item) {
                            if (item.leftBarButtonItem)
                                [elements addObject:[UIElement addNavigationItem:(UIBarButtonItem*)item.leftBarButtonItem withAction:@"LeftBarButtonItem"]];
                            else if (item.rightBarButtonItem)
                                [elements addObject:[UIElement addNavigationItem:(UIBarButtonItem*)item.rightBarButtonItem withAction:@"RightBarButtonItem"]];
                        }
                    }
                }
            }
            else if (![subview isKindOfClass:[UITableView class]] && [subview isKindOfClass:[UIScrollView class]]) {
                [elements addObject:[UIElement addUIElement:subview]];
                [self addAllSubviewsOfView:subview toArray:elements];
            }
            else if (!(([subview isKindOfClass:[UIControl class]])
                       || ([subview isKindOfClass:[UIWebView class]])
                       || ([subview isKindOfClass:[UISearchBar class]])
                       || ([subview isKindOfClass:[UIAlertView class]])
                       || ([subview isKindOfClass:[UIActionSheet class]])
                       || ([subview isKindOfClass:[UITableViewCell class]])
                       || ([subview isKindOfClass:[UINavigationBar class]])
                       || ([subview isKindOfClass:[UIToolbar class]])
                       || ([subview isKindOfClass:[UITabBar class]])
                       || ([subview isKindOfClass:[UIImageView class]])
                       || ([subview isKindOfClass:[UIProgressView class]])
                       || ([subview isKindOfClass:[UIPickerView class]])
                       || ([subview isKindOfClass:[UILabel class]])
                       || ([subview isKindOfClass:[UIButton class]])
                       || ([subview isKindOfClass:[UIWindow class]])
                       || ([subview isKindOfClass:[UITableView class]])
                       || ([subview isKindOfClass:[UIActivityIndicatorView class]]))){
                
                [self addAllSubviewsOfView:subview toArray:elements];
            } else 
                [elements addObject:[UIElement addUIElement:subview]];
        }
	}
}


@end
