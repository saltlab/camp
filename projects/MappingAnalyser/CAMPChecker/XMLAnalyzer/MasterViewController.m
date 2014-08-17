//
//  MasterViewController.m
//  XMLAnalyzer
//
//  Created by Mona Erfani on 2013-06-24.
//  Copyright (c) 2013 Mona Erfani. All rights reserved.
//

#import "MasterViewController.h"
#import "XMLLoader.h"
#import "TouchXML.h"
#import "XMLWriter.h"
#import "TFHpple.h"

#define QM 0

@interface MasterViewController ()

@end

@implementation MasterViewController

@synthesize androidXmlData, iphoneXmlData, androidStatesCsv, androidElementsCsv, androidTouchedViewsCsv, iphoneStatesCsv, iphoneElementsCsv, iphoneTouchedViewsCsv, responseData, statusCode, jiraUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
    //Start from bottom left corner
    self.instructionLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(40, 270, 400, 40)];
    [self.instructionLabel setStringValue:@"Choose XML files for the iPhone and Android app-pairs to map!"];
    [self.instructionLabel setBezeled:NO];
    [self.instructionLabel setDrawsBackground:NO];
    [self.instructionLabel setEditable:NO];
    [self.instructionLabel setSelectable:NO];
    [self.view addSubview:self.instructionLabel];
    
    self.myButton = [[NSButton alloc] initWithFrame:NSMakeRect(40, 220, 250, 40)];
    [self.view addSubview: self.myButton];
    [self.myButton setTitle: @"Upload Android and iPhone XML"];
    [self.myButton setButtonType:NSMomentaryLightButton];
    [self.myButton setBezelStyle:NSRoundedBezelStyle];
    [self.myButton setTarget:self];
    [self.myButton setAction:@selector(selectFile)];
    
    self.summaryLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(40, 100, 400, 50)];
    [self.summaryLabel setBezeled:NO];
    [self.summaryLabel setDrawsBackground:NO];
    [self.summaryLabel setEditable:NO];
    [self.summaryLabel setSelectable:NO];
    
    self.androidStatesCsv = [[NSMutableString alloc] init];
    self.androidElementsCsv = [[NSMutableString alloc] init];
    self.androidTouchedViewsCsv = [[NSMutableString alloc] init];
    
    self.iphoneStatesCsv = [[NSMutableString alloc] init];
    self.iphoneElementsCsv = [[NSMutableString alloc] init];
    self.iphoneTouchedViewsCsv = [[NSMutableString alloc] init];
}

- (void)selectFile
{
    //create the File Open Dialog class
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    //enable the selection of files in the dialog
    [openDlg setCanChooseFiles:YES];
    //enable the selection of directories in the dialog
    [openDlg setCanChooseDirectories:YES];
    //multiple files allowed
    [openDlg setAllowsMultipleSelection:YES];

    //display the dialog.  If the OK button was pressed, process the files
    if ([openDlg runModal] == NSOKButton)
    {
        //get an array containing the full filenames of all files and directories selected
        [self xmlSplit:[openDlg URLs]];
    }
}

