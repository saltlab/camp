//
//  UIElement.h
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIElement : NSObject

@property(nonatomic, assign) id object;
@property(nonatomic, assign) Class objectClass;
@property(nonatomic, retain) NSString *className;
@property(nonatomic, retain) NSString *action;
@property(nonatomic, assign) id target;
@property(nonatomic, assign) bool visited;
@property(nonatomic, retain) NSString *details;
@property(nonatomic, retain) NSString *label;

- (void)addActionForTargetUIElement;
- (BOOL)isEqualToUIElement:(UIElement*)e;
+ (UIElement*)addUIElement:(id)_object;
+ (UIElement*)addNavigationItem:(UIBarButtonItem*)barButtonItem withAction:(NSString*)action;
+ (UIElement*)addNavigationItemView:(UIView*)thisBackButtonView withAction:(NSString*)action;
+ (UIElement*)addTableView:(UITableView*)_tableView;
+ (UIElement*)addTabView:(UITabBarController*)_tabController;
+ (UIElement*)addLabel:(UILabel*)_label;
+ (UIElement*)addButton:(UIButton*)_button;

@end
