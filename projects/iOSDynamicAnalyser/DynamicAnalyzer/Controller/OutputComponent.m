//
//  OutputComponent.m
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import "OutputComponent.h"
#import "DCIntrospect.h"
#import <objc/runtime.h>



typedef int (*ObjCLogProc)(BOOL, const char *, const char *, SEL);
typedef void (*logObjcMessageSends_t)(ObjCLogProc logProc);


@implementation OutputComponent

OutputComponent *sharedInstance = nil;

@synthesize xmlWriter, stateNodesArray;


- (OutputComponent*) init {
	self = [super init];
	if (self != nil) {
		// intialize variables
		self.stateNodesArray = [[NSMutableArray alloc]init];
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
    //[self setupOutputUIElementsFile];
	[self setupOutputStateGraphFile];
	[self removeOldScreenshotsDirectory];
    [self createScreenshotsDirectory];
}

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
        
        [self.xmlWriter writeStartElement:@"UIElement_Target"];
        [self.xmlWriter writeCharacters:element.target?[NSString stringWithFormat:@"%@", element.target]:@""];
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
    
    [self.xmlWriter writeCharacters:@"\n"];
}

//+ (void)writeAllStatesElements {
//    
//    DCIntrospect *dcIntrospect = [[DCIntrospect alloc] init];
//    NSArray *statesArray =[[ICrawlerController sharedICrawler] visitedStates];
//    
//    int count = 0;
//    for (State* s in statesArray) {
//        for (UIElement* e in s.uiElementsArray) {
//            count++;
//            if ([e.className isEqualToString:@"UINavigationItemButtonView"] || [e.className isEqualToString:@"UIActivityIndicatorView"])
//                [dcIntrospect logPropertiesForObject:(UIView*)e.object
//                                  withViewController:NSStringFromClass([s.selfViewController class])
//                                       andStateIndex:s.visitedStateIndex];
//            else if ([e.objectClass isKindOfClass:[NSString class]])
//                NSLog(@"Unknow element %@", e.objectClass);
//            else
//                [dcIntrospect logPropertiesForObject:e.object
//                                  withViewController:NSStringFromClass([s.selfViewController class])
//                                       andStateIndex:s.visitedStateIndex];
//        }
//    }
//    
//    NSLog(@"Total number of GUI elements %d", count);
//}



- (void)getNextScreen:(UIEvent*)event {
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"DynamicAnalyser_isViewControllerLoaded"] isEqualToString:@"ViewControllerLoaded"]) {
        
        UIState *currentState = self.stateNodesArray.lastObject;
        UIViewController *currentViewController = currentState.viewController;
        UIViewController *topViewController = currentViewController.navigationController.topViewController;
        
        UIState *thisState = [[UIState alloc] init];
        thisState.className = [NSString stringWithFormat:@"%@",self.class];
        thisState.title = currentViewController.title;
        thisState.viewController = currentViewController;
        [thisState setAllUIElementsForViewController:currentViewController];
    }
    
    //instrumentObjcMessageSends(NO);
//    UIEventType thisEventType = [event type];
//    if(thisEventType == UIEventTypeTouches){
//        
//        NSSet *touches = [event allTouches];
//        UITouch *touch = [touches anyObject];
//       if (touch.phase == UITouchPhaseBegan)
    
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


