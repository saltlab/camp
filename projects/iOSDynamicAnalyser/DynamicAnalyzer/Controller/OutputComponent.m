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

typedef int (*ObjCLogProc)(BOOL, const char *, const char *, SEL);
typedef void (*logObjcMessageSends_t)(ObjCLogProc logProc);


@implementation OutputComponent

OutputComponent *sharedInstance = nil;

@synthesize xmlWriter, stateNodesArray, methodCallsArray, currentIndexNumber, currentEdge;


- (OutputComponent*) init {
	self = [super init];
	if (self != nil) {
		// intialize variables
		self.stateNodesArray = [[NSMutableArray alloc]init];
        self.methodCallsArray = [[NSMutableArray alloc]init];
        self.currentEdge = [[UIEdge alloc] init];
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

//- (void)addAOPToMethodCalls {
//	unsigned classNamesCount = 0;
//    const char** classNames = objc_copyClassNamesForImage([[[NSBundle mainBundle] executablePath] UTF8String], &classNamesCount);
//    
//    for(unsigned classIdx = 0; classIdx < classNamesCount; ++classIdx){
//        
//        NSString* className = [NSString stringWithFormat:@"%s", classNames[classIdx]];
//        
//        // No need to log iOS analyser classes
//        if (!([className isEqualToString:@"AspectInfo"] ||
//              [className isEqualToString:@"AspectsContainer"] ||
//              [className isEqualToString:@"AspectIdentifier"] ||
//              [className isEqualToString:@"AspectTracker"] ||
//              [className isEqualToString:@"OutputComponent"] ||
//              [className isEqualToString:@"XMLWriter"] ||
//              [className isEqualToString:@"UIElement"] ||
//              [className isEqualToString:@"UIState"] ||
//              [className isEqualToString:@"DCIntrospect"])) {
//            
//            [self traceAllClassesMethods:className];
//            
//            unsigned methodsCount = 0;
//            Method* methods = class_copyMethodList(objc_getClass(classNames[classIdx]), &methodsCount);
//            for(unsigned methodIdx = 0; methodIdx < methodsCount; ++methodIdx){
//                
//                [self traceAllClassesMethods:[NSString stringWithFormat:@"    %s", sel_getName(method_getName(methods[methodIdx]))]];
//                
//                [objc_getClass(classNames[classIdx]) aspect_hookSelector:method_getName(methods[methodIdx]) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info) {
//                    
//                    NSString* string = [NSString stringWithFormat:@"%@", info.instance];
//                    NSRange searchFromRange = [string rangeOfString:@"<"];
//                    NSRange searchToRange = [string rangeOfString:@" "];
//                    NSString *class1 = [string substringWithRange:NSMakeRange(searchFromRange.location+searchFromRange.length, searchToRange.location-searchFromRange.location-searchFromRange.length)];
//                    NSString* method1 = [NSStringFromSelector(info.originalInvocation.selector) stringByReplacingOccurrencesOfString:@"aspects__" withString:@""];
//                    
//                    [self.methodCallsArray addObject:[NSString stringWithFormat:@"[%@ %@]", class1, method1]];
//                    [self traceMethod:[NSString stringWithFormat:@"[%@ %@]", class1, method1]];
//                    
//                } error:NULL];
//                
//            }
//            free(methods);
//        }
//    }
//    free(classNames);
//}

#pragma mark -
#pragma mark Setup Directory Methods

- (void)setupOutputStateGraphFile {
	//Grab and empty a reference to the output txt file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDirectory stringByAppendingPathComponent:@"logStates.xml"]];
	[@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?> \n\
     <!DOCTYPE document SYSTEM \"\" > \n \
     <States>" writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
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


#pragma mark -
#pragma mark Create Directory Methods
- (void)createScreenshotsDirectory {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *directory = [documentsDirectory stringByAppendingPathComponent: @"/Screenshots"];
	
	NSFileManager *fileManager= [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:directory])
		if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:NULL])
			NSLog(@"Error: Create folder failed %@", directory);
}


#pragma mark -
#pragma mark Related Directory Methods
- (void)takeScreenshotOfState:(UIState*)node {
	
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
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[directory stringByAppendingPathComponent:[NSString stringWithFormat:@"S-%f-%d.jpg", [[NSDate date] timeIntervalSince1970],(node?node.indexNumber:0)]]];
	[UIImageJPEGRepresentation(img, 1.0) writeToFile:path atomically:NO];
}


#pragma mark -
#pragma mark Write Directory Methods

