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
#define WEIGHT_S_CLASS 1
#define WEIGHT_S_TITLE 1
#define WEIGHT_S_COUNT_GUIS 1
#define WEIGHT_E_CLASS 1
#define WEIGHT_E_TITLE 1
#define WEIGHT_E_DETAIL 1
#define WEIGHT_E_ACTION 1

@implementation MasterViewController

@synthesize similarityCsv, androidXmlData, iphoneXmlData, androidStatesCsv, androidElementsCsv, androidEdgesCsv, iphoneStatesCsv, iphoneElementsCsv, iphoneEdgesCsv, responseData, statusCode, jiraUrl, androidStatesAry, androidEdgesAry, iphoneStatesAry, iphoneEdgesAry;

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
    self.similarityCsv = [[NSMutableString alloc] init];

    self.androidStatesAry = [[NSMutableArray alloc]init];
    self.androidEdgesAry = [[NSMutableArray alloc]init];
    self.iphoneStatesAry = [[NSMutableArray alloc]init];
    self.iphoneEdgesAry = [[NSMutableArray alloc]init];
    
    [self setupOutputFiles];
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
                        [self parseEdgesXMLFiles:resultElement appendTo:self.androidEdgesCsv];
                    
                    [self clusterAndroidStatesEdges];
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
                        [self parseEdgesXMLFiles:resultElement appendTo:self.iphoneEdgesCsv];
                    
                    //[self outputiPhoneCsvFile];
                    [self clusteriPhoneStatesEdges];
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
    
    //calculate different combinations of properties and similarities
    [self outputInconsistencies];
    
    [self.summaryLabel setStringValue:[NSString stringWithFormat:@"Android (%tu States, %tu Elements, %tu Edges) and iPhone(%tu States, %tu Elements, %tu Edges) are saved in ../Desktop/mapping-projects/CAMPChecker/outputFiles/", i,(unsigned long)j,(unsigned long)k,(unsigned long)l,(unsigned long)m,(unsigned long)n]];
    [self.view addSubview:self.summaryLabel];
}

