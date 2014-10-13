//
//  OutputComponent.m
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import "OutputComponent.h"
#import "DCIntrospect.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "Aspects.h"
#import "UIEdge.h"
#import "UIViewController+Additions.h"

typedef int (*ObjCLogProc)(BOOL, const char *, const char *, SEL);
typedef void (*logObjcMessageSends_t)(ObjCLogProc logProc);


@implementation OutputComponent

OutputComponent *sharedInstance = nil;

@synthesize xmlWriter, stateNodesArray, methodCallsArray, currentIndexNumber, currentEdge, currentNode;


- (OutputComponent*) init {
	self = [super init];
	if (self != nil) {
		// intialize variables
		self.stateNodesArray = [[NSMutableArray alloc]init];
        self.methodCallsArray = [[NSMutableArray alloc]init];
        self.currentEdge = [[UIEdge alloc] init];
        self.currentNode = [[UIState alloc] init];
        self.xmlWriter = [[XMLWriter alloc]init];
        self.currentIndexNumber = 1;
    }
	return self;
}

#pragma mark -
#pragma mark SharedInstance Methods
+ (OutputComponent *)sharedOutput {
	if (!sharedInstance)
		sharedInstance = [[OutputComponent alloc] init];
    
	return sharedInstance;
}

- (void)setup {
	[self setupOutputStateGraphFile];
    [self setupOutputcallGraphFile];
	[self removeOldScreenshotsDirectory];
    [self createScreenshotsDirectory];
}

#pragma mark -
#pragma mark Related Directory Methods

- (void)setupOutputStateGraphFile {
	//Grab and empty a reference to the output txt file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDirectory stringByAppendingPathComponent:@"logStatesEdges.xml"]];
	[@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?> \n\
     <!DOCTYPE document SYSTEM \"\" > \n \
     <Model>" writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

- (void)setupOutputcallGraphFile {
	//Grab and empty a reference to the output txt file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDirectory stringByAppendingPathComponent:@"methodCalls.txt"]];
	[@"" writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

- (void)removeOldScreenshotsDirectory {
	// Attempt to delete the file at documentsDirectory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *directory = [documentsDirectory stringByAppendingPathComponent: @"/Screenshots"];
	
	NSFileManager *fileManager= [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:directory])
		if(![fileManager removeItemAtPath:directory error:NULL])
			NSLog(@"Error: Delete folder failed %@", directory);
}

- (void)createScreenshotsDirectory {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *directory = [documentsDirectory stringByAppendingPathComponent: @"/Screenshots"];
	
	NSFileManager *fileManager= [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:directory])
		if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:NULL])
			NSLog(@"Error: Create folder failed %@", directory);
}

- (void)takeScreenshotOfState {
	
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *directory = [documentsDirectory stringByAppendingPathComponent: @"/Screenshots"];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[directory stringByAppendingPathComponent:[NSString stringWithFormat:@"S-%f-%d.jpg", [[NSDate date] timeIntervalSince1970],(self.currentEdge.targetStateID?self.currentEdge.targetStateID:0)]]];
	[UIImageJPEGRepresentation(img, 1.0) writeToFile:path atomically:NO];
}

- (void)outputStateGraphFile:(NSMutableString*)outputString {
	// Create paths to State Graph output txt file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDirectory stringByAppendingPathComponent:@"logStatesEdges.xml"]];
	freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
	NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
	[fileHandler seekToEndOfFile];
	[fileHandler writeData:[outputString dataUsingEncoding:NSUTF8StringEncoding]];
	[fileHandler closeFile];
}

- (void)outputCallGraphFile:(NSMutableString*)outputString {
	// Create paths to State Graph output txt file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDirectory stringByAppendingPathComponent:@"methodCalls.txt"]];
	freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
	NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
	[fileHandler seekToEndOfFile];
	[fileHandler writeData:[outputString dataUsingEncoding:NSUTF8StringEncoding]];
	[fileHandler closeFile];
}

#pragma mark -
#pragma mark Related Node/Edge Methods

- (void)getNextScreen:(UIEvent*)event {
    
    self.currentNode.indexNumber = self.currentIndexNumber;
    self.currentEdge.targetStateID = self.currentNode.indexNumber;
    [self.stateNodesArray addObject:self.currentNode];
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"DynamicAnalyser_isViewControllerLoaded"] isEqualToString:@"ViewControllerLoaded"]) {
        
        UIState *currentState = self.stateNodesArray.lastObject;
        UIViewController *currentViewController = currentState.viewController;
        
        UIState *thisState = [[UIState alloc] init];
        thisState.className = [NSString stringWithFormat:@"%@",currentViewController.class];
        thisState.title = currentViewController.title;
        thisState.viewController = currentViewController;
        [thisState setAllUIElementsForViewController:currentViewController];
    }
}

