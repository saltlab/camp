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
#import "NSString+Levenshtein.h"


//Heuristical Weights and Threshold
#define WEIGHT_S_CLASS 100
#define WEIGHT_S_TITLE 100
#define WEIGHT_S_COUNT_GUIS 100
#define WEIGHT_E_CLASS 50
#define WEIGHT_E_TITLE 10
#define WEIGHT_E_ENABALED 1
#define WEIGHT_E_HIDDEN 1
#define WEIGHT_E_IMAGE 1
#define WEIGHT_E_VALUE 1
#define WEIGHT_E_TARGET 10
#define WEIGHT_E_ACTION 50



@interface MasterViewController ()

@end

@implementation MasterViewController

@synthesize androidXmlData, iphoneXmlData, androidStatesCsv, androidElementsCsv, androidTouchedViewsCsv, iphoneStatesCsv, iphoneElementsCsv, iphoneTouchedViewsCsv, responseData, statusCode, jiraUrl, androidStatesAry, androidElementsAry, androidTouchedViewsAry, iphoneStatesAry, iphoneElementsAry, iphoneTouchedViewsAry;

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
    
    self.androidStatesAry = [NSMutableArray array];
    self.androidElementsAry = [NSMutableArray array];
    self.androidTouchedViewsAry = [NSMutableArray array];
    
    self.iphoneStatesAry = [NSMutableArray array];
    self.iphoneElementsAry = [NSMutableArray array];
    self.iphoneTouchedViewsAry = [NSMutableArray array];
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
    NSUInteger i=0;
    NSUInteger j=0;
    NSUInteger k=0;
    NSUInteger l=0;
    NSUInteger m=0;
    NSUInteger n=0;
    
    // Loop through all the files and process them.
    for(int u=0;u<[urls count];u++) {
        
        NSURL *filePath = [urls objectAtIndex:u];
        NSString* fileName = [filePath lastPathComponent];
        NSRange range = [fileName rangeOfString:@".xml" options:NSCaseInsensitiveSearch];
        
        //check if it is an xml file
        if (range.location != NSNotFound && range.location + range.length == [fileName length])
        {
            NSRange androidRange = [fileName rangeOfString:@"Android" options:NSCaseInsensitiveSearch];
            NSRange iphoneRange = [fileName rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch];
            
            NSArray* resultNodes = nil;
             
            //check if it is Android file
            if (androidRange.location != NSNotFound)
            {
                self.androidXmlData = [NSMutableData dataWithContentsOfURL:filePath];
                CXMLDocument* xmlParser = [[CXMLDocument alloc] initWithData:self.androidXmlData options:0 error:nil];
                
                if (self.androidXmlData) {
                    
                    [self.androidStatesCsv appendString:@"TimeStamp,State_ID,State_ClassName,State_Title,State_ScreenshotPath,State_NumberOfElements\n"];
                    resultNodes = [xmlParser nodesForXPath:@"//State" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:i];
                        [self parseStatesXMLFiles:resultElement appendTo:self.androidStatesCsv];
                        
                        i= [resultNodes indexOfObject:resultElement] + 1;
                    }
                    
                    [self.androidElementsCsv appendString:@"State_ID,UIElement_ID,UIElement_Type,UIElement_Label,UIElement_Action,UIElement_Target,UIElement_Details\n"]; //UIElement_Position
                    resultNodes = [xmlParser nodesForXPath:@"//State/UIElements/UIElement" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:j];
                        [self parseElementsXMLFiles:resultElement appendTo:self.androidElementsCsv];
                        
                        j= [resultNodes indexOfObject:resultElement] + 1;
                    }
                    
                    [self.androidTouchedViewsCsv appendString:@"TimeStamp,State_ID,TouchedElement_Type,TouchedElement_Label,TouchedElement_Action,UTouchedElement_Target,TouchedElement_Details\n"];
                    resultNodes = [xmlParser nodesForXPath:@"//TouchedElement" error:nil];
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
                    
                    [self.iphoneStatesCsv appendString:@"TimeStamp,State_ID,State_ClassName,State_Title,State_ScreenshotPath,State_NumberOfElements\n"];
                    resultNodes = [xmlParser nodesForXPath:@"//State" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:l];
                        [self parseStatesXMLFiles:resultElement appendTo:self.iphoneStatesCsv];
                        
                        l= [resultNodes indexOfObject:resultElement] + 1;
                    }
                    
                    [self.iphoneElementsCsv appendString:@"State_ID,UIElement_ID,UIElement_Type,UIElement_Label,UIElement_Action,UIElement_Target,UIElement_Details\n"]; //UIElement_Position
                    resultNodes = [xmlParser nodesForXPath:@"//State/UIElements//UIElement" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:m];
                        [self parseElementsXMLFiles:resultElement appendTo:self.iphoneElementsCsv];
                        
                        m= [resultNodes indexOfObject:resultElement] + 1;
                    }
                    
                    [self.iphoneTouchedViewsCsv appendString:@"TimeStamp,State_ID,TouchedElement_Type,TouchedElement_Label,TouchedElement_Action,UTouchedElement_Target,TouchedElement_Details\n"];
                    resultNodes = [xmlParser nodesForXPath:@"//TouchedElement" error:nil];
                    for (CXMLElement* resultElement in resultNodes) {
                        CXMLElement* resultElement = [resultNodes objectAtIndex:n];
                        [self parseTouchedViewsXMLFiles:resultElement appendTo:self.iphoneTouchedViewsCsv];
                        
                        n= [resultNodes indexOfObject:resultElement] + 1;
                    }

                    [self outputiPhoneStatesCsvFile:self.iphoneStatesCsv];
                    [self outputiPhoneElementsCsvFile:self.iphoneElementsCsv];
                    [self outputiPhoneTouchedViewsCsvFile:self.iphoneTouchedViewsCsv];
                }
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
    
    [self.summaryLabel setStringValue:[NSString stringWithFormat:@"Android (%tu States, %tu Elements, %tu TouchedElements) and iPhone(%tu States, %tu Elements, %tu TouchedElements) are saved in ../Desktop/mapping-projects/CAMPChecker/outputFiles/", i,(unsigned long)j,(unsigned long)k,(unsigned long)l,(unsigned long)m,(unsigned long)n]];
    [self.view addSubview:self.summaryLabel];
    
    [self outputInconsistencies];
    
}