- (void)outputStateGraphFile:(NSMutableString*)outputString {
	// Create paths to State Graph output txt file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDirectory stringByAppendingPathComponent:@"logStates.xml"]];
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

//http://code.google.com/p/xswi/source/browse/trunk/xswi/Classes/?r=122
- (void)writeXMLFile:(UIState*)node {
    
    [self.stateNodesArray addObject:node];
    node.indexNumber = self.currentIndexNumber;
    //node.indexNumber = [self.stateNodesArray count];
    [self logPropertiesForState:node];
	
    //take screenshot
    [self takeScreenshotOfState:node];
}

- (void)logPropertiesForState:(UIState*)node {
    
    //log initial Edge
    if (self.currentEdge.touchedElement == nil) {
        self.currentEdge = [[UIEdge alloc] init];
        self.currentEdge.timeStamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        self.currentEdge.sourceStateID = @"S0";
        self.currentEdge.targetStateID = node.indexNumber?[NSString stringWithFormat:@"S%d", node.indexNumber]:@"";
        self.currentEdge.touchedElement = nil;
        self.currentEdge.methodsArray = self.methodCallsArray;
        //[self logPropertiesForEdge:self.currentEdge];
        [self performSelector:@selector(logPropertiesForEdge:) withObject:self.currentEdge afterDelay:2.0];
    }
    else {
        self.currentEdge.targetStateID = node.indexNumber?[NSString stringWithFormat:@"S%d", node.indexNumber]:@"";
        [self performSelector:@selector(logPropertiesForEdge:) withObject:self.currentEdge afterDelay:2.0];
    }
        
    [self.xmlWriter writeCharacters:@"\n\n\n"];

	[self.xmlWriter writeStartElement:@"State"];
    
    [self.xmlWriter writeStartElement:@"TimeStamp"];
    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
    [self.xmlWriter writeEndElement];
	
    [self.xmlWriter writeStartElement:@"State_ID"];
	[self.xmlWriter writeCharacters:node.indexNumber?[NSString stringWithFormat:@"S%d", node.indexNumber]:@""];
	[self.xmlWriter writeEndElement];
    
	[self.xmlWriter writeStartElement:@"State_ClassName"];
	[self.xmlWriter writeCharacters:node.className?node.className:@""];
	[self.xmlWriter writeEndElement];
	
	[self.xmlWriter writeStartElement:@"State_Title"];
	[self.xmlWriter writeCharacters:node.title?node.title:@""];
	[self.xmlWriter writeEndElement];
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *directory = [documentsDirectory stringByAppendingPathComponent: @"/Screenshots"];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[directory stringByAppendingPathComponent:[NSString stringWithFormat:@"S%d.jpg", node.indexNumber]]];
	[self.xmlWriter writeStartElement:@"State_ScreenshotPath"];
	[self.xmlWriter writeCharacters:path];
	[self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"State_NumberOfElements"];
	[self.xmlWriter writeCharacters:node.numberOfUIElements?[NSString stringWithFormat:@"%d", node.numberOfUIElements]:@""];
	[self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"UIElements"];
    
    for(UIElement * element in node.uiElementsArray){
        
        [self.xmlWriter writeStartElement:@"UIElement"];
        
        [self.xmlWriter writeStartElement:@"State_ID"];
        [self.xmlWriter writeCharacters:node.indexNumber?[NSString stringWithFormat:@"S%d", node.indexNumber]:@""];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"UIElement_ID"];
        [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"E%d",[node.uiElementsArray indexOfObject:element]+1]];
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
        
//        [self.xmlWriter writeStartElement:@"UIElement_Target"];
//        [self.xmlWriter writeCharacters:element.target?[NSString stringWithFormat:@"%@", element.target]:@""];
//        [self.xmlWriter writeEndElement];
        
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

}

- (void)getNextScreen:(UIEvent*)event {
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"DynamicAnalyser_isViewControllerLoaded"] isEqualToString:@"ViewControllerLoaded"]) {
        
        UIState *currentState = self.stateNodesArray.lastObject;
        UIViewController *currentViewController = currentState.viewController;
        //UIViewController *topViewController = currentViewController.navigationController.topViewController;
        
        UIState *thisState = [[UIState alloc] init];
        thisState.className = [NSString stringWithFormat:@"%@",currentViewController.class];
        thisState.title = currentViewController.title;
        thisState.viewController = currentViewController;
        [thisState setAllUIElementsForViewController:currentViewController];
    }
}

- (void)identifyCall:(NSURL*)url {

}