//http://code.google.com/p/xswi/source/browse/trunk/xswi/Classes/?r=122
- (void)writeXMLFile:(UIState*)node {
    
    self.currentNode = node;
    
    //log initial Edge
    if (self.currentEdge.touchedElement == nil) {
        self.currentEdge = [[UIEdge alloc] init];
        self.currentEdge.timeStamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        self.currentEdge.sourceStateID = 0;
        self.currentEdge.targetStateID = 1;
        self.currentEdge.touchedElement = nil;
        self.currentEdge.methodsArray = self.methodCallsArray;
        
        self.currentNode.indexNumber = self.currentEdge.targetStateID;
        [self.stateNodesArray addObject:self.currentNode];
    }
    
    [self performSelector:@selector(logPropertiesForEdge) withObject:nil afterDelay:2.0];
}

- (void)logPropertiesForEdge {
    
    self.currentEdge.methodsArray = self.methodCallsArray;
    
    [self.xmlWriter writeCharacters:@"\n\n\n"];
    
    [self.xmlWriter writeStartElement:@"Edge"];
    
    [self.xmlWriter writeStartElement:@"TimeStamp"];
    [self.xmlWriter writeCharacters:self.currentEdge.timeStamp];
    [self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"Source_State_ID"];
    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"S%d", self.currentEdge.sourceStateID]];
    [self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"Target_State_ID"];
    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"S%d", self.currentEdge.targetStateID]];
    [self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"TouchedElement"];
    
    if (self.currentEdge.touchedElement) {
    
        [self.xmlWriter writeStartElement:@"UIElement_Type"];
        [self.xmlWriter writeCharacters:self.currentEdge.touchedElement.className?self.currentEdge.touchedElement.className:@""];
        [self.xmlWriter writeEndElement];
    
        [self.xmlWriter writeStartElement:@"UIElement_Label"];
        [self.xmlWriter writeCharacters:self.currentEdge.touchedElement.label?self.currentEdge.touchedElement.label:@""];
        [self.xmlWriter writeEndElement];
    
        [self.xmlWriter writeStartElement:@"UIElement_Action"];
        [self.xmlWriter writeCharacters:self.currentEdge.touchedElement.action?self.currentEdge.touchedElement.action:@""];
        [self.xmlWriter writeEndElement];
    
        [self.xmlWriter writeStartElement:@"UIElement_Details"];
        [self.xmlWriter writeCharacters:self.currentEdge.touchedElement.details?self.currentEdge.touchedElement.details:@""];
        [self.xmlWriter writeEndElement];
    }
    
    [self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"Methods"];
    
    if ([self.methodCallsArray count]>0) {
        
        for(NSString * method in self.methodCallsArray){
            
            [self.xmlWriter writeStartElement:@"Method"];
            [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@", method]];
            [self.xmlWriter writeEndElement];
        }
        [self.methodCallsArray removeAllObjects];
    }
    [self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeEndElement];
    
    // Create paths to output txt file
    [self outputStateGraphFile:[self.xmlWriter toString]];
    
    self.xmlWriter = [[XMLWriter alloc]init];
    
    [self logPropertiesForState];
}

- (void)logPropertiesForState {
    
    [self.xmlWriter writeCharacters:@"\n\n\n"];
    
	[self.xmlWriter writeStartElement:@"State"];
    
    [self.xmlWriter writeStartElement:@"TimeStamp"];
    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
    [self.xmlWriter writeEndElement];
	
    [self.xmlWriter writeStartElement:@"State_ID"];
	[self.xmlWriter writeCharacters:self.currentEdge.targetStateID?[NSString stringWithFormat:@"S%d", self.currentEdge.targetStateID]:@""];
	[self.xmlWriter writeEndElement];
    
	[self.xmlWriter writeStartElement:@"State_ClassName"];
	[self.xmlWriter writeCharacters:self.currentNode.className?self.currentNode.className:@""];
	[self.xmlWriter writeEndElement];
	
	[self.xmlWriter writeStartElement:@"State_Title"];
	[self.xmlWriter writeCharacters:self.currentNode.title?self.currentNode.title:@""];
	[self.xmlWriter writeEndElement];
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *directory = [documentsDirectory stringByAppendingPathComponent: @"/Screenshots"];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[directory stringByAppendingPathComponent:[NSString stringWithFormat:@"S%d.jpg", self.currentEdge.targetStateID]]];
	[self.xmlWriter writeStartElement:@"State_ScreenshotPath"];
	[self.xmlWriter writeCharacters:path];
	[self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"State_NumberOfElements"];
	[self.xmlWriter writeCharacters:self.currentNode.numberOfUIElements?[NSString stringWithFormat:@"%d", self.currentNode.numberOfUIElements]:@""];
	[self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"UIElements"];
    
    for(UIElement * element in self.currentNode.uiElementsArray){
        
        [self.xmlWriter writeStartElement:@"UIElement"];
        
        [self.xmlWriter writeStartElement:@"State_ID"];
        [self.xmlWriter writeCharacters:self.currentEdge.targetStateID?[NSString stringWithFormat:@"S%d", self.currentEdge.targetStateID]:@"S0"];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"UIElement_ID"];
        [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"E%d",[self.currentNode.uiElementsArray indexOfObject:element]+1]];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"UIElement_Type"];
        [self.xmlWriter writeCharacters:element.className?element.className:@""];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"UIElement_Label"];
        [self.xmlWriter writeCharacters:element.label?element.label:@""];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"UIElement_Action"];
        [self.xmlWriter writeCharacters:element.action?element.action:@""];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"UIElement_Details"];
        [self.xmlWriter writeCharacters:element.details?element.details:@""];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeEndElement];
    }
    
    [self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeEndElement];
    
    // Create paths to output txt file
    [self outputStateGraphFile:[self.xmlWriter toString]];
    self.xmlWriter = [[XMLWriter alloc]init];
    //[self.xmlWriter writeCharacters:@"\n"];
    
    //take screenshot
    [self takeScreenshotOfState];
}