- (void)parseStatesXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    //add TimeStamp
    NSArray *timeStampNodes = [resultElement elementsForName:@"TimeStamp"];
    NSString *timeStamp = [[timeStampNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [timeStamp stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add state ID
    NSArray *stateIdNodes = [resultElement elementsForName:@"State_ID"];
    NSString *stateId = [[stateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [stateId stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add class name
    NSArray *classNameNodes = [resultElement elementsForName:@"State_ClassName"];
    NSString *className = [[classNameNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [className stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add title 
    NSArray *statusNodes = [resultElement elementsForName:@"State_Title"];
    NSString *bugStatus = [[statusNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [bugStatus stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add screen shot path
    NSArray *resolutionNodes = [resultElement elementsForName:@"State_ScreenshotPath"];
    NSString *bugResolution = [[resolutionNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [bugResolution stringByReplacingOccurrencesOfString:@"," withString:@";"]]];

    //add number of elements
    NSArray *elementsNumberNodes = [resultElement elementsForName:@"State_NumberOfElements"];
    NSString *elementsNumber = [[elementsNumberNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementsNumber stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    [csvString appendString:@"\n"];
    
}

- (void)parseElementsXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    //add state ID
    NSArray *stateIdNodes = [resultElement elementsForName:@"State_ID"];
    NSString *stateId = [[stateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [stateId stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element ID
    NSArray *elementIdNodes = [resultElement elementsForName:@"UIElement_ID"];
    NSString *elementId = [[elementIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementId stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element type
    NSArray *elementTypeNodes = [resultElement elementsForName:@"UIElement_Type"];
    NSString *elementType = [[elementTypeNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementType stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element label
    NSArray *elementLabelNodes = [resultElement elementsForName:@"UIElement_Label"];
    NSString *elementLabel = [[elementLabelNodes objectAtIndex:0] stringValue];
    elementLabel = [elementLabel stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementLabel stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element action
    NSArray *elementActionNodes = [resultElement elementsForName:@"UIElement_Action"];
    NSString *elementAction = [[elementActionNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementAction stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element target
    NSArray *elementTargetNodes = [resultElement elementsForName:@"UIElement_Target"];
    NSString *elementTarget = [[elementTargetNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementTarget stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element details
    NSArray *elementDetailsNodes = [resultElement elementsForName:@"UIElement_Details"];
    NSString *elementDetails = [[elementDetailsNodes objectAtIndex:0] stringValue];
    elementDetails = [elementDetails stringByReplacingOccurrencesOfString:@"\n" withString:@"*"];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementDetails stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element position
    //NSArray *elementPositionNodes = [resultElement elementsForName:@"UIElement_Position"];
    //NSString *elementPosition = [[elementPositionNodes objectAtIndex:0] stringValue];
    //[csvString appendString:[NSString stringWithFormat:@"%@,", [elementPosition stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    [csvString appendString:@"\n"];
    
}

- (void)parseTouchedViewsXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    //add TimeStamp
    NSArray *timeStampNodes = [resultElement elementsForName:@"TimeStamp"];
    NSString *timeStamp = [[timeStampNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [timeStamp stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add state ID
    NSArray *stateIdNodes = [resultElement elementsForName:@"State_ID"];
    NSString *stateId = [[stateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [stateId stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element type
    NSArray *elementTypeNodes = [resultElement elementsForName:@"TouchedElement_Type"];
    NSString *elementType = [[elementTypeNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementType stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element label
    NSArray *elementLabelNodes = [resultElement elementsForName:@"TouchedElement_Label"];
    NSString *elementLabel = [[elementLabelNodes objectAtIndex:0] stringValue];
    elementLabel = [elementLabel stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementLabel stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element action
    NSArray *elementActionNodes = [resultElement elementsForName:@"TouchedElement_Action"];
    NSString *elementAction = [[elementActionNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementAction stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element target
    NSArray *elementTargetNodes = [resultElement elementsForName:@"UTouchedElement_Target"];
    NSString *elementTarget = [[elementTargetNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementTarget stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element details
    NSArray *elementDetailsNodes = [resultElement elementsForName:@"TouchedElement_Details"];
    NSString *elementDetails = [[elementDetailsNodes objectAtIndex:0] stringValue];
    elementDetails = [elementDetails stringByReplacingOccurrencesOfString:@"\n" withString:@"*"];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementDetails stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add element position
    //NSArray *elementPositionNodes = [resultElement elementsForName:@"TouchedView_Position"];
    //NSString *elementPosition = [[elementPositionNodes objectAtIndex:0] stringValue];
    //[csvString appendString:[NSString stringWithFormat:@"%@,", [elementPosition stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
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


- (void) outputInconsistencies{
    
    [self compareInitialStateAndTouchedElementPairs];
    [self compareStateAndTouchedElementPairs];
}


- (void) compareStateAndTouchedElementPairs{
    
    NSString *line;
    for(int i=2; i< [[self.iphoneStatesCsv componentsSeparatedByString:@"\n"] count]; i++) {
        line = [self.iphoneStatesCsv componentsSeparatedByString:@"\n"][i];
        if ([line length]>0) {
            NSArray *rows = [line componentsSeparatedByString:@","];
            NSMutableDictionary* row = [NSMutableDictionary dictionary];
            [row setObject:rows[0]?rows[0]:@"" forKey:@"TimeStamp"];
            [row setObject:rows[1]?rows[1]:@"" forKey:@"State_ID"];
            [row setObject:rows[2]?rows[2]:@"" forKey:@"State_ClassName"];
            [row setObject:rows[3]?rows[3]:@"" forKey:@"State_Title"];
            [row setObject:rows[4]?rows[4]:@"" forKey:@"State_ScreenshotPath"];
            [row setObject:rows[5]?rows[5]:@"" forKey:@"State_NumberOfElements"];
            
            //get the elements for the iphone next state
            NSMutableArray *elements = [NSMutableArray array];
            NSString *line;
            for(int i=1; i< [[self.iphoneElementsCsv componentsSeparatedByString:@"\n"] count]; i++) {
                line = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"][i];
                if ([line length]>0) {
                    NSArray *rows = [line componentsSeparatedByString:@","];
                    NSMutableDictionary* element = [NSMutableDictionary dictionary];
                    [element setObject:rows[0]?rows[0]:@"" forKey:@"State_ID"];
                    [element setObject:rows[1]?rows[1]:@"" forKey:@"UIElement_ID"];
                    [element setObject:rows[2]?rows[2]:@"" forKey:@"UIElement_Type"];
                    [element setObject:rows[3]?rows[3]:@"" forKey:@"UIElement_Label"];
                    [element setObject:rows[4]?rows[4]:@"" forKey:@"UIElement_Action"];
                    [element setObject:rows[5]?rows[5]:@"" forKey:@"UIElement_Target"];
                    [element setObject:rows[6]?rows[6]:@"" forKey:@"UIElement_Details"];
                    
                    if ([row[@"State_ID"] isEqualToString:element[@"State_ID"]])
                        [elements addObject:element];
                    else
                        break;
                }
            }
            
            [row setObject:elements forKey:@"Elements"];
            [self.iphoneStatesAry addObject:row];
        }
    }
    
    for(int i=2; i< [[self.androidStatesCsv componentsSeparatedByString:@"\n"] count]; i++) {
        line = [self.iphoneStatesCsv componentsSeparatedByString:@"\n"][i];
        if ([line length]>0) {
            NSArray *rows = [line componentsSeparatedByString:@","];
            NSMutableDictionary* row = [NSMutableDictionary dictionary];
            [row setObject:rows[0]?rows[0]:@"" forKey:@"TimeStamp"];
            [row setObject:rows[1]?rows[1]:@"" forKey:@"State_ID"];
            [row setObject:rows[2]?rows[2]:@"" forKey:@"State_ClassName"];
            [row setObject:rows[3]?rows[3]:@"" forKey:@"State_Title"];
            [row setObject:rows[4]?rows[4]:@"" forKey:@"State_ScreenshotPath"];
            [row setObject:rows[5]?rows[5]:@"" forKey:@"State_NumberOfElements"];
            
            //get the elements for the android next state
            NSMutableArray *elements = [NSMutableArray array];
            NSString *line;
            for(int i=1; i< [[self.androidElementsCsv componentsSeparatedByString:@"\n"] count]; i++) {
                line = [self.androidElementsCsv componentsSeparatedByString:@"\n"][i];
                if ([line length]>0) {
                    NSArray *rows = [line componentsSeparatedByString:@","];
                    NSMutableDictionary* element = [NSMutableDictionary dictionary];
                    [element setObject:rows[0]?rows[0]:@"" forKey:@"State_ID"];
                    [element setObject:rows[1]?rows[1]:@"" forKey:@"UIElement_ID"];
                    [element setObject:rows[2]?rows[2]:@"" forKey:@"UIElement_Type"];
                    [element setObject:rows[3]?rows[3]:@"" forKey:@"UIElement_Label"];
                    [element setObject:rows[4]?rows[4]:@"" forKey:@"UIElement_Action"];
                    [element setObject:rows[5]?rows[5]:@"" forKey:@"UIElement_Target"];
                    [element setObject:rows[6]?rows[6]:@"" forKey:@"UIElement_Details"];
                    
                    if ([row[@"State_ID"] isEqualToString:element[@"State_ID"]])
                        [elements addObject:element];
                    else
                        break;
                }
            }
            
            [row setObject:elements forKey:@"Elements"];
            [self.androidStatesAry addObject:row];
        }
    }
    
    if ([self.iphoneStatesAry count] == [self.androidStatesAry count]){
        for (int i=0; i <[self.iphoneStatesAry count]; i++ ){
            
            NSUInteger r1 = [self.iphoneStatesAry[i][@"State_ClassName"] levenshteinDistanceToString:self.androidStatesAry[i][@"State_ClassName"]];
            float r2 = [self.iphoneStatesAry[i][@"State_Title"] compareWithWord:self.androidStatesAry[i][@"State_Title"]];
            
            
        }
    }
    
}


- (void) compareInitialStateAndTouchedElementPairs{
    
    //get the iphone initial state
    NSString *firstLine = [self.iphoneStatesCsv componentsSeparatedByString:@"\n"][1];
    if ([firstLine length]>0) {
        NSArray *rows = [firstLine componentsSeparatedByString:@","];
        NSMutableDictionary* iphoneState = [NSMutableDictionary dictionary];
        [iphoneState setObject:rows[0]?rows[0]:@"" forKey:@"TimeStamp"];
        [iphoneState setObject:rows[1]?rows[1]:@"" forKey:@"State_ID"];
        [iphoneState setObject:rows[2]?rows[2]:@"" forKey:@"State_ClassName"];
        [iphoneState setObject:rows[3]?rows[3]:@"" forKey:@"State_Title"];
        [iphoneState setObject:rows[4]?rows[4]:@"" forKey:@"State_ScreenshotPath"];
        [iphoneState setObject:rows[5]?rows[5]:@"" forKey:@"State_NumberOfElements"];
        
        //get the elements for the iphone initial state
        NSMutableArray *elements = [NSMutableArray array];
        NSString *line;
        for(int i=1; i< [[self.iphoneElementsCsv componentsSeparatedByString:@"\n"] count]; i++) {
            line = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"][i];
            if ([line length]>0) {
                NSArray *rows = [line componentsSeparatedByString:@","];
                NSMutableDictionary* element = [NSMutableDictionary dictionary];
                [element setObject:rows[0]?rows[0]:@"" forKey:@"State_ID"];
                [element setObject:rows[1]?rows[1]:@"" forKey:@"UIElement_ID"];
                [element setObject:rows[2]?rows[2]:@"" forKey:@"UIElement_Type"];
                [element setObject:rows[3]?rows[3]:@"" forKey:@"UIElement_Label"];
                [element setObject:rows[4]?rows[4]:@"" forKey:@"UIElement_Action"];
                [element setObject:rows[5]?rows[5]:@"" forKey:@"UIElement_Target"];
                [element setObject:rows[6]?rows[6]:@"" forKey:@"UIElement_Details"];
                
                if ([iphoneState[@"State_ID"] isEqualToString:element[@"State_ID"]])
                    [elements addObject:element];
                else
                    break;
            }
        }
        
        [iphoneState setObject:elements forKey:@"Elements"];
        [self.iphoneStatesAry addObject:iphoneState];
    }
    
    //get the android initial state
    firstLine = [self.androidStatesCsv componentsSeparatedByString:@"\n"][1];
    if ([firstLine length]>0) {
        NSArray* rows = [firstLine componentsSeparatedByString:@","];
        NSMutableDictionary* androidState = [NSMutableDictionary dictionary];
        [androidState setObject:rows[0]?rows[0]:@"" forKey:@"TimeStamp"];
        [androidState setObject:rows[1]?rows[1]:@"" forKey:@"State_ID"];
        [androidState setObject:rows[2]?rows[2]:@"" forKey:@"State_ClassName"];
        [androidState setObject:rows[3]?rows[3]:@"" forKey:@"State_Title"];
        [androidState setObject:rows[4]?rows[4]:@"" forKey:@"State_ScreenshotPath"];
        [androidState setObject:rows[5]?rows[5]:@"" forKey:@"State_NumberOfElements"];
    
        //get the elements for the android initial state
        NSMutableArray *elements = [NSMutableArray array];
        NSString *line;
        for(int i=1; i< [[self.androidElementsCsv componentsSeparatedByString:@"\n"] count]; i++) {
            line = [self.androidElementsCsv componentsSeparatedByString:@"\n"][i];
            if ([line length]>0) {
                NSArray *rows = [line componentsSeparatedByString:@","];
                NSMutableDictionary* element = [NSMutableDictionary dictionary];
                [element setObject:rows[0]?rows[0]:@"" forKey:@"State_ID"];
                [element setObject:rows[1]?rows[1]:@"" forKey:@"UIElement_ID"];
                [element setObject:rows[2]?rows[2]:@"" forKey:@"UIElement_Type"];
                [element setObject:rows[3]?rows[3]:@"" forKey:@"UIElement_Label"];
                [element setObject:rows[4]?rows[4]:@"" forKey:@"UIElement_Action"];
                [element setObject:rows[5]?rows[5]:@"" forKey:@"UIElement_Target"];
                [element setObject:rows[6]?rows[6]:@"" forKey:@"UIElement_Details"];
                
                if ([androidState[@"State_ID"] isEqualToString:element[@"State_ID"]])
                    [elements addObject:element];
                else
                    break;
            }
        }
        
        [androidState setObject:elements forKey:@"Elements"];
        [self.androidStatesAry addObject:androidState];
    }
    
    
    float similarity = [self calculateStatePairsSimilarityS1:[self.iphoneStatesAry objectAtIndex:0] withS2:[self.androidStatesAry objectAtIndex:0]];
    NSLog(@"Need to update %f", similarity);
    
}

- (float) calculateStatePairsSimilarityS1:(NSMutableDictionary*)iphoneState withS2:(NSMutableDictionary*)androidState{
    
    float classSimilarity = [iphoneState[@"State_ClassName"] compareWithWord:androidState[@"State_ClassName"]];
    float titleSimilarity = [iphoneState[@"State_Title"] compareWithWord:androidState[@"State_Title"]];
    
    float similarity = WEIGHT_S_CLASS*classSimilarity + WEIGHT_S_TITLE*titleSimilarity +
    WEIGHT_S_COUNT_GUIS*(([iphoneState[@"State_NumberOfElements"] isEqualToString:androidState[@"State_NumberOfElements"]]) ? 1 : 0) +
    [self calculateElementsPairsSimilarityE1:iphoneState[@"Elements"] withE2:androidState[@"Elements"]];
    
    return similarity;
}

- (float) calculateElementsPairsSimilarityE1:(NSMutableArray*)iphoneElements withE2:(NSMutableArray*)androidElements{
    
    float similarity = 0;
    float maxSimilarity = 0;
    float totalSimilarity = 0;
    NSMutableDictionary* correspondentElement;
    
    for (NSMutableDictionary* element1 in iphoneElements) {
    
        for (NSMutableDictionary* element2 in androidElements) {
        
            float targetSimilarity = [element1[@"UIElement_Target"] compareWithWord:element2[@"UIElement_Target"]];
            float actionSimilarity = [element1[@"UIElement_Action"] compareWithWord:element2[@"UIElement_Action"]];
            float labelSimilarity = [element1[@"UIElement_Label"] compareWithWord:element2[@"UIElement_Label"]];
            float typeSimilarity = [self mappedE1:element1[@"UIElement_Type"] withE2:element2[@"UIElement_Type"]];
            
            similarity = WEIGHT_E_TITLE*labelSimilarity + WEIGHT_E_TARGET*targetSimilarity + WEIGHT_E_ACTION*actionSimilarity + WEIGHT_E_CLASS*typeSimilarity;
            if (similarity > maxSimilarity) {
                maxSimilarity = similarity;
                correspondentElement = element2;
            }
        }
        //element1 ~ correspondentElement
        totalSimilarity++;
    }

    return totalSimilarity/[iphoneElements count];
}
    
//- (NSMutableDictionary*) findCorrespondentAndroidElementTo:(NSMutableDictionary*)iphoneElement inElements:(NSMutableArray*)androidElements{
//    
//    float maxSimilarity = 0;
//    float similarity = 0;
//    NSMutableDictionary* correspondentElement;// = [NSMutableDictionary dictionary];
//    
//    for (NSMutableDictionary* element in androidElements) {
//        similarity = [self mappedE1:iphoneElement[@"UIElement_Type"] withE2:element[@"UIElement_Type"]];
//        if (similarity > maxSimilarity) {
//            maxSimilarity = similarity;
//            correspondentElement = element;
//        }
//    }
//    
//    return correspondentElement;
//}

- (float) mappedE1:(NSString*)iphoneElement withE2:(NSString*)androidElement{
    
    float similarity = 0;
    
    //string contains sub-string
    if (([iphoneElement rangeOfString:@"UIImageView"].location != NSNotFound) &&
        ([androidElement rangeOfString:@"ImageView"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIButton"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Button"].location != NSNotFound))
        similarity = 1;
        
    else if (([iphoneElement rangeOfString:@"UIButton"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"CheckBox"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIButton"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"CheckBox"].location != NSNotFound))
        similarity = 1;
   
    else if (([iphoneElement rangeOfString:@"UISwitch"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Switch"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UILable"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"TextView"].location != NSNotFound))
        similarity = 1;
   
    else if (([iphoneElement rangeOfString:@"UITextView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"EditText"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UITextField"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"EditText"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UITableView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"ListView"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIPickerView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Spinner"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIPickerView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Picker"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIDatePicker"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Picker"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIProgressView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"ProgressBar"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UISlider"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"SeekBar"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UISlider"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"RatingBar"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UICollectionView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"GridView"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIScrollView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"ScrollView"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UICollectionView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"GridView"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UISearchBar"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"SearchView"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIWebView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Webview"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIAlertView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"AlertDialog"].location != NSNotFound))
        similarity = 1;
   
    else if (([iphoneElement rangeOfString:@"UIAlertView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Toast"].location != NSNotFound))
        similarity = 1;
   
    else if (([iphoneElement rangeOfString:@"UIPageControl"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"ViewPager"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIPageControl"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"tab"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UITabBar"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Tab"].location != NSNotFound))
        similarity = 1;
    //Customized
    else if (([iphoneElement rangeOfString:@"UITabBar"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Button"].location != NSNotFound))
        similarity = 1;
    //Customized
    else if (([iphoneElement rangeOfString:@"UISegmentedControl"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Button"].location != NSNotFound))
        similarity = 1;
    //Customized
    else if (([iphoneElement rangeOfString:@"UIToolBar"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Button"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIToolBar"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Tab"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIActionSheet"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"ActionBar"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIActionSheet"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Spinner"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIStepper"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Button"].location != NSNotFound))
        similarity = 1;
   
    else if (([iphoneElement rangeOfString:@"UIMenuController"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"PopupMenu"].location != NSNotFound))
        similarity = 1;
    

    return similarity;
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
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidTouchedElements.csv"]];
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
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneTouchedElements.csv"]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //[fileHandler seekToEndOfFile];
    [fileHandler writeData:[csvString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

@end







