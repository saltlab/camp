//
//  OutputComponent.m
//
//  Created by Mona on 12-04-07. All rights reserved.
//

#import "OutputComponent.h"
#import "DCIntrospect.h"
#import "Xtrace.h"

@implementation OutputComponent

OutputComponent *sharedInstance = nil;

@synthesize xmlWriter, stateNodesArray;


- (OutputComponent*) init {
	self = [super init];
	if (self != nil) {
		// intialize variables
		self.stateNodesArray = [[NSMutableArray alloc]init];
        self.xmlWriter = [[XMLWriter alloc]init];
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
    [self setupOutputUIElementsFile];
	[self setupOutputStateGraphFile];
	[self removeOldScreenshotsDirectory];
    [self createScreenshotsDirectory];
}

#pragma mark -
#pragma mark Setup Directory Methods
- (void)setupOutputUIElementsFile {
	//Grab and empty a reference to the output txt file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDirectory stringByAppendingPathComponent:@"logUIElements.txt"]];
	[@"" writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

- (void)setupOutputStateGraphFile {
	//Grab and empty a reference to the output txt file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDirectory stringByAppendingPathComponent:@"logStates.xml"]];
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
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[directory stringByAppendingPathComponent:[NSString stringWithFormat:@"S%d.jpg", node.indexNumber]]];
	[UIImageJPEGRepresentation(img, 1.0) writeToFile:path atomically:NO];
}


#pragma mark -
#pragma mark Write Directory Methods
- (void)outputGraphFile:(NSMutableString*)outputString {
	// Create paths to Graph output txt file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDirectory stringByAppendingPathComponent:@"logGraphPath.txt"]];
	freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
	NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
	[fileHandler seekToEndOfFile];
	[fileHandler writeData:[outputString dataUsingEncoding:NSUTF8StringEncoding]];
	[fileHandler closeFile];
}

- (void)outputUIElementsFile:(NSMutableString*)outputString {
	// Create paths All UIElements to output txt file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [[NSString alloc] initWithFormat:@"%@",[documentsDirectory stringByAppendingPathComponent:@"logUIElements.txt"]];
	freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
	NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
	[fileHandler seekToEndOfFile];
	[fileHandler writeData:[outputString dataUsingEncoding:NSUTF8StringEncoding]];
	[fileHandler closeFile];
}

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
    node.indexNumber = [self.stateNodesArray count];
    [self logPropertiesForState:node];
	
    //take screenshot
    [self takeScreenshotOfState:node];
}

- (void)logPropertiesForState:(UIState*)node {
    [self.xmlWriter writeCharacters:@"\n\n\n"];
    
	[self.xmlWriter writeStartElement:@"State"];
	
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

- (void)identifyEvent:(UIEvent*)event {

    //[UIEvent xtrace];
    //NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(aSEL));
    
    UIEventType thisEventType = [event type];
    
    if(thisEventType == UIEventTypeTouches){
        
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        NSMutableString* touchDetails = [[[DCIntrospect alloc] init] logPropertiesForObject:touch.view];
    
        //if (touch == UITouchPhaseBegan)
        if ([[self.xmlWriter toString] length]>0) {
        
            [self.xmlWriter writeStartElement:@"State_TouchedView"];
        
            [self.xmlWriter writeStartElement:@"State_ID"];
            [self.xmlWriter writeCharacters:[self.stateNodesArray count]?[NSString stringWithFormat:@"S%d", [self.stateNodesArray count]]:@""];
            [self.xmlWriter writeEndElement];

            [self.xmlWriter writeStartElement:@"TouchedView_Type"];
            [self.xmlWriter writeCharacters:touch.view.class?[NSString stringWithFormat:@"%@",touch.view.class]:@""];
            [self.xmlWriter writeEndElement];
        
            [self.xmlWriter writeStartElement:@"TouchedView_Frame"];
            [self.xmlWriter writeCharacters:[NSString stringWithFormat:@"%@",NSStringFromCGRect(touch.view.frame)]?[NSString stringWithFormat:@"%@",NSStringFromCGRect(touch.view.frame)]:@""];
            [self.xmlWriter writeEndElement];
    
            [self.xmlWriter writeStartElement:@"TouchedView_Details"];
            [self.xmlWriter writeCharacters:touchDetails?touchDetails:@""];
            [self.xmlWriter writeEndElement];
    
            [self.xmlWriter writeEndElement];
    
            // Create paths to output txt file
            [self outputStateGraphFile:[self.xmlWriter toString]];
        
            self.xmlWriter = [[XMLWriter alloc]init];
        }
    }
}



@end
