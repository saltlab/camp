//
//  OutputComponent.h
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLWriter.h"
#import "UIState.h"

@interface OutputComponent : NSObject

@property(nonatomic, retain) XMLWriter *xmlWriter;
@property(nonatomic, strong) NSMutableArray *stateNodesArray;
@property(nonatomic, assign) int currentIndexNumber;

+ (OutputComponent*)sharedOutput;		// this returns nil when NOT in DEGBUG mode
- (void)setup;
- (void)setupOutputUIElementsFile;
- (void)setupOutputStateGraphFile;
- (void)removeOldScreenshotsDirectory;
- (void)createScreenshotsDirectory;
- (void)takeScreenshotOfState:(UIState*)node;
- (void)outputGraphFile:(NSMutableString*)outputString;
- (void)outputUIElementsFile:(NSMutableString*)outputString;
- (void)outputStateGraphFile:(NSMutableString*)outputString;
//- (void)writeAllStatesElements;
- (void)logPropertiesForState:(UIState*)node;
- (void)writeXMLFile:(UIState*)node;
- (void)identifyEvent:(UIEvent*)event;
- (void)identifyRequest:(NSMutableURLRequest*)request method:(NSString*)method parameters:(NSDictionary*)parameters;
- (void)identifyRequest:(NSURLRequest*)request;
- (void)identifyCall:(NSURL*)url;
- (UIElement*)find:(UIView*)view inArray:(NSMutableArray*)uiElementsArray;

@end