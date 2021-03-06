//
//  UIState.h
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIElement.h"

@interface UIEdge : NSObject

@property(nonatomic, retain) NSString *timeStamp;
@property(nonatomic, assign) int sourceStateID;
@property(nonatomic, assign) int targetStateID;
@property(nonatomic, retain) UIElement *touchedElement;
@property(nonatomic, retain) NSMutableArray *methodsArray;

@end