- (void)identifyEvent:(UIEvent*)event {

    UIEventType thisEventType = [event type];
    
    if(thisEventType == UIEventTypeTouches){
        
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        //CGPoint locationPoint = [touch locationInView:touch.view];
        //UIView* viewYouWishToObtain = [touch.view hitTest:locationPoint withEvent:event];
        //UIResponder
        if (touch.phase == UITouchPhaseBegan) {
            
            UIState *currentState = self.stateNodesArray.lastObject;
            UIElement * element = [self find:touch.view inArray:currentState.uiElementsArray];
            
            if (!element)
                element = [UIElement addUIElement:touch.view];
            
            
            [self.xmlWriter writeStartElement:@"TouchedElement"];
            
            [self.xmlWriter writeStartElement:@"TimeStamp"];
            [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
            [self.xmlWriter writeEndElement];
            
            [self.xmlWriter writeStartElement:@"State_ID"];
            [self.xmlWriter writeCharacters:[self.stateNodesArray count]?[NSString stringWithFormat:@"S%d", [self.stateNodesArray count]]:@""];
            [self.xmlWriter writeEndElement];
            
            [self.xmlWriter writeStartElement:@"TouchedElement_Type"];
            [self.xmlWriter writeCharacters:element.className?element.className:@""];
            [self.xmlWriter writeEndElement];
            
            [self.xmlWriter writeStartElement:@"TouchedElement_Label"];
            [self.xmlWriter writeCharacters:element.label?element.label:@""];
            [self.xmlWriter writeEndElement];
            
            [self.xmlWriter writeStartElement:@"TouchedElement_Action"];
            [self.xmlWriter writeCharacters:element.action?element.action:@""];
            [self.xmlWriter writeEndElement];
            
            [self.xmlWriter writeStartElement:@"UTouchedElement_Target"];
            [self.xmlWriter writeCharacters:element.target?[NSString stringWithFormat:@"%@", element.target]:@""];
            [self.xmlWriter writeEndElement];
            
            [self.xmlWriter writeStartElement:@"TouchedElement_Details"];
            [self.xmlWriter writeCharacters:element.details?element.details:@""];
            [self.xmlWriter writeEndElement];
            
            
//            [self.xmlWriter writeStartElement:@"State_TouchedElement"];
//            
//            [self.xmlWriter writeStartElement:@"TimeStamp"];
//            [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
//            [self.xmlWriter writeEndElement];
//        
//            [self.xmlWriter writeStartElement:@"State_ID"];
//            [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"S%d", self.currentIndexNumber]];
//            [self.xmlWriter writeEndElement];
//
//            [self.xmlWriter writeStartElement:@"TouchedElement_Type"];
//            [self.xmlWriter writeCharacters:touch.view.class?[NSString stringWithFormat:@"%@",touch.view.class]:@""];
//            [self.xmlWriter writeEndElement];
//            
//            __block NSString* thisTarget = @"";
//            __block NSString* thisAction = @"";
//            if ([touch.view respondsToSelector:@selector(allTargets)])
//            {
//                UIControl *control = (UIControl *)touch.view;
//                UIControlEvents controlEvents = [control allControlEvents];
//                NSSet *allTargets = [control allTargets];
//                [allTargets enumerateObjectsUsingBlock:^(id target, BOOL *stop)
//                 {
//                     NSArray *actions = [control actionsForTarget:target forControlEvent:controlEvents];
//                     [actions enumerateObjectsUsingBlock:^(id action, NSUInteger idx, BOOL *stop2)
//                      {
//                          thisTarget = target;
//                          thisAction = action;
//                      }];
//                 }];
//            }
//            
//            [self.xmlWriter writeStartElement:@"TouchedElement_Target"];
//            [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@",thisTarget]];
//            [self.xmlWriter writeEndElement];
//        
//            [self.xmlWriter writeStartElement:@"TouchedElement_Action"];
//            [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@",thisAction]];
//            [self.xmlWriter writeEndElement];
//            
//            [self.xmlWriter writeStartElement:@"TouchedElement_Frame"];
//            [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@",NSStringFromCGRect(touch.view.frame)]?[NSString stringWithFormat:@"%@",NSStringFromCGRect(touch.view.frame)]:@""];
//            [self.xmlWriter writeEndElement];
//    
//            [self.xmlWriter writeStartElement:@"TouchedElement_Details"];
//            [self.xmlWriter writeCharacters:touchDetails?touchDetails:@""];
//            [self.xmlWriter writeEndElement];
//    
            [self.xmlWriter writeEndElement];
    
            // Create paths to output txt file
            [self outputStateGraphFile:[self.xmlWriter toString]];
        
            self.xmlWriter = [[XMLWriter alloc]init];
            
            self.currentIndexNumber++;
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"DynamicAnalyser_isViewControllerLoaded"];
            [self performSelector:@selector(getNextScreen:) withObject:event afterDelay:2.0];
            
        }
    }
}

- (void)identifyRequest:(NSMutableURLRequest*)request method:(NSString*)method parameters:(NSDictionary*)parameters  {
    
    [self.xmlWriter writeStartElement:@"State_Request"];
    
    [self.xmlWriter writeStartElement:@"TimeStamp"];
    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
    [self.xmlWriter writeEndElement];
    
        [self.xmlWriter writeStartElement:@"State_ID"];
        [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"S%d", self.currentIndexNumber]];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"Request"];
        [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@", request]?[NSString stringWithFormat:@"%@", request]:@""];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"Method"];
        [self.xmlWriter writeCharacters:method?method:@""];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"Parameters"];
        [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@", parameters]?[NSString stringWithFormat:@"%@",parameters]:@""];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeEndElement];
            
        // Create paths to output txt file
        [self outputStateGraphFile:[self.xmlWriter toString]];
            
        self.xmlWriter = [[XMLWriter alloc]init];
    //}
}

- (void)identifyRequest:(NSURLRequest*)request {
    
    [self.xmlWriter writeStartElement:@"State_Request2"];
    
    [self.xmlWriter writeStartElement:@"TimeStamp"];
    [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
    [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"State_ID"];
        [self.xmlWriter writeCharacters:[self.stateNodesArray count]?[NSString stringWithFormat:@"S%d", [self.stateNodesArray count]]:@""];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeStartElement:@"Request"];
        [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@", request]?[NSString stringWithFormat:@"%@", request]:@""];
        [self.xmlWriter writeEndElement];
        
        [self.xmlWriter writeEndElement];
        
        // Create paths to output txt file
        [self outputStateGraphFile:[self.xmlWriter toString]];
        
        self.xmlWriter = [[XMLWriter alloc]init];
    //}
}

- (UIElement*)find:(UIView*)view inArray:(NSMutableArray*)uiElementsArray {
	
    for (UIElement* e in uiElementsArray)
        if (e.object == view)
            return e;
    
    return nil;
}



@end
