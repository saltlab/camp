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
#define WEIGHT_E_ACTION 50

@implementation MasterViewController

@synthesize androidXmlData, iphoneXmlData, androidStatesCsv, androidElementsCsv, androidEdgesCsv, iphoneStatesCsv, iphoneElementsCsv, iphoneEdgesCsv, responseData, statusCode, jiraUrl, androidStatesAry, androidElementsAry, androidTouchedViewsAry, iphoneStatesAry, iphoneElementsAry, iphoneTouchedViewsAry;

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
    self.androidEdgesCsv = [[NSMutableString alloc] init];
    
    self.iphoneStatesCsv = [[NSMutableString alloc] init];
    self.iphoneElementsCsv = [[NSMutableString alloc] init];
    self.iphoneEdgesCsv = [[NSMutableString alloc] init];
    
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

-(void)xmlSplit:(NSArray*)urls
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
                
                if (xmlParser) {
                    
                    [self.androidStatesCsv appendString:@"TimeStamp,State_ID,State_ClassName,State_Title,State_ScreenshotPath,State_NumberOfElements\n"];
                    resultNodes = [xmlParser nodesForXPath:@"//State" error:nil];
                    i = resultNodes.count;
                    for (CXMLElement* resultElement in resultNodes)
                        [self parseStatesXMLFiles:resultElement appendTo:self.androidStatesCsv];
                        
                    [self.androidElementsCsv appendString:@"State_ID,UIElement_ID,UIElement_Type,UIElement_Label,UIElement_Action,UIElement_Details\n"];
                    resultNodes = [xmlParser nodesForXPath:@"//State/UIElements/UIElement" error:nil];
                    j = resultNodes.count;
                    for (CXMLElement* resultElement in resultNodes)
                        [self parseElementsXMLFiles:resultElement appendTo:self.androidElementsCsv];
                    
                    [self.androidEdgesCsv appendString:@"TimeStamp,Source_State_ID,Target_State_ID,TouchedElement_Type,TouchedElement_Label,TouchedElement_Action,TouchedElement_Details,Methods\n"];
                    resultNodes = [xmlParser nodesForXPath:@"//Edge" error:nil];
                    k = resultNodes.count;
                    for (CXMLElement* resultElement in resultNodes)
                        [self parseTouchedViewsXMLFiles:resultElement appendTo:self.androidEdgesCsv];
                    
                    [self trimAndroidStatesEdges];
                    [self outputAndroidCsvFiles];
                }
            }
            //check if it is iPhone file
            else if (iphoneRange.location != NSNotFound)
            {
                self.iphoneXmlData = [NSMutableData dataWithContentsOfURL:filePath];
                CXMLDocument* xmlParser = [[CXMLDocument alloc] initWithData:self.iphoneXmlData options:0 error:nil];
                
                if (xmlParser) {
                    
                    [self.iphoneStatesCsv appendString:@"TimeStamp,State_ID,State_ClassName,State_Title,State_ScreenshotPath,State_NumberOfElements\n"];
                    resultNodes = [xmlParser nodesForXPath:@"//State" error:nil];
                    l = resultNodes.count;
                    for (CXMLElement* resultElement in resultNodes)
                        [self parseStatesXMLFiles:resultElement appendTo:self.iphoneStatesCsv];
                    
                    [self.iphoneElementsCsv appendString:@"State_ID,UIElement_ID,UIElement_Type,UIElement_Label,UIElement_Action,UIElement_Details\n"];
                    resultNodes = [xmlParser nodesForXPath:@"//State/UIElements//UIElement" error:nil];
                    m = resultNodes.count;
                    for (CXMLElement* resultElement in resultNodes)
                        [self parseElementsXMLFiles:resultElement appendTo:self.iphoneElementsCsv];
                    
                    [self.iphoneEdgesCsv appendString:@"TimeStamp,Source_State_ID,Target_State_ID,TouchedElement_Type,TouchedElement_Label,TouchedElement_Action,TouchedElement_Details,Methods\n"];
                    resultNodes = [xmlParser nodesForXPath:@"//Edge" error:nil];
                    n = resultNodes.count;
                    for (CXMLElement* resultElement in resultNodes)
                        [self parseTouchedViewsXMLFiles:resultElement appendTo:self.iphoneEdgesCsv];
                    
                    [self trimiPhoneStatesEdges];
                    [self outputiPhoneCsvFile];
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
    
    float similarity = [self outputInconsistencies];
    [self.summaryLabel setStringValue:[NSString stringWithFormat:@"Android (%tu States, %tu Elements, %tu Edges) and iPhone(%tu States, %tu Elements, %tu Edges) with similarity of %tu are saved in ../Desktop/mapping-projects/CAMPChecker/outputFiles/", i,(unsigned long)j,(unsigned long)k,(unsigned long)l,(unsigned long)m,(unsigned long)n, similarity]];
    [self.view addSubview:self.summaryLabel];
}

-(void)parseStatesXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString
{
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

-(void)parseElementsXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
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
    
    //add element details
    NSArray *elementDetailsNodes = [resultElement elementsForName:@"UIElement_Details"];
    NSString *elementDetails = [[elementDetailsNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [elementDetails stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    [csvString appendString:@"\n"];
}

-(void)parseTouchedViewsXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    //add TimeStamp
    NSArray *timeStampNodes = [resultElement elementsForName:@"TimeStamp"];
    NSString *timeStamp = [[timeStampNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [timeStamp stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add Source State ID
    NSArray *srcStateIdNodes = [resultElement elementsForName:@"Source_State_ID"];
    NSString *srcStateId = [[srcStateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [srcStateId stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    //add Target State ID
    NSArray *trgStateIdNodes = [resultElement elementsForName:@"Target_State_ID"];
    NSString *trgStateId = [[trgStateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", [trgStateId stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    
    NSArray* resultNodes = [resultElement elementsForName:@"TouchedElement"];
    CXMLElement* resultUIElement = resultNodes[0];
    
    if ([resultUIElement.children count]>0){
        //add element type
        NSArray *elementTypeNodes = [resultUIElement elementsForName:@"UIElement_Type"];
        NSString *elementType = [[elementTypeNodes objectAtIndex:0] stringValue];
        [csvString appendString:[NSString stringWithFormat:@"%@,", [elementType stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
        
        //add element label
        NSArray *elementLabelNodes = [resultUIElement elementsForName:@"UIElement_Label"];
        NSString *elementLabel = [[elementLabelNodes objectAtIndex:0] stringValue];
        elementLabel = [elementLabel stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        [csvString appendString:[NSString stringWithFormat:@"%@,", [elementLabel stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
        
        //add element action
        NSArray *elementActionNodes = [resultUIElement elementsForName:@"UIElement_Action"];
        NSString *elementAction = [[elementActionNodes objectAtIndex:0] stringValue];
        [csvString appendString:[NSString stringWithFormat:@"%@,", [elementAction stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
        
        //add element details
        NSArray *elementDetailsNodes = [resultElement elementsForName:@"UIElement_Details"];
        NSString *elementDetails = [elementDetailsNodes count]?[[elementDetailsNodes objectAtIndex:0] stringValue]:@"";
        [csvString appendString:[NSString stringWithFormat:@"%@,", [elementDetails stringByReplacingOccurrencesOfString:@"," withString:@";"]]];
    }
    else
        [csvString appendString:@",,,,"];
    
    //add methods
    resultNodes = [resultElement elementsForName:@"Methods"];
    NSArray *methodNodes = [resultNodes[0] elementsForName:@"Method"];
    for (CXMLElement* resultElement in methodNodes){
        NSString *methodDetails = [resultElement stringValue];
        [csvString appendString:[NSString stringWithFormat:@"%@;", methodDetails]];
    }
    [csvString appendString:@","];
    [csvString appendString:@"\n"];
}

-(void)trimiPhoneStatesEdges
{
    NSArray* rows = [self.iphoneStatesCsv componentsSeparatedByString:@"\n"];
    
    for (int i=1;i<rows.count-1;i++){
        NSString* row1 = [rows objectAtIndex:i];
        NSArray* columns1 = [row1 componentsSeparatedByString:@","];
        
        for (int j=i+1;j<rows.count-1;j++){
            NSString* row2 = [rows objectAtIndex:j];
            NSArray* columns2 = [row2 componentsSeparatedByString:@","];
            if ([columns1[2] isEqualToString:columns2[2]] &&
                [columns1[3] isEqualToString:columns2[3]] &&
                [columns1[5] isEqualToString:columns2[5]]) {
                
                //remove identical states
                self.iphoneStatesCsv = [[self.iphoneStatesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",row2] withString:@""] mutableCopy];
                
                //rename identical states
                self.iphoneEdgesCsv = [[self.iphoneEdgesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",columns2[1]] withString:[NSString stringWithFormat:@"%@,",columns1[1]]] mutableCopy];
                
                //remove identical states
                NSArray* otherRows = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"];
                for (NSString* otherRow1 in otherRows){
                    if([otherRow1 rangeOfString:columns2[1] options:NSCaseInsensitiveSearch].location != NSNotFound)
                        self.iphoneElementsCsv = [[self.iphoneElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                }
            }
        }
    }
}

-(void)trimAndroidStatesEdges
{
    NSArray* rows = [self.androidStatesCsv componentsSeparatedByString:@"\n"];
    
    for (int i=1;i<rows.count-1;i++){
        NSString* row1 = [rows objectAtIndex:i];
        NSArray* columns1 = [row1 componentsSeparatedByString:@","];
        
        for (int j=i+1;j<rows.count-1;j++){
            NSString* row2 = [rows objectAtIndex:j];
            NSArray* columns2 = [row2 componentsSeparatedByString:@","];
            if ([columns1[2] isEqualToString:columns2[2]] &&
                [columns1[3] isEqualToString:columns2[3]] &&
                [columns1[5] isEqualToString:columns2[5]]) {
                
                //remove identical states
                self.androidStatesCsv = [[self.androidStatesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",row2] withString:@""] mutableCopy];
                
                //rename identical states
                self.androidEdgesCsv = [[self.androidEdgesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",columns2[1]] withString:[NSString stringWithFormat:@"%@,",columns1[1]]] mutableCopy];
                
                //remove identical states
                NSArray* otherRows = [self.androidElementsCsv componentsSeparatedByString:@"\n"];
                for (NSString* otherRow1 in otherRows){
                    if([otherRow1 rangeOfString:columns2[1] options:NSCaseInsensitiveSearch].location != NSNotFound)
                        self.androidElementsCsv = [[self.androidElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                }
            }
        }
    }
}

-(NSString*)getStringForTFHppleElement:(TFHppleElement *)element
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

- (float)outputInconsistencies
{
    float similarity =[self compareInitialStateAndTouchedElementPairs];
    float similarity2 = [self compareStateAndTouchedElementPairs];
    return similarity;
}

-(float)compareStateAndTouchedElementPairs
{
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
                    [element setObject:rows[5]?rows[5]:@"" forKey:@"UIElement_Details"];
                    
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
                    [element setObject:rows[5]?rows[5]:@"" forKey:@"UIElement_Details"];
                    
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


-(float)compareInitialStateAndTouchedElementPairs{
    
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
                [element setObject:rows[5]?rows[5]:@"" forKey:@"UIElement_Details"];
                
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
                [element setObject:rows[5]?rows[5]:@"" forKey:@"UIElement_Details"];
                
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
    
    return similarity;
}

-(float)calculateStatePairsSimilarityS1:(NSMutableDictionary*)iphoneState withS2:(NSMutableDictionary*)androidState
{
    float classSimilarity = [iphoneState[@"State_ClassName"] compareWithWord:androidState[@"State_ClassName"]];
    float titleSimilarity = [iphoneState[@"State_Title"] compareWithWord:androidState[@"State_Title"]];
    
    float similarity = WEIGHT_S_CLASS*classSimilarity + WEIGHT_S_TITLE*titleSimilarity +
    WEIGHT_S_COUNT_GUIS*(([iphoneState[@"State_NumberOfElements"] isEqualToString:androidState[@"State_NumberOfElements"]]) ? 1 : 0) +
    [self calculateElementsPairsSimilarityE1:iphoneState[@"Elements"] withE2:androidState[@"Elements"]];
    
    return similarity;
}

-(float)calculateElementsPairsSimilarityE1:(NSMutableArray*)iphoneElements withE2:(NSMutableArray*)androidElements
{
    float similarity = 0;
    float maxSimilarity = 0;
    float totalSimilarity = 0;
    NSMutableDictionary* correspondentElement;
    
    for (NSMutableDictionary* element1 in iphoneElements) {
    
        for (NSMutableDictionary* element2 in androidElements) {
        
            float actionSimilarity = [element1[@"UIElement_Action"] compareWithWord:element2[@"UIElement_Action"]];
            float labelSimilarity = [element1[@"UIElement_Label"] compareWithWord:element2[@"UIElement_Label"]];
            float typeSimilarity = [self mappedE1:element1[@"UIElement_Type"] withE2:element2[@"UIElement_Type"]];
            
            similarity = WEIGHT_E_TITLE*labelSimilarity + WEIGHT_E_ACTION*actionSimilarity + WEIGHT_E_CLASS*typeSimilarity;
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

-(float)mappedE1:(NSString*)iphoneElement withE2:(NSString*)androidElement
{
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

-(void)outputXMLFile:(NSMutableString *)outputString withIndex:(NSUInteger)i
{
    NSString *directory = [@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles" stringByAppendingPathComponent: [NSString stringWithFormat:@"/%@XMLFiles", @"Android"]];
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[directory stringByAppendingPathComponent:[NSString stringWithFormat:@"xmlFile_%ld.xml", (unsigned long)i]]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //[fileHandler seekToEndOfFile];
    [fileHandler writeData:[outputString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

-(void)outputAndroidCsvFiles
{
    NSString *path1 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidStates.csv"]];
    freopen([path1 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler1 = [NSFileHandle fileHandleForUpdatingAtPath:path1];
    //[fileHandler1 seekToEndOfFile];
    [fileHandler1 writeData:[self.androidStatesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler1 closeFile];

    NSString *path2 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidElements.csv"]];
    freopen([path2 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler2 = [NSFileHandle fileHandleForUpdatingAtPath:path2];
    //[fileHandler2 seekToEndOfFile];
    [fileHandler2 writeData:[self.androidElementsCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler2 closeFile];

    NSString *path3 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidEdges.csv"]];
    freopen([path3 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler3 = [NSFileHandle fileHandleForUpdatingAtPath:path3];
    //[fileHandler3 seekToEndOfFile];
    [fileHandler3 writeData:[self.androidEdgesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler3 closeFile];
}

-(void)outputiPhoneCsvFile
{
    NSString *path1 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneStates.csv"]];
    freopen([path1 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler1 = [NSFileHandle fileHandleForUpdatingAtPath:path1];
    //[fileHandler1 seekToEndOfFile];
    [fileHandler1 writeData:[self.iphoneStatesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler1 closeFile];

    NSString *path2 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneElements.csv"]];
    freopen([path2 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler2 = [NSFileHandle fileHandleForUpdatingAtPath:path2];
    //[fileHandler2 seekToEndOfFile];
    [fileHandler2 writeData:[self.iphoneElementsCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler2 closeFile];

    NSString *path3 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneEdges.csv"]];
    freopen([path3 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler3 = [NSFileHandle fileHandleForUpdatingAtPath:path3];
    //[fileHandler3 seekToEndOfFile];
    [fileHandler3 writeData:[self.iphoneEdgesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler3 closeFile];
}

@end