-(void)parseStatesXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString
{
    //add TimeStamp
    NSArray *timeStampNodes = [resultElement elementsForName:@"TimeStamp"];
    NSString *timeStamp = [[timeStampNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", timeStamp?[timeStamp stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add state ID
    NSArray *stateIdNodes = [resultElement elementsForName:@"State_ID"];
    NSString *stateId = [[stateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", stateId?[stateId stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add class name
    NSArray *classNameNodes = [resultElement elementsForName:@"State_ClassName"];
    NSString *className = [[classNameNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", className?[className stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add title 
    NSArray *statusNodes = [resultElement elementsForName:@"State_Title"];
    NSString *bugStatus = [[statusNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", bugStatus?[bugStatus stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add screen shot path
    NSArray *screenshotNodes = [resultElement elementsForName:@"State_ScreenshotPath"];
    NSString *screenShot = [[screenshotNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,",screenShot?[screenShot stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];

    //add number of elements
    NSArray *elementsNumberNodes = [resultElement elementsForName:@"State_NumberOfElements"];
    NSString *elementsNumber = [[elementsNumberNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", elementsNumber?[elementsNumber stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    [csvString appendString:@"\n"];
}

-(void)parseElementsXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    //add state ID
    NSArray *stateIdNodes = [resultElement elementsForName:@"State_ID"];
    NSString *stateId = [[stateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", stateId?[stateId stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add element ID
    NSArray *elementIdNodes = [resultElement elementsForName:@"UIElement_ID"];
    NSString *elementId = [[elementIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", elementId?[elementId stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add element type
    NSArray *elementTypeNodes = [resultElement elementsForName:@"UIElement_Type"];
    NSString *elementType = [[elementTypeNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", elementType?[elementType stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add element label
    NSArray *elementLabelNodes = [resultElement elementsForName:@"UIElement_Label"];
    NSString *elementLabel = [[elementLabelNodes objectAtIndex:0] stringValue];
    elementLabel = [elementLabel stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [csvString appendString:[NSString stringWithFormat:@"%@,", elementLabel?[elementLabel stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add element action
    NSArray *elementActionNodes = [resultElement elementsForName:@"UIElement_Action"];
    NSString *elementAction = [[elementActionNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", elementAction?[elementAction stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add element details
    NSArray *elementDetailsNodes = [resultElement elementsForName:@"UIElement_Details"];
    NSString *elementDetails = [[elementDetailsNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", elementDetails?[elementDetails stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    [csvString appendString:@"\n"];
}

-(void)parseEdgesXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    //add TimeStamp
    NSArray *timeStampNodes = [resultElement elementsForName:@"TimeStamp"];
    NSString *timeStamp = [[timeStampNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", timeStamp?[timeStamp stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add Source State ID
    NSArray *srcStateIdNodes = [resultElement elementsForName:@"Source_State_ID"];
    NSString *srcStateId = [[srcStateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", srcStateId?[srcStateId stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add Target State ID
    NSArray *trgStateIdNodes = [resultElement elementsForName:@"Target_State_ID"];
    NSString *trgStateId = [[trgStateIdNodes objectAtIndex:0] stringValue];
    [csvString appendString:[NSString stringWithFormat:@"%@,", trgStateId?[trgStateId stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    NSArray* resultNodes = [resultElement elementsForName:@"TouchedElement"];
    CXMLElement* resultUIElement = resultNodes[0];
    
    if ([resultUIElement.children count]>0){
        //add element type
        NSArray *elementTypeNodes = [resultUIElement elementsForName:@"UIElement_Type"];
        NSString *elementType = [[elementTypeNodes objectAtIndex:0] stringValue];
        [csvString appendString:[NSString stringWithFormat:@"%@,", elementType?[elementType stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
        
        //add element label
        NSArray *elementLabelNodes = [resultUIElement elementsForName:@"UIElement_Label"];
        NSString *elementLabel = [[elementLabelNodes objectAtIndex:0] stringValue];
        elementLabel = [elementLabel stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        [csvString appendString:[NSString stringWithFormat:@"%@,", elementLabel?[elementLabel stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
        
        //add element action
        NSArray *elementActionNodes = [resultUIElement elementsForName:@"UIElement_Action"];
        NSString *elementAction = [[elementActionNodes objectAtIndex:0] stringValue];
        [csvString appendString:[NSString stringWithFormat:@"%@,", elementAction?[elementAction stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
        
        //add element details
        NSArray *elementDetailsNodes = [resultElement elementsForName:@"UIElement_Details"];
        NSString *elementDetails = [elementDetailsNodes count]?[[elementDetailsNodes objectAtIndex:0] stringValue]:@"";
        [csvString appendString:[NSString stringWithFormat:@"%@,", elementDetails?[elementDetails stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
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

-(void)clusteriPhoneStatesEdges
{
    BOOL flag = false;
    NSArray* rows = [self.iphoneStatesCsv componentsSeparatedByString:@"\n"];
    NSArray* elRows = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"];
    
    for (int i=1;i<rows.count-1;i++){
        NSString* row1 = [rows objectAtIndex:i];
        NSArray* columns1 = [row1 componentsSeparatedByString:@","];
        
        for (int j=i+1;j<rows.count-1;j++){
            NSString* row2 = [rows objectAtIndex:j];
            NSArray* columns2 = [row2 componentsSeparatedByString:@","];
            if ([columns1[2] isEqualToString:columns2[2]] && [columns1[3] isEqualToString:columns2[3]]) {  //classnames and titles
                if ([columns1[5] isEqualToString:columns2[5]]) {  //number of UI elements are equal
                    
                    //compare the elements
                    for (int l=1;l<elRows.count-1;l++){
                        NSString* elRow1 = [elRows objectAtIndex:l];
                        NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                        
                        if ([columns1[1] isEqualToString:elColumns1[0]]) {
                            for (int k=l+1;k<elRows.count-1;k++){
                                NSString* elRow2 = [elRows objectAtIndex:k];
                                NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                if ([columns2[1] isEqualToString:elColumns2[0]]) {
                                    if ([elColumns1[1] isEqualToString:elColumns2[1]] && [elColumns1[2] isEqualToString:elColumns2[2]] && [elColumns1[3] isEqualToString:elColumns2[3]] && [elColumns1[4] isEqualToString:elColumns2[4]] && [elColumns1[5] isEqualToString:elColumns2[5]]) {
                                        // are exactly equal
                                        flag= true;
                                        break;
                                    }
                                    flag= false;
                                }
                            }
                        }
                    }
                    
                    if (flag) {
                        //remove identical states from the states array
                        self.iphoneStatesCsv = [[self.iphoneStatesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",row2] withString:@""] mutableCopy];
                        
                        //rename identical states in the edges array
                        self.iphoneEdgesCsv = [[self.iphoneEdgesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",columns2[1]] withString:[NSString stringWithFormat:@"%@,",columns1[1]]] mutableCopy];
                        
                        //remove identical states in the elements array
                        NSArray* otherRows = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"];
                        for (NSString* otherRow1 in otherRows){
                            if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns2[1]] options:NSCaseInsensitiveSearch].location != NSNotFound)
                                self.iphoneElementsCsv = [[self.iphoneElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                        }
                    }
                }
                else {  //number of UI elements are NOT equal
                    
                    if ([columns1[5] intValue] > [columns2[5] intValue]) {
                        for (int l=1;l<elRows.count-1;l++){
                            NSString* elRow1 = [elRows objectAtIndex:l];
                            NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                            
                            if ([columns1[1] isEqualToString:elColumns1[0]]) {
                                for (int k=l+1;k<elRows.count-1;k++){
                                    NSString* elRow2 = [elRows objectAtIndex:k];
                                    NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                    if ([columns2[1] isEqualToString:elColumns2[0]]) {
                                        if ([elColumns1[2] isEqualToString:elColumns2[2]] && [elColumns1[3] isEqualToString:elColumns2[3]] && [elColumns1[4] isEqualToString:elColumns2[4]] && [elColumns1[5] isEqualToString:elColumns2[5]]) {
                                            // are exactly equal
                                            flag= true;
                                            break;
                                        }
                                        flag= false;
                                    }
                                }
                            }
                        }
                        
                        if (flag) {
                            //remove identical states from the states array
                            self.iphoneStatesCsv = [[self.iphoneStatesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",row2] withString:@""] mutableCopy];
                            
                            //rename identical states in the edges array
                            self.iphoneEdgesCsv = [[self.iphoneEdgesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",columns2[1]] withString:[NSString stringWithFormat:@"%@,",columns1[1]]] mutableCopy];
                            
                            //remove identical states in the elements array
                            NSArray* otherRows = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"];
                            for (NSString* otherRow1 in otherRows){
                                if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns2[1]] options:NSCaseInsensitiveSearch].location != NSNotFound)
                                    self.iphoneElementsCsv = [[self.iphoneElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                            }
                        }
                    }
                    else if ([columns1[5] intValue] < [columns2[5] intValue]){
                        for (int l=1;l<elRows.count-1;l++){
                            NSString* elRow1 = [elRows objectAtIndex:l];
                            NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                            
                            if ([columns1[1] isEqualToString:elColumns1[0]]) {
                                for (int k=l+1;k<elRows.count-1;k++){
                                    NSString* elRow2 = [elRows objectAtIndex:k];
                                    NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                    if ([columns2[1] isEqualToString:elColumns2[0]]) {
                                        if ([elColumns1[2] isEqualToString:elColumns2[2]] && [elColumns1[3] isEqualToString:elColumns2[3]] && [elColumns1[4] isEqualToString:elColumns2[4]] && [elColumns1[5] isEqualToString:elColumns2[5]]) {
                                            // are exactly equal
                                            flag= true;
                                            break;
                                        }
                                        flag= false;
                                    }
                                }
                            }
                        }
                
                        if (flag) {
                            NSString *temp = [row1 stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",%@,",columns1[5]] withString:[NSString stringWithFormat:@",%@,",columns2[5]]];
                            
                            //remove identical states from the states array
                            self.iphoneStatesCsv = [[self.iphoneStatesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",row1] withString:[NSString stringWithFormat:@"%@\n",temp]] mutableCopy];
                            row1 = temp;
                            columns1 = [row1 componentsSeparatedByString:@","];
                            
                            self.iphoneStatesCsv = [[self.iphoneStatesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",row2] withString:@""] mutableCopy];
                            
                            //rename identical states in the edges array
                            self.iphoneEdgesCsv = [[self.iphoneEdgesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",columns2[1]] withString:[NSString stringWithFormat:@"%@,",columns1[1]]] mutableCopy];
                            
                            //remove identical states in the elements array
                            NSArray* otherRows = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"];
                            for (NSString* otherRow1 in otherRows){
                                if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns1[1]] options:NSCaseInsensitiveSearch].location != NSNotFound)
                                    self.iphoneElementsCsv = [[self.iphoneElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                            }
                            otherRows = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"];
                            for (NSString* otherRow1 in otherRows){
                                if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns2[1]] options:NSCaseInsensitiveSearch].location != NSNotFound){
                                    
                                    NSString* otherRow2 = [[otherRow1 stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",columns2[1]] withString:[NSString stringWithFormat:@"%@,",columns1[1]]] mutableCopy];
                                    self.iphoneElementsCsv = [[self.iphoneElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:[NSString stringWithFormat:@"%@\n",otherRow2]] mutableCopy];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void)clusterAndroidStatesEdges
{
    BOOL flag = false;
    NSArray* rows = [self.androidStatesCsv componentsSeparatedByString:@"\n"];
    NSArray* elRows = [self.androidElementsCsv componentsSeparatedByString:@"\n"];
    
    for (int i=1;i<rows.count-1;i++){
        NSString* row1 = [rows objectAtIndex:i];
        NSArray* columns1 = [row1 componentsSeparatedByString:@","];
        
        for (int j=i+1;j<rows.count-1;j++){
            NSString* row2 = [rows objectAtIndex:j];
            NSArray* columns2 = [row2 componentsSeparatedByString:@","];
            if ([columns1[2] isEqualToString:columns2[2]] && [columns1[3] isEqualToString:columns2[3]]) { // classnames && titles
                    
                if ([columns1[5] isEqualToString:columns2[5]]) {  //number of UI elements are equal
                    //compare the elements
                    for (int l=1;l<elRows.count-1;l++){
                        NSString* elRow1 = [elRows objectAtIndex:l];
                        NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                        
                        if ([columns1[1] isEqualToString:elColumns1[0]]) {
                            for (int k=l+1;k<elRows.count-1;k++){
                                NSString* elRow2 = [elRows objectAtIndex:k];
                                NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                if ([columns2[1] isEqualToString:elColumns2[0]]) {
                                    if ([elColumns1[1] isEqualToString:elColumns2[1]] && [elColumns1[2] isEqualToString:elColumns2[2]] && [elColumns1[3] isEqualToString:elColumns2[3]] && [elColumns1[4] isEqualToString:elColumns2[4]] && [elColumns1[5] isEqualToString:elColumns2[5]]) {
                                        // are exactly equal
                                        flag= true;
                                        break;
                                    }
                                    flag= false;
                                }
                            }
                        }
                    }
                    
                    if (flag) {
                        //remove identical states from the states array
                        self.androidStatesCsv = [[self.androidStatesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",row2] withString:@""] mutableCopy];
                        
                        //rename identical states in the edges array
                        self.androidEdgesCsv = [[self.androidEdgesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",columns2[1]] withString:[NSString stringWithFormat:@"%@,",columns1[1]]] mutableCopy];
                        
                        //remove identical states in the elements array
                        NSArray* otherRows = [self.androidElementsCsv componentsSeparatedByString:@"\n"];
                        for (NSString* otherRow1 in otherRows){
                            if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns2[1]] options:NSCaseInsensitiveSearch].location != NSNotFound)
                                self.androidElementsCsv = [[self.androidElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                        }
                    }
                }
                else {  //number of UI elements are NOT equal
                    
                    if ([columns1[5] intValue] > [columns2[5] intValue]) {
                        for (int l=1;l<elRows.count-1;l++){
                            NSString* elRow1 = [elRows objectAtIndex:l];
                            NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                            
                            if ([columns2[1] isEqualToString:elColumns1[0]]) {
                                for (int k=l+1;k<elRows.count-1;k++){
                                    NSString* elRow2 = [elRows objectAtIndex:k];
                                    NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                    if ([columns1[1] isEqualToString:elColumns2[0]]) {
                                        if ([elColumns1[2] isEqualToString:elColumns2[2]] && [elColumns1[3] isEqualToString:elColumns2[3]] && [elColumns1[4] isEqualToString:elColumns2[4]] && [elColumns1[5] isEqualToString:elColumns2[5]]) {
                                            // are exactly equal
                                            flag= true;
                                            break;
                                        }
                                        flag= false;
                                    }
                                }
                            }
                        }
                        
                        if (flag) {
                            //remove identical states from the states array
                            self.androidStatesCsv = [[self.androidStatesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",row2] withString:@""] mutableCopy];
                            
                            //rename identical states in the edges array
                            self.androidEdgesCsv = [[self.androidEdgesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",columns2[1]] withString:[NSString stringWithFormat:@"%@,",columns1[1]]] mutableCopy];
                            
                            //remove identical states in the elements array
                            NSArray* otherRows = [self.androidElementsCsv componentsSeparatedByString:@"\n"];
                            for (NSString* otherRow1 in otherRows){
                                if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns2[1]] options:NSCaseInsensitiveSearch].location != NSNotFound)
                                    self.androidElementsCsv = [[self.androidElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                            }
                        }
                    }
                    else if ([columns1[5] intValue] < [columns2[5] intValue]){
                        for (int l=1;l<elRows.count-1;l++){
                            NSString* elRow1 = [elRows objectAtIndex:l];
                            NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                            
                            if ([columns1[1] isEqualToString:elColumns1[0]]) {
                                for (int k=l+1;k<elRows.count-1;k++){
                                    NSString* elRow2 = [elRows objectAtIndex:k];
                                    NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                    if ([columns2[1] isEqualToString:elColumns2[0]]) {
                                        if ([elColumns1[2] isEqualToString:elColumns2[2]] && [elColumns1[3] isEqualToString:elColumns2[3]] && [elColumns1[4] isEqualToString:elColumns2[4]] && [elColumns1[5] isEqualToString:elColumns2[5]]) {
                                            // are exactly equal
                                            flag= true;
                                            break;
                                        }
                                        flag= false;
                                    }
                                }
                            }
                        }

                        if (flag) {
                            NSString *temp = [row1 stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",%@,",columns1[5]] withString:[NSString stringWithFormat:@",%@,",columns2[5]]];
                            
                            //remove identical states from the states array
                            self.androidStatesCsv = [[self.androidStatesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",row1] withString:[NSString stringWithFormat:@"%@\n",temp]] mutableCopy];
                            row1 = temp;
                            columns1 = [row1 componentsSeparatedByString:@","];
                            
                            self.androidStatesCsv = [[self.androidStatesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",row2] withString:@""] mutableCopy];
                            
                            //rename identical states in the edges array
                            self.androidEdgesCsv = [[self.androidEdgesCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",columns2[1]] withString:[NSString stringWithFormat:@"%@,",columns1[1]]] mutableCopy];
                            
                            //remove identical states in the elements array
                            NSArray* otherRows = [self.androidElementsCsv componentsSeparatedByString:@"\n"];
                            for (NSString* otherRow1 in otherRows){
                                if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns1[1]] options:NSCaseInsensitiveSearch].location != NSNotFound)
                                    self.androidElementsCsv = [[self.androidElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                                
                            }
                            otherRows = [self.androidElementsCsv componentsSeparatedByString:@"\n"];
                            for (NSString* otherRow1 in otherRows){
                                if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns2[1]] options:NSCaseInsensitiveSearch].location != NSNotFound){
                                    
                                    NSString* otherRow2 = [[otherRow1 stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,",columns2[1]] withString:[NSString stringWithFormat:@"%@,",columns1[1]]] mutableCopy];
                                    self.androidElementsCsv = [[self.androidElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:[NSString stringWithFormat:@"%@\n",otherRow2]] mutableCopy];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)outputInconsistencies
{
    //get the android-iphone states and elements arrays
    [self getStateAndElementsArray];
    
    //get the android-iphone edges arrays
    [self getEdgesArray];
    
    //compare models
    //[self compareModels];
    
    //get the initial states
    [self.iphoneStatesAry[0] setObject:@1 forKey:@"Mapped"];
    NSMutableDictionary* iPhoneIntialState = self.iphoneStatesAry[0];
    [self.androidStatesAry[0] setObject:@1 forKey:@"Mapped"];
    NSMutableDictionary* androidIntialState = self.androidStatesAry[0];
    
    [self compareiPhoneState:iPhoneIntialState withAndroidState:androidIntialState];
    
    //get the initial edges
    NSMutableArray *edgePairs = [NSMutableArray array];
    edgePairs = [self compareEdgePairsForiPhoneState:iPhoneIntialState andAndroidState:androidIntialState];
    //loop through all states, edges
    
    for (int i=0;i<edgePairs.count;i++){
        NSMutableDictionary* edgePair = [edgePairs objectAtIndex:i];
        
        if([edgePair[@"Mapped"] isEqualToNumber:@0]) {
            //Mark edge pair as mapped
            edgePair[@"Mapped"]=@1;
            NSMutableArray* nextEdgePairs = [self compareNextStates:edgePair];
            for (int k=0;k<nextEdgePairs.count;k++){
                NSMutableDictionary* nextEdgePair = [nextEdgePairs objectAtIndex:k];
                [edgePairs insertObject:nextEdgePair atIndex:i+k+1];
            }
        }
    }
    
    //write similarities
    [self outputSimilarityCsvFile];
}

-(NSMutableArray*)compareNextStates:(NSMutableDictionary*)edgePair {
    
    NSMutableDictionary* iPhoneState = [self findState:edgePair[@"iPhone"][@"Target_State_ID"] inStates:self.iphoneStatesAry];
    NSMutableDictionary* androidState = [self findState:edgePair[@"Android"][@"Target_State_ID"] inStates:self.androidStatesAry];
    
    if (iPhoneState && androidState) {
        [self compareiPhoneState:iPhoneState withAndroidState:androidState];
        NSMutableArray* edgePairs = [self compareEdgePairsForiPhoneState:iPhoneState andAndroidState:androidState];
        return edgePairs;
    }
    else
        return nil;
}

-(NSMutableDictionary*)findState:(NSString*)stateId inStates:(NSArray*)statesAry
{
    for (NSMutableDictionary* s in statesAry) {
        if([s[@"State_ID"] isEqualToString:stateId] && (!s[@"Mapped"] || (s[@"Mapped"] && s[@"Mapped"]==0))) {
            NSInteger anIndex=[statesAry indexOfObject:s];
            [s setObject:@1 forKey:@"Mapped"];
            [(NSMutableArray*)statesAry replaceObjectAtIndex:anIndex withObject:s];
            return s;
        }
        
    }
    return nil;
}

-(NSMutableArray*)compareEdgePairsForiPhoneState:(NSMutableDictionary*)iPhoneState andAndroidState:(NSMutableDictionary*)androidState{

    NSMutableArray *edgePairs = [NSMutableArray array];
    NSUInteger maxDif;
    NSUInteger sum;
    
    NSArray *iPhoneEdges =  [self getOutgoingEdgesFor:iPhoneState inEdges:self.iphoneEdgesAry];
    NSArray *androidEdges =  [self getOutgoingEdgesFor:androidState inEdges:self.androidEdgesAry];
    
    //To-Do: Sort edges array with TimeStamp
    
    //map outgoing edges
    for (NSMutableDictionary* edge1 in iPhoneEdges) {
        
        NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
        edgePair[@"iPhone"] = edge1;
        maxDif=100;
        for (NSMutableDictionary* edge2 in androidEdges) {
            
            NSUInteger r1 = [edge1[@"TouchedElement_Action"] levenshteinDistanceToString:edge2[@"TouchedElement_Action"]];
            NSUInteger r2 = [edge1[@"TouchedElement_Label"] levenshteinDistanceToString:edge2[@"TouchedElement_Label"]];
            sum = WEIGHT_E_ACTION*r1+WEIGHT_E_TITLE*r2;
            if (sum < maxDif) {
                edgePair[@"Android"]=edge2;
                edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                edgePair[@"Mapped"]=@0;
                maxDif = sum;
            }
        }
        
        [edgePairs addObject:edgePair];
        [self.similarityCsv appendString:@"\n***Closest Edges in Combination 1: Edge (Label, Action)\n"];
        [self.similarityCsv appendString:[NSString stringWithFormat:@"iPhoneEdge: %@->%@ (%@, %@), androidEdge: %@->%@ (%@, %@), Diff: %tu \n",edgePair[@"iPhone"][@"Source_State_ID"], edgePair[@"iPhone"][@"Target_State_ID"],edgePair[@"iPhone"][@"TouchedElement_Action"],edgePair[@"iPhone"][@"TouchedElement_Label"],edgePair[@"Android"][@"Source_State_ID"],edgePair[@"Android"][@"Target_State_ID"],edgePair[@"Android"][@"TouchedElement_Action"],edgePair[@"Android"][@"TouchedElement_Label"],sum]];
    }
    
    return edgePairs;
}

-(void)compareiPhoneState:(NSMutableDictionary*)iPhoneState withAndroidState:(NSMutableDictionary*)androidState {
    
    [self.similarityCsv appendString:@"\n***Closest States in Combination 1: State (ClassName, Title)\n"];
    //heuristics on class names
    NSString* n1 = [iPhoneState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
    n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
    n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
    n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
    NSString* n2 = [androidState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
    n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
    NSUInteger r1 = [n1 levenshteinDistanceToString:n2];
    NSUInteger r2 = [iPhoneState[@"State_Title"] levenshteinDistanceToString:androidState[@"State_Title"]];
    NSUInteger sum = WEIGHT_S_CLASS*r1+WEIGHT_S_TITLE*r2;
            
    [self.similarityCsv appendString:[NSString stringWithFormat:@"iPhoneState: %@, androidState: %@, Diff: %tu \n",iPhoneState[@"State_ID"],androidState[@"State_ID"],sum]];
}

- (NSMutableArray*)getOutgoingEdgesFor:(NSMutableDictionary*)state inEdges:(NSArray*)edgesAry
{
    NSMutableArray *outgoingEdges = [NSMutableArray array];
    
    for (NSMutableDictionary* edge in edgesAry) {
        if([state[@"State_ID"] isEqualToString:edge[@"Source_State_ID"]])
            [outgoingEdges addObject:edge];
    }
    
    return outgoingEdges;
}

-(void)getStateAndElementsArray
{
    NSString *line;
    [self.similarityCsv appendString:@"\n\n***iPhone States\nState_ID      State_ClassName     State_Title     State_NumberOfElements\n"];
    for(int i=1; i< [[self.iphoneStatesCsv componentsSeparatedByString:@"\n"] count]; i++) {
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
            
            //printout states
            [self.similarityCsv appendString:[NSString stringWithFormat:@"%@            %@      %@      %@\n",rows[1],rows[2],rows[3],rows[5]]];
            
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
    
    [self.similarityCsv appendString:@"\n\n***Android States\nState_ID      State_ClassName     State_Title     State_NumberOfElements\n"];
    for(int i=1; i< [[self.androidStatesCsv componentsSeparatedByString:@"\n"] count]; i++) {
        line = [self.androidStatesCsv componentsSeparatedByString:@"\n"][i];
        if ([line length]>0) {
            NSArray *rows = [line componentsSeparatedByString:@","];
            NSMutableDictionary* row = [NSMutableDictionary dictionary];
            [row setObject:rows[0]?rows[0]:@"" forKey:@"TimeStamp"];
            [row setObject:rows[1]?rows[1]:@"" forKey:@"State_ID"];
            [row setObject:rows[2]?rows[2]:@"" forKey:@"State_ClassName"];
            [row setObject:rows[3]?rows[3]:@"" forKey:@"State_Title"];
            [row setObject:rows[4]?rows[4]:@"" forKey:@"State_ScreenshotPath"];
            [row setObject:rows[5]?rows[5]:@"" forKey:@"State_NumberOfElements"];
            
            //printout states
            [self.similarityCsv appendString:[NSString stringWithFormat:@"%@            %@          %@      %@\n",rows[1],rows[2],rows[3],rows[5]]];
            
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
}

-(void)getEdgesArray
{
    NSString *line;
    [self.similarityCsv appendString:@"\n\n***iPhone Actions\nSource -> Target     TouchedElement(Type     Label       Action       Details)\n"];
    for(int i=1; i< [[self.iphoneEdgesCsv componentsSeparatedByString:@"\n"] count]; i++) {
        line = [self.iphoneEdgesCsv componentsSeparatedByString:@"\n"][i];
        if ([line length]>0) {
            NSArray *rows = [line componentsSeparatedByString:@","];
            NSMutableDictionary* row = [NSMutableDictionary dictionary];
            [row setObject:rows[0]?rows[0]:@"" forKey:@"TimeStamp"];
            [row setObject:rows[1]?rows[1]:@"" forKey:@"Source_State_ID"];
            [row setObject:rows[2]?rows[2]:@"" forKey:@"Target_State_ID"];
            [row setObject:rows[3]?rows[3]:@"" forKey:@"TouchedElement_Type"];
            [row setObject:rows[4]?rows[4]:@"" forKey:@"TouchedElement_Label"];
            [row setObject:rows[5]?rows[5]:@"" forKey:@"TouchedElement_Action"];
            [row setObject:rows[6]?rows[6]:@"" forKey:@"TouchedElement_Details"];
            
            //printout edges
            [self.similarityCsv appendString:[NSString stringWithFormat:@"%@    ->  %@      %@      %@      %@      %@\n",rows[1],rows[2],rows[3],rows[4],rows[5],rows[6]]];
            
            //get the methods for the iphone action
            NSMutableArray *methods = [NSMutableArray array];
            if ([rows[7] length]>0) {
                methods = (NSMutableArray*)[rows[7] componentsSeparatedByString:@";"];
            }
            
            [row setObject:methods forKey:@"Methods"];
            [self.iphoneEdgesAry addObject:row];
        }
    }
    
    [self.similarityCsv appendString:@"\n\n***Android Actions\nSource_ID -> Target_ID     TouchedElement(Type     Label       Action       Details)\n"];
    for(int i=1; i< [[self.androidEdgesCsv componentsSeparatedByString:@"\n"] count]; i++) {
        line = [self.androidEdgesCsv componentsSeparatedByString:@"\n"][i];
        if ([line length]>0) {
            NSArray *rows = [line componentsSeparatedByString:@","];
            NSMutableDictionary* row = [NSMutableDictionary dictionary];
            [row setObject:rows[0]?rows[0]:@"" forKey:@"TimeStamp"];
            [row setObject:rows[1]?rows[1]:@"" forKey:@"Source_State_ID"];
            [row setObject:rows[2]?rows[2]:@"" forKey:@"Target_State_ID"];
            [row setObject:rows[3]?rows[3]:@"" forKey:@"TouchedElement_Type"];
            [row setObject:rows[4]?rows[4]:@"" forKey:@"TouchedElement_Label"];
            [row setObject:rows[5]?rows[5]:@"" forKey:@"TouchedElement_Action"];
            [row setObject:rows[6]?rows[6]:@"" forKey:@"TouchedElement_Details"];
            
            //printout edges
            [self.similarityCsv appendString:[NSString stringWithFormat:@"%@    ->  %@      %@      %@      %@      %@\n",rows[1],rows[2],rows[3],rows[4],rows[5],rows[6]]];
            
            //get the methods for the android action
            NSMutableArray *methods = [NSMutableArray array];
            if ([rows[7] length]>0) {
                methods = (NSMutableArray*)[rows[7] componentsSeparatedByString:@";"];
            }
            
            [row setObject:methods forKey:@"Methods"];
            [self.androidEdgesAry addObject:row];
        }
    }
}

-(void)compareModels{
    
    NSUInteger maxDif;
    NSMutableDictionary* closestRow;
    
    [self.similarityCsv appendString:@"\n***Closest States in Combination 1: State (ClassName, Title) \n\niPhone    Android     Diff \n"];
    for (NSMutableDictionary* row in self.iphoneStatesAry){
        
        maxDif=100;
        for (NSMutableDictionary* row2 in self.androidStatesAry){
        
            //heuristics on class names
            NSString* n1 = [row[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
            n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
            n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
            n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
            NSString* n2 = [row2[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
            n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
            NSUInteger r1 = [n1 levenshteinDistanceToString:n2];
            
            NSUInteger r2 = 0;
            if (!([row[@"State_Title"] isEqualToString:@""] || [row2[@"State_Title"] isEqualToString:@""]))
                r2 = [row[@"State_Title"] levenshteinDistanceToString:row2[@"State_Title"]];
            NSUInteger sum = WEIGHT_S_CLASS*r1+WEIGHT_S_TITLE*r2;
            
            //[self.similarityCsv appendString:[NSString stringWithFormat:@"%@ , %@, Dif: %tu \n",row[@"State_ID"],row2[@"State_ID"],sum]];
            
            if (sum < maxDif) {
                maxDif=sum;
                closestRow = row2;
            }
        }
        [self.similarityCsv appendString:[NSString stringWithFormat:@"%@        %@          %tu \n",row[@"State_ID"],closestRow[@"State_ID"],maxDif]];
    }
    
    [self.similarityCsv appendString:@"\n***Closest States in Combination 2: State (ClassName, Title, Elements) \n\niPhone    Android     Diff \n"];
    for (NSMutableDictionary* row in self.iphoneStatesAry){
        
        maxDif=100;
        for (NSMutableDictionary* row2 in self.androidStatesAry){
            
            //heuristics on class names
            NSString* n1 = [row[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
            n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
            n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
            n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
            NSString* n2 = [row2[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
            n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
            NSUInteger r1 = [n1 levenshteinDistanceToString:n2];
            
            NSUInteger r2 = 0;
            if (!([row[@"State_Title"] isEqualToString:@""] || [row2[@"State_Title"] isEqualToString:@""]))
                r2 = [row[@"State_Title"] levenshteinDistanceToString:row2[@"State_Title"]];
            
            NSUInteger sum = WEIGHT_S_CLASS*r1+WEIGHT_S_TITLE*r2+[self calculateElementsPairSimilarityE1:row[@"Elements"] withE2:row2[@"Elements"]];;
            
            //[self.similarityCsv appendString:[NSString stringWithFormat:@"%@ , %@, Dif: %tu \n",row[@"State_ID"],row2[@"State_ID"],sum]];
            
            if (sum < maxDif) {
                maxDif=sum;
                closestRow = row2;
            }
        }
        
        [self.similarityCsv appendString:[NSString stringWithFormat:@"%@        %@          %tu \n",row[@"State_ID"],closestRow[@"State_ID"],maxDif]];
    }

    
    [self.similarityCsv appendString:@"\n***Closest States in Combination 3: State(Title, Elements) \n\niPhone    Android     Diff \n"];
    for (NSMutableDictionary* row in self.iphoneStatesAry){
        
        maxDif=100;
        for (NSMutableDictionary* row2 in self.androidStatesAry){
            
            NSUInteger r2 = 0;
            if (!([row[@"State_Title"] isEqualToString:@""] || [row2[@"State_Title"] isEqualToString:@""]))
                r2 = [row[@"State_Title"] levenshteinDistanceToString:row2[@"State_Title"]];
            
            NSUInteger sum = WEIGHT_S_TITLE*r2-[self calculateElementsPairSimilarityE1:row[@"Elements"] withE2:row2[@"Elements"]];
            
            //[self.similarityCsv appendString:[NSString stringWithFormat:@"%@ , %@, Dif: %tu \n",row[@"State_ID"],row2[@"State_ID"],sum]];
            
            if (sum < maxDif) {
                maxDif=sum;
                closestRow = row2;
            }
        }
        [self.similarityCsv appendString:[NSString stringWithFormat:@"%@        %@          %tu \n",row[@"State_ID"],closestRow[@"State_ID"],maxDif]];
    }

    
    [self.similarityCsv appendString:@"\n***Closest States in Combination 4: State (ClassName, Title, Elements), Action (Methods, Touched Element) \n\niPhone    Android     Diff \n"];
    for (NSMutableDictionary* row in self.iphoneStatesAry){
        
        maxDif=100;
        for (NSMutableDictionary* row2 in self.androidStatesAry){
            
            //heuristics on class names
            NSString* n1 = [row[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
            n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
            n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
            n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
            NSString* n2 = [row2[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
            n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
            NSUInteger r1 = [n1 levenshteinDistanceToString:n2];
            //NSUInteger rr1 = [row[@"State_ClassName"] compareWithWord:row2[@"State_ClassName"]];
            
            NSUInteger r2 = 0;
            if (!([row[@"State_Title"] isEqualToString:@""] || [row2[@"State_Title"] isEqualToString:@""]))
                r2 = [row[@"State_Title"] levenshteinDistanceToString:row2[@"State_Title"]];
            
            NSUInteger sum = WEIGHT_S_CLASS*r1+WEIGHT_S_TITLE*r2+[self calculateElementsPairSimilarityE1:row[@"Elements"] withE2:row2[@"Elements"]]+[self calculateActionsPairSimilarityE1:row[@"Elements"] withE2:row2[@"Elements"]];
            
            //[self.similarityCsv appendString:[NSString stringWithFormat:@"%@ , %@, Dif: %tu \n",row[@"State_ID"],row2[@"State_ID"],sum]];
            
            if (sum < maxDif) {
                maxDif=sum;
                closestRow = row2;
            }
        }
        [self.similarityCsv appendString:[NSString stringWithFormat:@"%@        %@          %tu \n",row[@"State_ID"],closestRow[@"State_ID"],maxDif]];
    }
}

-(NSUInteger)calculateElementsPairSimilarityE1:(NSMutableArray*)iphoneElements withE2:(NSMutableArray*)androidElements
{
    NSUInteger totalSimilarity = 0;
    
    for (NSMutableDictionary* element1 in iphoneElements) {
    
        NSMutableDictionary * element2 = [self findCorrespondentAndroidElementTo:element1 inElements:androidElements];
        
        if (element2)
          totalSimilarity++;
    }
    return totalSimilarity;
}
    
- (NSMutableDictionary*) findCorrespondentAndroidElementTo:(NSMutableDictionary*)iphoneElement inElements:(NSMutableArray*)androidElements{
    
    NSMutableDictionary* correspondentElement=nil;
    for (NSMutableDictionary* element in androidElements) {
        if ([self mappedE1:iphoneElement withE2:element]){
            correspondentElement = element;
            break;
        }
    }
    
    return correspondentElement;
    
   //NSUInteger actionDif = [element1[@"UIElement_Action"] levenshteinDistanceToString:element2[@"UIElement_Action"]];
    //NSUInteger detailDif = [element1[@"UIElement_Details"] levenshteinDistanceToString:element2[@"UIElement_Details"]];
    //float similarity = WEIGHT_E_TITLE*labelDif + WEIGHT_E_ACTION*actionDif + WEIGHT_E_CLASS*typeDif + WEIGHT_E_DETAIL*detailDif;
    
}

-(float)mappedE1:(NSMutableDictionary*)iphoneE withE2:(NSMutableDictionary*)androidE
{
    float similarity = 0;
    
    NSString* iphoneElement = iphoneE[@"UIElement_Type"];
    NSString* androidElement = androidE[@"UIElement_Type"];
    
    //mona: add deatails label comparision here
    
    //string contains sub-string
    if (([iphoneElement rangeOfString:@"UIImageView"].location != NSNotFound) &&
        ([androidElement rangeOfString:@"ImageView"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UIButton"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Button"].location != NSNotFound)) {
        similarity = 1;
        if ([iphoneE[@"UIElement_Label"] levenshteinDistanceToString:androidE[@"UIElement_Label"]]<5)
            similarity++;
    }
    
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
             ([androidElement rangeOfString:@"TextView"].location != NSNotFound)) {
        similarity = 1;
    }
   
    else if (([iphoneElement rangeOfString:@"UITextView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"EditText"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UITextField"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"EditText"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UITableView"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"ListView"].location != NSNotFound)) {
        similarity = 1;
    }
    
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


-(NSUInteger)calculateActionsPairSimilarityE1:(NSMutableArray*)iphoneElements withE2:(NSMutableArray*)androidElements
{
    NSUInteger similarity = 0;

    return similarity;
}


#pragma mark - output methods

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

-(void)outputSimilarityCsvFile
{
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"SimilarityMapping.txt"]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [fileHandler seekToEndOfFile];
    [fileHandler writeData:[self.similarityCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

#pragma mark - setup methods

- (void)setupOutputFiles {
	//Grab and empty a reference to the output files
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"SimilarityMapping.txt"]];
	[@"" writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path1 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneEdges.csv"]];
	[@"" writeToFile:path1 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path2 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneElements.csv"]];
	[@"" writeToFile:path2 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path3 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneStates.csv"]];
	[@"" writeToFile:path3 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path4 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidEdges.csv"]];
	[@"" writeToFile:path4 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path5 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidElements.csv"]];
	[@"" writeToFile:path5 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path6 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/Mona/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidStates.csv"]];
	[@"" writeToFile:path6 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}


@end







