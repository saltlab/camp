//
//  UIState.h
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIElement.h"

@interface UIState : NSObject

@property(nonatomic, retain) NSString *className;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *actionName;
@property(nonatomic, assign) int indexNumber;
@property(nonatomic, assign) int numberOfUIElements;
@property(nonatomic, retain) NSMutableArray *uiElementsArray;
@property(nonatomic, retain) UIViewController *viewController;

- (void)setAllUIElementsForViewController:(UIViewController*)currentViewController;
- (void)addAllSubviewsOfView:(UIView*)thisView toArray:(NSMutableArray*)elements;

@end
