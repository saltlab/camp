//
//  OutputComponent.h
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLWriter.h"
#import "UIState.h"
#import "UIEdge.h"
#import "UIElement.h"

@interface OutputComponent : NSObject

@property(nonatomic, retain) XMLWriter *xmlWriter;
@property(nonatomic, retain) UIEdge *currentEdge;
@property(nonatomic, retain) UIState *currentNode;
@property(nonatomic, retain) NSMutableArray *stateNodesArray;
@property(nonatomic, retain) NSMutableArray *methodCallsArray;
@property(nonatomic, assign) int currentIndexNumber;

+ (OutputComponent*)sharedOutput;		// this returns nil when NOT in DEGBUG mode
//- (void)addAOPToMethodCalls;
- (void)setup;
- (void)setupOutputStateGraphFile;
- (void)removeOldScreenshotsDirectory;
- (void)createScreenshotsDirectory;
- (void)takeScreenshotOfState;
- (void)outputStateGraphFile:(NSMutableString*)outputString;

- (void)writeXMLFile:(UIState*)node;
- (void)logPropertiesForEdge;
- (void)logPropertiesForState;

- (void)createEdge:(UIEvent*)event;
//- (void)identifyRequest:(NSMutableURLRequest*)request method:(NSString*)method parameters:(NSDictionary*)parameters;
//- (void)identifyRequest:(NSURLRequest*)request;
//- (void)identifyCall:(NSURL*)url;
- (UIElement*)find:(UIView*)view inArray:(NSMutableArray*)uiElementsArray;
- (void)traceMethod:(NSString*)method;
- (void)traceAllClassesMethods:(NSString*)method;

@end