- (UIViewController*)initializeRootState {
	
    UIViewController *currentViewController;
	
	id mainController;
	NSObject <UIApplicationDelegate> *appDelegate = (NSObject <UIApplicationDelegate> *)[[UIApplication sharedApplication] delegate];
	Class appDelegateClass = object_getClass(appDelegate);
    Class appDelegateSuperClass = [appDelegateClass superclass];
    
	unsigned int outCount, i;
	objc_property_t *properties = class_copyPropertyList([appDelegateClass class], &outCount);
    if (!properties && appDelegateSuperClass)
        properties = class_copyPropertyList(appDelegateSuperClass, &outCount);
    
	for(i = 0; i < outCount; i++) {
		objc_property_t property = properties[i];
		const char *propName = property_getName(property);
		if(propName) {
			NSString *propertyName = [NSString stringWithUTF8String:propName];
			mainController = [appDelegate valueForKey:propertyName];
			
			if ([mainController isKindOfClass:[UINavigationController class]]) {
				//the app starts with NavigationController
				UINavigationController *newNav = (UINavigationController*)mainController;
				currentViewController = newNav.topViewController;
				break;
			}
			else if ([mainController isKindOfClass:[UITabBarController class]]) {
				//the app starts with TabBarController
				UITabBarController *thisTabBarController = (UITabBarController*)mainController;
				thisTabBarController.selectedIndex = 0;
				currentViewController = thisTabBarController;
				break;
			}
			else if ([mainController isKindOfClass:[UIViewController class]]) {
				//the app starts with a UIViewController
				UIViewController *mainViewController = [appDelegate valueForKey:propertyName];
				currentViewController = mainViewController;
				break;
			}
            //else if ([mainController isKindOfClass:[UIWindow class]]) {
            //	UIWindow *window = [appDelegate valueForKey:propertyName];
            //	UIViewController *mainViewController = window.rootViewController;
            //	self.currentViewController = mainViewController;
            //	break;
            //}
		}
	}
	
    free(properties);
    return currentViewController;
}

- (void)logPropertiesForEdge:(UIEdge*)edge {
    
    edge.methodsArray = self.methodCallsArray;
    
    [self.xmlWriter writeCharacters:@"\n\n\n"];
    
    [self.xmlWriter writeStartElement:@"Edge"];
    
    [self.xmlWriter writeStartElement:@"TimeStamp"];
    [self.xmlWriter writeCharacters:edge.timeStamp];
    [self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"Source_State_ID"];
    [self.xmlWriter writeCharacters:edge.sourceStateID];
    [self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"Target_State_ID"];
    [self.xmlWriter writeCharacters:edge.targetStateID];
    [self.xmlWriter writeEndElement];
    
    [self.xmlWriter writeStartElement:@"TouchedElement"];
    
    if (edge.touchedElement) {
    
        [self.xmlWriter writeStartElement:@"UIElement_Type"];
        [self.xmlWriter writeCharacters:edge.touchedElement.className?edge.touchedElement.className:@""];
        [self.xmlWriter writeEndElement];
    
        [self.xmlWriter writeStartElement:@"UIElement_Label"];
        [self.xmlWriter writeCharacters:edge.touchedElement.label?edge.touchedElement.label:@""];
        [self.xmlWriter writeEndElement];
    
        [self.xmlWriter writeStartElement:@"UIElement_Action"];
        [self.xmlWriter writeCharacters:edge.touchedElement.action?edge.touchedElement.action:@""];
        [self.xmlWriter writeEndElement];
    
        //        [self.xmlWriter writeStartElement:@"UIElement_Target"];
        //        [self.xmlWriter writeCharacters:edge.touchedElement.target?[NSString stringWithFormat:@"%@", edge.touchedElement.target]:@""];
        //        [self.xmlWriter writeEndElement];
    
        [self.xmlWriter writeStartElement:@"UIElement_Details"];
        [self.xmlWriter writeCharacters:edge.touchedElement.details?edge.touchedElement.details:@""];
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

}

- (void)createEdge:(UIEvent*)event {

    UIEventType thisEventType = [event type];
    
    if(thisEventType == UIEventTypeTouches){
        
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
       
        if (touch.phase == UITouchPhaseBegan) {
            
            self.currentEdge = [[UIEdge alloc] init];
            self.currentEdge.timeStamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            self.currentEdge.sourceStateID = [self.stateNodesArray count]?[NSString stringWithFormat:@"S%d", [self.stateNodesArray count]]:@"S0";
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