-(void) xmlSplit:(NSArray*)urls
{
    // Loop through all the files and process them.
    for(int i=0;i<[urls count];i++) {
        
        NSURL *filePath = [urls objectAtIndex:i];
        NSString* fileName = [filePath lastPathComponent];
        NSRange range = [fileName rangeOfString:@".xml" options:NSCaseInsensitiveSearch];
        
        //check if it is an xml file
        if (range.location != NSNotFound && range.location + range.length == [fileName length])
        {
            NSRange androidRange = [fileName rangeOfString:@"Android" options:NSCaseInsensitiveSearch];
            NSRange iphoneRange = [fileName rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch];
            
            NSArray* resultNodes = nil;
            NSUInteger i=0;
            NSUInteger j=0;
            NSUInteger k=0;
            NSUInteger l=0;
            NSUInteger m=0;
            NSUInteger n=0;
            
            //check if it is related to Android
            if (androidRange.location != NSNotFound)
            {
                self.androidXmlData = [NSMutableData dataWithContentsOfURL:filePath];
                CXMLDocument* xmlParser = [[CXMLDocument alloc] initWithData:self.androidXmlData options:0 error:nil];
                
                if (self.androidXmlData) {
                    
                    [self.androidStatesCsv appendString:@"State_ID, State_ClassName, State_Title, State_ScreenshotPath, State_NumberOfElements \n"];
                    resultNodes = [xmlParser nodesForXPath:@"//State" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:i];
                        [self parseStatesXMLFiles:resultElement appendTo:self.androidStatesCsv];
                        
                        i= [resultNodes indexOfObject:resultElement] + 1;
                    }
                    
                    [self.androidElementsCsv appendString:@"State_ID, UIElement_ID, UIElement_Type, UIElement_Label, UIElement_Action, UIElement_Target, UIElement_Details \n"]; //UIElement_Position
                    resultNodes = [xmlParser nodesForXPath:@"//State/UIElements/UIElement" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:j];
                        [self parseElementsXMLFiles:resultElement appendTo:self.androidElementsCsv];
                        
                        j= [resultNodes indexOfObject:resultElement] + 1;
                    }
                    
                    [self.androidTouchedViewsCsv appendString:@"State_ID, TouchedView_Type, TouchedView_Frame, TouchedView_Details \n"];
                    resultNodes = [xmlParser nodesForXPath:@"//State_TouchedView" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:k];
                        [self parseTouchedViewsXMLFiles:resultElement appendTo:self.androidTouchedViewsCsv];
                        
                        k= [resultNodes indexOfObject:resultElement] + 1;
                    }
                    
                    [self outputAndroidStatesCsvFile:self.androidStatesCsv];
                    [self outputAndroidElementsCsvFile:self.androidElementsCsv];
                    [self outputAndroidTouchedViewsCsvFile:self.androidTouchedViewsCsv];
                }
            }
            //check if it is iPhone file
            else if (iphoneRange.location != NSNotFound)
            {
                self.iphoneXmlData = [NSMutableData dataWithContentsOfURL:filePath];
                CXMLDocument* xmlParser = [[CXMLDocument alloc] initWithData:self.androidXmlData options:0 error:nil];
                
                if (self.iphoneXmlData) {
                    
                    [self.iphoneStatesCsv appendString:@"State_ID, State_ClassName, State_Title, State_ScreenshotPath, State_NumberOfElements \n"];
                    resultNodes = [xmlParser nodesForXPath:@"//State" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:l];
                        [self parseStatesXMLFiles:resultElement appendTo:self.iphoneStatesCsv];
                        
                        l= [resultNodes indexOfObject:resultElement] + 1;
                    }
                    
                    [self.iphoneElementsCsv appendString:@"State_ID, UIElement_ID, UIElement_Type, UIElement_Label, UIElement_Action, UIElement_Target, UIElement_Details \n"]; //UIElement_Position
                    resultNodes = [xmlParser nodesForXPath:@"//State/UIElements//UIElement" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:m];
                        [self parseElementsXMLFiles:resultElement appendTo:self.iphoneElementsCsv];
                        
                        m= [resultNodes indexOfObject:resultElement] + 1;
                    }
                    
                    [self.iphoneTouchedViewsCsv appendString:@"State_ID, TouchedView_Type, TouchedView_Frame, TouchedView_Details \n"];
                    resultNodes = [xmlParser nodesForXPath:@"//State_TouchedView" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:n];
                        [self parseTouchedViewsXMLFiles:resultElement appendTo:self.iphoneTouchedViewsCsv];
                        
                        n= [resultNodes indexOfObject:resultElement] + 1;
                    }

                    [self outputiPhoneStatesCsvFile:self.iphoneStatesCsv];
                    [self outputiPhoneElementsCsvFile:self.iphoneElementsCsv];
                    [self outputiPhoneTouchedViewsCsvFile:self.iphoneTouchedViewsCsv];
                }
                
                //[self.summaryLabel setStringValue:[NSString stringWithFormat:@"Android (%i States, %j Elements, %k TouchedViews) and iPhone(%l States, %m Elements, %n TouchedViews) are saved in ../Desktop/mapping-projects/CAMPChecker/outputFiles/", i,(unsigned long)j,(unsigned long)k,(unsigned long)l,(unsigned long)m,(unsigned long)n]];
                //[self.view addSubview:self.summaryLabel];
                
            }
            else
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:[NSString stringWithFormat:@"%@ XML file is not defined. Please select iPhone/Android XML file.", fileName]];
                [alert runModal];
            }
        }
        else
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:[NSString stringWithFormat:@"%@ is not an XML file. Please select an XML file.", fileName]];
            [alert runModal];
        }
    }
}

