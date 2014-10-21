//
//  UIState.m
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import "UIState.h"
#import "OutputComponent.h"
#import "UIElement.h"

@implementation UIState

@synthesize className, title, actionName, indexNumber, numberOfUIElements, uiElementsArray, viewController;


- (void)setAllUIElementsForViewController:(UIViewController*)currentViewController {
	
	NSMutableArray *elements = [[NSMutableArray alloc] init];
    
    UITabBarController *thisTabController = currentViewController.tabBarController;
    if (thisTabController && [[thisTabController tabBar] window]) { //&& thisTabController.tabBar.userInteractionEnabled
		[elements addObject:[UIElement addTabView:(UITabBarController*)thisTabController]];
    }
    
	if ([currentViewController isKindOfClass:[UITableViewController class]]) {
		UITableViewController* thisTableViewController = (UITableViewController*)currentViewController;
		[elements addObject:[UIElement addTableView:thisTableViewController.tableView]];
    }
	else if ([currentViewController.view isKindOfClass:[UITableView class]])
		[elements addObject:[UIElement addTableView:(UITableView*)currentViewController.view]];
    
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
                [elements addObject:[UIElement addNavigationItem:currentViewController.navigationItem.backBarButtonItem withAction:@"goBack"]];
            else if (!thisNav.navigationBar.hidden) {
                NSArray *thisArray = thisNav.navigationBar.items;
                for (UINavigationItem *item in thisArray) {
                    UIView *thisBackButtonView = [item valueForKey:@"_backButtonView"];
                    if (item.backBarButtonItem && !item.hidesBackButton && item.backBarButtonItem.width>0)
                        [elements addObject:[UIElement addNavigationItem:item.backBarButtonItem withAction:@"goBack"]];
                    else if (thisBackButtonView && thisBackButtonView.userInteractionEnabled && !(thisBackButtonView.frame.origin.x <0 || thisBackButtonView.frame.origin.y <0))
                        [elements addObject:[UIElement addNavigationItemView:thisBackButtonView withAction:@"goBack"]];
                    else if (item.leftBarButtonItem)
                        [elements addObject:[UIElement addNavigationItem:item.leftBarButtonItem withAction:@"LeftBarButtonItem"]];
                }
            }
        }
    }
    
    //detecting if a UIAlert is open
    if([[NSString stringWithFormat:@"%@",currentViewController.class] isEqualToString:@"_UIModalItemsPresentingViewController"])
    {
        //UIAlertView* v = (UIAlertView*)currentViewController.view;
        //UILabel* title = [currentViewController.view valueForKey:@"_titleLabel"];
        //NSMutableArray* i = [currentViewController.view valueForKey:@"_buttons"];
        [elements addObject:[UIElement addAlertView:(UIAlertView*)currentViewController.view]];
        
        //        UIView *subView=nil;
        //        for (UIWindow* window in [UIApplication sharedApplication].windows){
        //            for (subView in [window subviews]){
        //                if ([subView isKindOfClass:[UIAlertView class]])
        //                    [elements addObject:[UIElement addAlertView:(UIAlertView*)subView]];
        //            }
        //        }
    }

    //detecting if a UIActionSheet is open
    //UIActionSheet* actionView = [UIElement doesActionSheetExist];
    //if (actionView)
    //    [elements addObject:actionView];
    
	self.uiElementsArray = elements;
    self.numberOfUIElements = (int)[elements count];
    //self.actionName = ?;
    
    [[OutputComponent sharedOutput] writeXMLFile:self];
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
                        [elements addObject:[UIElement addNavigationItem:(UIBarButtonItem*)item.backBarButtonItem withAction:@"goBack"]];
                    else if (thisBackButtonView && !(thisBackButtonView.frame.origin.x <0 || thisBackButtonView.frame.origin.y <0))
                        [elements addObject:[UIElement addNavigationItemView:thisBackButtonView withAction:@"goBack"]];
                    else if (item.leftBarButtonItem)
                        [elements addObject:[UIElement addNavigationItem:(UIBarButtonItem*)item.leftBarButtonItem withAction:@"LeftBarButtonItem"]];
                    else if (item.rightBarButtonItem)
                        [elements addObject:[UIElement addNavigationItem:(UIBarButtonItem*)item.rightBarButtonItem withAction:@"RightBarButtonItem"]];
                    else  { //if ([self isBarButtonAdded])
                        UINavigationItem *item = nil;//[ICrawlerController sharedICrawler].navItem;
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
            else if ([subview isKindOfClass:[UITableView class]]) {
                [elements addObject:[UIElement addTableView:(UITableView*)subview]];
            }
            else if ([subview isKindOfClass:[UILabel class]]) {
                [elements addObject:[UIElement addLabel:(UILabel*)subview]];
            }
            else if ([subview isKindOfClass:[UIButton class]]) {
                [elements addObject:[UIElement addButton:(UIButton*)subview]];
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