- (void)createEdge:(UIEvent*)event {

    UIEventType thisEventType = [event type];
    
    if(thisEventType == UIEventTypeTouches){
        
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
       
        if (touch.phase == UITouchPhaseBegan) {
        
            self.currentEdge = [[UIEdge alloc] init];
            self.currentEdge.timeStamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            
            UIState *currentState = self.stateNodesArray.lastObject;
            self.currentEdge.sourceStateID = currentState.indexNumber;//[self.stateNodesArray count]?[self.stateNodesArray count]:0;
            
            self.currentEdge.touchedElement = [UIElement addUIElement:touch.view];
            self.currentEdge.methodsArray = self.methodCallsArray;
            
            self.currentIndexNumber++;
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"DynamicAnalyser_isViewControllerLoaded"];
            [self performSelector:@selector(getNextScreen:) withObject:event afterDelay:2.0];
            
        }
    }
}

//- (void)identifyRequest:(NSMutableURLRequest*)request method:(NSString*)method parameters:(NSDictionary*)parameters  {
//    
//    [self.xmlWriter writeStartElement:@"State_Request"];
//    
//    [self.xmlWriter writeStartElement:@"TimeStamp"];
//    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
//    [self.xmlWriter writeEndElement];
//    
//    [self.xmlWriter writeStartElement:@"State_ID"];
//    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"S%d", self.currentIndexNumber]];
//    [self.xmlWriter writeEndElement];
//        
//    [self.xmlWriter writeStartElement:@"Request"];
//    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@", request]?[NSString stringWithFormat:@"%@", request]:@""];
//    [self.xmlWriter writeEndElement];
//        
//    [self.xmlWriter writeStartElement:@"Method"];
//    [self.xmlWriter writeCharacters:method?method:@""];
//    [self.xmlWriter writeEndElement];
//        
//    [self.xmlWriter writeStartElement:@"Parameters"];
//    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@", parameters]?[NSString stringWithFormat:@"%@",parameters]:@""];
//    [self.xmlWriter writeEndElement];
//        
//    [self.xmlWriter writeEndElement];
//            
//    // Create paths to output txt file
//    [self outputStateGraphFile:[self.xmlWriter toString]];
//            
//    self.xmlWriter = [[XMLWriter alloc]init];
//}
//
//- (void)identifyRequest:(NSURLRequest*)request {
//    
//    [self.xmlWriter writeStartElement:@"State_Request2"];
//    
//    [self.xmlWriter writeStartElement:@"TimeStamp"];
//    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
//    [self.xmlWriter writeEndElement];
//        
//    [self.xmlWriter writeStartElement:@"State_ID"];
//    [self.xmlWriter writeCharacters:[self.stateNodesArray count]?[NSString stringWithFormat:@"S%d", [self.stateNodesArray count]]:@""];
//    [self.xmlWriter writeEndElement];
//        
//    [self.xmlWriter writeStartElement:@"Request"];
//    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@", request]?[NSString stringWithFormat:@"%@", request]:@""];
//    [self.xmlWriter writeEndElement];
//        
//    [self.xmlWriter writeEndElement];
//        
//    // Create paths to output txt file
//    [self outputStateGraphFile:[self.xmlWriter toString]];
//        
//    self.xmlWriter = [[XMLWriter alloc]init];
//}

- (UIElement*)find:(UIView*)view inArray:(NSMutableArray*)uiElementsArray {
	
    for (UIElement* e in uiElementsArray)
        if (e.object == view)
            return e;
    
    return nil;
}

- (void)traceMethod:(NSString*)method {
    
    NSMutableString* outputTxt = [NSMutableString stringWithFormat:@"\n%@", method];
    
    // Create paths to output txt file
    [self outputCallGraphFile:outputTxt];
    
    //[self.xmlWriter writeStartElement:@"TouchedElement"];
    self.xmlWriter = [[XMLWriter alloc]init];
    
    [self.xmlWriter writeCharacters:@"\n"];
    [self.xmlWriter writeStartElement:@"Method"];
    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@", method]];
    [self.xmlWriter writeEndElement];
    
    // Create paths to output txt file
    [self outputStateGraphFile:[self.xmlWriter toString]];

}

- (void)traceAllClassesMethods:(NSString*)method {
    
    NSMutableString* outputTxt = [NSMutableString stringWithFormat:@"\n%@", method];
    // Create paths to output txt file
    [self outputCallGraphFile:outputTxt];
}



@end