- (void)parseStatesXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    //add state ID
    NSArray *stateIdNodes = [resultElement elementsForName:@"State_ID"];
    NSString *stateId = [[stateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", stateId]];
    
    //add class name
    NSArray *classNameNodes = [resultElement elementsForName:@"State_ClassName"];
    NSString *className = [[classNameNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", className]];
    
    //add title 
    NSArray *statusNodes = [resultElement elementsForName:@"State_Title"];
    NSString *bugStatus = [[statusNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", bugStatus]];
    
    //add screen shot path
    NSArray *resolutionNodes = [resultElement elementsForName:@"State_ScreenshotPath"];
    NSString *bugResolution = [[resolutionNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", bugResolution]];

    //add number of elements
    NSArray *elementsNumberNodes = [resultElement elementsForName:@"State_NumberOfElements"];
    NSString *elementsNumber = [[elementsNumberNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", elementsNumber]];
    
    [csvString appendString:@"\n"];
    
}

- (void)parseElementsXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    //add state ID
    NSArray *stateIdNodes = [resultElement elementsForName:@"State_ID"];
    NSString *stateId = [[stateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", stateId]];
    
    //add element ID
    NSArray *elementIdNodes = [resultElement elementsForName:@"UIElement_ID"];
    NSString *elementId = [[elementIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", elementId]];
    
    //add element type
    NSArray *elementTypeNodes = [resultElement elementsForName:@"UIElement_Type"];
    NSString *elementType = [[elementTypeNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", elementType]];
    
    //add element label
    NSArray *elementLabelNodes = [resultElement elementsForName:@"UIElement_Label"];
    NSString *elementLabel = [[elementLabelNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", elementLabel]];
    
    //add element action
    NSArray *elementActionNodes = [resultElement elementsForName:@"UIElement_Action"];
    NSString *elementAction = [[elementActionNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", elementAction]];
    
    //add element target
    NSArray *elementTargetNodes = [resultElement elementsForName:@"UIElement_Target"];
    NSString *elementTarget = [[elementTargetNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", elementTarget]];
    
    //add element details
    NSArray *elementDetailsNodes = [resultElement elementsForName:@"UIElement_Details"];
    NSString *elementDetails = [[elementDetailsNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", elementDetails]];
    
    //add element position
    //NSArray *elementPositionNodes = [resultElement elementsForName:@"UIElement_Position"];
    //NSString *elementPosition = [[elementPositionNodes objectAtIndex:0] stringValue];
    //[csvString appendString:[NSString stringWithFormat:@"%@,", elementPosition]];
    
    [csvString appendString:@"\n"];
    
}

- (void)parseTouchedViewsXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    //add state ID
    NSArray *stateIdNodes = [resultElement elementsForName:@"State_ID"];
    NSString *stateId = [[stateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", stateId]];
    
    //add element type
    NSArray *elementIdNodes = [resultElement elementsForName:@"TouchedView_Type"];
    NSString *elementId = [[elementIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", elementId]];
    
    //add element frame
    NSArray *elementTypeNodes = [resultElement elementsForName:@"TouchedView_Frame"];
    NSString *elementType = [[elementTypeNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@, ", elementType]];
    
    //add element details
    NSArray *elementDetailsNodes = [resultElement elementsForName:@"TouchedView_Details"];
    NSString *elementDetails = [[elementDetailsNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", elementDetails]];
    
    //add element position
    //NSArray *elementPositionNodes = [resultElement elementsForName:@"TouchedView_Position"];
    //NSString *elementPosition = [[elementPositionNodes objectAtIndex:0] stringValue];
    //[csvString appendString:[NSString stringWithFormat:@"%@,", elementPosition]];
    
    [csvString appendString:@"\n"];
    
}

-(NSString*) getStringForTFHppleElement:(TFHppleElement *)element
{
    
    NSMutableString *result = [NSMutableString new];
    
    // Iterate recursively through all children
    for (TFHppleElement *child in [element children])
        [result appendString:[self getStringForTFHppleElement:child]];
    
    // Hpple creates a <text> node when it parses texts
    if ([element.tagName isEqualToString:@"text"])
        [result appendString:element.content];
    
    return result;
}


- (NSString*)getLibraryCachesDirectory
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = searchPaths[0];
    return cachesPath;
}

- (void)createXMLFilesDirectory:(NSString*)name
{
    NSString *directory = [@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles" stringByAppendingPathComponent: [NSString stringWithFormat:@"/%@XMLFiles", name]];
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:directory]) {
        if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:NULL]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Create folder failed. Please check the directory."];
            [alert runModal];
        }
    }
}

- (void) writeXMLFile:(CXMLElement*)resultElement withIndex:(NSUInteger)i
{
    XMLWriter* xmlWriter = [[XMLWriter alloc]init];
    [xmlWriter writeStartDocumentWithEncodingAndVersion:@"UTF-8" version:@"1.0"];
    NSMutableString *theMutableCopy = [[resultElement XMLString] mutableCopy];
    [theMutableCopy replaceOccurrencesOfString:@" & " withString:@" &amp; " options:0 range:NSMakeRange(0, [theMutableCopy length])];
    [xmlWriter write:theMutableCopy];
    // Create paths to output txt file
    [self outputXMLFile:[xmlWriter toString] withIndex:i];
}

- (void)outputXMLFile:(NSMutableString *)outputString withIndex:(NSUInteger)i 
{
    NSString *directory = [@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles" stringByAppendingPathComponent: [NSString stringWithFormat:@"/%@XMLFiles", @"Android"]];
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[directory stringByAppendingPathComponent:[NSString stringWithFormat:@"xmlFile_%ld.xml", (unsigned long)i]]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //[fileHandler seekToEndOfFile];
    [fileHandler writeData:[outputString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

- (void)outputAndroidStatesCsvFile:(NSMutableString*)csvString
{
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidStates.csv"]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //[fileHandler seekToEndOfFile];
    [fileHandler writeData:[csvString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

- (void)outputAndroidElementsCsvFile:(NSMutableString*)csvString
{
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidElements.csv"]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //[fileHandler seekToEndOfFile];
    [fileHandler writeData:[csvString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

- (void)outputAndroidTouchedViewsCsvFile:(NSMutableString*)csvString
{
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidTouchedViews.csv"]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //[fileHandler seekToEndOfFile];
    [fileHandler writeData:[csvString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

- (void)outputiPhoneStatesCsvFile:(NSMutableString*)csvString
{
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneStates.csv"]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //[fileHandler seekToEndOfFile];
    [fileHandler writeData:[csvString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

- (void)outputiPhoneElementsCsvFile:(NSMutableString*)csvString
{
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneElements.csv"]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //[fileHandler seekToEndOfFile];
    [fileHandler writeData:[csvString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

- (void)outputiPhoneTouchedViewsCsvFile:(NSMutableString*)csvString
{
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneTouchedViews.csv"]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //[fileHandler seekToEndOfFile];
    [fileHandler writeData:[csvString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

@end







