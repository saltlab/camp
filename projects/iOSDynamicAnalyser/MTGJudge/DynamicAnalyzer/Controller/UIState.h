//
//  UIState.h
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIState : NSObject

@property(nonatomic, retain) NSMutableArray *uiElementsArray;

- (void)setAllUIElements:(UIViewController*)currentViewController;
- (void)addAllSubviewsOfView:(UIView*)thisView toArray:(NSMutableArray*)elements;
- (void)addTableView:(UITableView*)_tableView;

@end
