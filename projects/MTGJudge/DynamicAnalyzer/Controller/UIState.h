//
//  UIState.h
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIElement.h"

@interface UIState : NSObject

@property(nonatomic, retain) NSMutableArray *uiElementsArray;

- (void)setAllUIElements:(UIViewController*)currentViewController;
- (void)addAllSubviewsOfView:(UIView*)thisView toArray:(NSMutableArray*)elements;

@end
