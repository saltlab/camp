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
#import "TFHpple.h"
#import "NSString+Levenshtein.h"

//Heuristical Weights and Threshold
#define WEIGHT_S_CLASS 1
#define WEIGHT_S_TITLE 1
#define WEIGHT_S_ELEMENTS 1
#define WEIGHT_E_CLASS 1
#define WEIGHT_E_TITLE 1
#define WEIGHT_E_DETAIL 1
#define WEIGHT_E_ACTION 1

@implementation MasterViewController

@synthesize iphoneXmlWriter, androidXmlWriter, edgePairs, statePairs, edgeMapId, stateMapId, elemMapId;
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
    
    self.iphoneXmlWriter = [[XMLWriter alloc]init];
    self.androidXmlWriter = [[XMLWriter alloc]init];
    self.edgePairs = [[NSMutableArray alloc]init];
    self.statePairs = [[NSMutableArray alloc]init];
    self.edgeMapId = 1;
    self.stateMapId = 1;
    self.elemMapId = 1;
    
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
                    
                    [self outputAndroidOriginalCsvFiles];
                    [self clusterAndroidStatesEdges];
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
                    
                    [self outputiPhoneOriginalCsvFile];
                    [self clusteriPhoneStatesEdges];
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

    [self.summaryLabel setStringValue:[NSString stringWithFormat:@"Android (%tu States, %tu Elements, %tu Edges) and iPhone(%tu States, %tu Elements, %tu Edges) are saved in ../Desktop/mapping-projects/CAMPChecker/outputFiles/", i,(unsigned long)j,(unsigned long)k,(unsigned long)l,(unsigned long)m,(unsigned long)n]];
    [self.view addSubview:self.summaryLabel];
    
    //calculate different combinations of properties and similarities
    [self outputInconsistencies];
    
}

-(void)parseStatesXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString
{
    NSMutableString* line = [[NSMutableString alloc] init];
    
    //add TimeStamp
    NSArray *timeStampNodes = [resultElement elementsForName:@"TimeStamp"];
    NSString *timeStamp = [[timeStampNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", timeStamp?[timeStamp stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add state ID
    NSArray *stateIdNodes = [resultElement elementsForName:@"State_ID"];
    NSString *stateId = [[stateIdNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", stateId?[stateId stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add class name
    NSArray *classNameNodes = [resultElement elementsForName:@"State_ClassName"];
    NSString *className = [[classNameNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", className?[className stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add title 
    NSArray *statusNodes = [resultElement elementsForName:@"State_Title"];
    NSString *bugStatus = [[statusNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", bugStatus?[bugStatus stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add screen shot path
    NSArray *screenshotNodes = [resultElement elementsForName:@"State_ScreenshotPath"];
    NSString *screenShot = [[screenshotNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,",screenShot?[screenShot stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];

    //add number of elements
    NSArray *elementsNumberNodes = [resultElement elementsForName:@"State_NumberOfElements"];
    NSString *elementsNumber = [[elementsNumberNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", elementsNumber?[elementsNumber stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    
    BOOL Flag = TRUE;
    for(int i=0; i< [[csvString componentsSeparatedByString:@"\n"] count]; i++) {
        NSString* line1 = [csvString componentsSeparatedByString:@"\n"][i];
        if ([line isEqualToString:line1]) {
            Flag = FALSE;
            break;
        }
    }
    if (Flag)
        [csvString appendString:[NSString stringWithFormat:@"%@\n",line]];

}

-(void)parseElementsXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    NSMutableString* line = [[NSMutableString alloc] init];
    
    //add state ID
    NSArray *stateIdNodes = [resultElement elementsForName:@"Parent_State_ID"];
    NSString *stateId = [[stateIdNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", stateId?[stateId stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add element ID
    NSArray *elementIdNodes = [resultElement elementsForName:@"UIElement_ID"];
    NSString *elementId = [[elementIdNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", elementId?[elementId stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add element type
    NSArray *elementTypeNodes = [resultElement elementsForName:@"UIElement_Type"];
    NSString *elementType = [[elementTypeNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", elementType?[elementType stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add element label
    NSArray *elementLabelNodes = [resultElement elementsForName:@"UIElement_Label"];
    NSString *elementLabel = [[elementLabelNodes objectAtIndex:0] stringValue];
    elementLabel = [elementLabel stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [line appendString:[NSString stringWithFormat:@"%@,", elementLabel?[elementLabel stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add element action
    NSArray *elementActionNodes = [resultElement elementsForName:@"UIElement_Action"];
    NSString *elementAction = [[elementActionNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", elementAction?[elementAction stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add element details
    NSArray *elementDetailsNodes = [resultElement elementsForName:@"UIElement_Details"];
    NSString *elementDetails = [[elementDetailsNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", elementDetails?[elementDetails stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    
//    BOOL Flag = TRUE;
//    for(int i=0; i< [[csvString componentsSeparatedByString:@"\n"] count]; i++) {
//        NSString* line1 = [csvString componentsSeparatedByString:@"\n"][i];
//        if ([line isEqualToString:line1]) {
//            Flag = FALSE;
//            break;
//        }
//    }
//    if (Flag)
        [csvString appendString:[NSString stringWithFormat:@"%@\n",line]];
    
}

-(void)parseEdgesXMLFiles:(CXMLElement*)resultElement appendTo:(NSMutableString*)csvString{
    
    NSMutableString* line = [[NSMutableString alloc] init];
    
    //add TimeStamp
    NSArray *timeStampNodes = [resultElement elementsForName:@"TimeStamp"];
    NSString *timeStamp = [[timeStampNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", timeStamp?[timeStamp stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add Source State ID
    NSArray *srcStateIdNodes = [resultElement elementsForName:@"Source_State_ID"];
    NSString *srcStateId = [[srcStateIdNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", srcStateId?[srcStateId stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    //add Target State ID
    NSArray *trgStateIdNodes = [resultElement elementsForName:@"Target_State_ID"];
    NSString *trgStateId = [[trgStateIdNodes objectAtIndex:0] stringValue];
    [line appendString:[NSString stringWithFormat:@"%@,", trgStateId?[trgStateId stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    
    NSArray* resultNodes = [resultElement elementsForName:@"TouchedElement"];
    CXMLElement* resultUIElement = resultNodes[0];
    
    if ([resultUIElement.children count]>0){
        //add element type
        NSArray *elementTypeNodes = [resultUIElement elementsForName:@"UIElement_Type"];
        NSString *elementType = [[elementTypeNodes objectAtIndex:0] stringValue];
        [line appendString:[NSString stringWithFormat:@"%@,", elementType?[elementType stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
        
        //add element label
        NSArray *elementLabelNodes = [resultUIElement elementsForName:@"UIElement_Label"];
        NSString *elementLabel = [[elementLabelNodes objectAtIndex:0] stringValue];
        elementLabel = [elementLabel stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        [line appendString:[NSString stringWithFormat:@"%@,", elementLabel?[elementLabel stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
        
        //add element action
        NSArray *elementActionNodes = [resultUIElement elementsForName:@"UIElement_Action"];
        NSString *elementAction = [[elementActionNodes objectAtIndex:0] stringValue];
        [line appendString:[NSString stringWithFormat:@"%@,", elementAction?[elementAction stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
        
        //add element details
        NSArray *elementDetailsNodes = [resultElement elementsForName:@"UIElement_Details"];
        NSString *elementDetails = [elementDetailsNodes count]?[[elementDetailsNodes objectAtIndex:0] stringValue]:@"";
        [line appendString:[NSString stringWithFormat:@"%@,", elementDetails?[elementDetails stringByReplacingOccurrencesOfString:@"," withString:@";"]:@""]];
    }
    else
        [line appendString:@",,,,"];
    
    //add methods
    resultNodes = [resultElement elementsForName:@"Methods"];
    NSArray *methodNodes = [resultNodes[0] elementsForName:@"Method"];
    for (CXMLElement* resultElement in methodNodes){
        NSString *methodDetails = [resultElement stringValue];
        [line appendString:[NSString stringWithFormat:@"%@;", [methodDetails stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
    }
    [line appendString:@","];
    
    BOOL Flag = TRUE;
    for(int i=0; i< [[csvString componentsSeparatedByString:@"\n"] count]; i++) {
        NSString* line1 = [csvString componentsSeparatedByString:@"\n"][i];
        if ([line isEqualToString:line1]) {
            Flag = FALSE;
            break;
        }
    }
    if (Flag)
        [csvString appendString:[NSString stringWithFormat:@"%@\n",line]];
    
}

-(void)clusteriPhoneStatesEdges
{
    BOOL flag = false;
    NSArray* rows = [self.iphoneStatesCsv componentsSeparatedByString:@"\n"];
    NSArray* elRows = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"];
    
    for (int i=1;i<rows.count-1;i++){
        NSString* row1 = [rows objectAtIndex:i];
        
        if([self.iphoneStatesCsv rangeOfString:row1 options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            NSArray* columns1 = [row1 componentsSeparatedByString:@","];
            
            for (int j=i+1;j<rows.count-1;j++){
                NSString* row2 = [rows objectAtIndex:j];
                NSArray* columns2 = [row2 componentsSeparatedByString:@","];
                if ([columns1[2] isEqualToString:columns2[2]]) {   //classnames
                    if ([columns1[5] isEqualToString:columns2[5]]) {  //number of UI elements are equal
                        
                        if ([columns1[1] isEqualToString:columns2[1]])  //remove duplicate States Ids
                            flag= true;
                        else if ([columns1[3] isEqualToString:columns2[3]]) //have same title
                            flag= true;
                        else
                            //compare the elements
                            for (int l=1;l<elRows.count-1;l++){
                                NSString* elRow1 = [elRows objectAtIndex:l];
                                NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                                
                                if ([columns1[1] isEqualToString:elColumns1[0]]) {
                                    for (int k=l+1;k<elRows.count-1;k++){
                                        NSString* elRow2 = [elRows objectAtIndex:k];
                                        NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                        if ([columns2[1] isEqualToString:elColumns2[0]]) {
                                            if ([elColumns1[1] isEqualToString:elColumns2[1]] && [elColumns1[2] isEqualToString:elColumns2[2]] ) { //Element ID, Type and (Action && [elColumns1[4] isEqualToString:elColumns2[4]])
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
                            if(![columns2[1] isEqualToString:columns1[1]]) {
                                NSArray* otherRows = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"];
                                for (NSString* otherRow1 in otherRows){
                                    if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns2[1]] options:NSCaseInsensitiveSearch].location != NSNotFound)
                                        self.iphoneElementsCsv = [[self.iphoneElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                                }
                            }
                        }
                    }
                    else {  //number of UI elements are NOT equal
                        
                        if ([columns1[5] intValue] > [columns2[5] intValue]) {
                            if ([columns1[1] isEqualToString:columns2[1]])  //remove duplicate States Ids
                                flag= true;
                            else
                                for (int l=1;l<elRows.count-1;l++){
                                    NSString* elRow1 = [elRows objectAtIndex:l];
                                    NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                                    
                                    if ([columns1[1] isEqualToString:elColumns1[0]]) {
                                        for (int k=l+1;k<elRows.count-1;k++){
                                            NSString* elRow2 = [elRows objectAtIndex:k];
                                            NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                            if ([columns2[1] isEqualToString:elColumns2[0]]) {
                                                if ([elColumns1[2] isEqualToString:elColumns2[2]] &&  [elColumns1[4] isEqualToString:elColumns2[4]]) { //Element Type and Action
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
                                if(![columns2[1] isEqualToString:columns1[1]]) {
                                    NSArray* otherRows = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"];
                                    for (NSString* otherRow1 in otherRows){
                                        if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns2[1]] options:NSCaseInsensitiveSearch].location != NSNotFound)
                                            self.iphoneElementsCsv = [[self.iphoneElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                                    }
                                }
                            }
                        }
                        else if ([columns1[5] intValue] < [columns2[5] intValue]){
                            if ([columns1[1] isEqualToString:columns2[1]])  //remove duplicate States Ids
                                flag= true;
                            else
                                for (int l=1;l<elRows.count-1;l++){
                                    NSString* elRow1 = [elRows objectAtIndex:l];
                                    NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                                    
                                    if ([columns1[1] isEqualToString:elColumns1[0]]) {
                                        for (int k=l+1;k<elRows.count-1;k++){
                                            NSString* elRow2 = [elRows objectAtIndex:k];
                                            NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                            if ([columns2[1] isEqualToString:elColumns2[0]]) {
                                                if ([elColumns1[2] isEqualToString:elColumns2[2]] &&  [elColumns1[4] isEqualToString:elColumns2[4]]) { //Element Type and Action
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
}

-(void)clusterAndroidStatesEdges
{
    BOOL flag = false;
    NSArray* rows = [self.androidStatesCsv componentsSeparatedByString:@"\n"];
    NSArray* elRows = [self.androidElementsCsv componentsSeparatedByString:@"\n"];
    
    for (int i=1;i<rows.count-1;i++){
        NSString* row1 = [rows objectAtIndex:i];
        
        if([self.androidStatesCsv rangeOfString:row1 options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            NSArray* columns1 = [row1 componentsSeparatedByString:@","];
            
            for (int j=i+1;j<rows.count-1;j++){
                NSString* row2 = [rows objectAtIndex:j];
                NSArray* columns2 = [row2 componentsSeparatedByString:@","];
                if ([columns1[2] isEqualToString:columns2[2]]) { // classnames
                    
                    if ([columns1[5] isEqualToString:columns2[5]]) {  //number of UI elements are equal
                        
                        if ([columns1[1] isEqualToString:columns2[1]]) //remove duplicate States Ids
                            flag= true;
                        else
                            //compare the elements
                            for (int l=1;l<elRows.count-1;l++){
                                NSString* elRow1 = [elRows objectAtIndex:l];
                                NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                                
                                if ([columns1[1] isEqualToString:elColumns1[0]]) {
                                    for (int k=l+1;k<elRows.count-1;k++){
                                        NSString* elRow2 = [elRows objectAtIndex:k];
                                        NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                        if ([columns2[1] isEqualToString:elColumns2[0]]) {
                                            if ([elColumns1[1] isEqualToString:elColumns2[1]] && [elColumns1[2] isEqualToString:elColumns2[2]] &&  [elColumns1[4] isEqualToString:elColumns2[4]]) { //Element ID, Type and Action
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
                            if(![columns2[1] isEqualToString:columns1[1]]) {
                                NSArray* otherRows = [self.androidElementsCsv componentsSeparatedByString:@"\n"];
                                for (NSString* otherRow1 in otherRows){
                                    if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns2[1]] options:NSCaseInsensitiveSearch].location != NSNotFound)
                                        self.androidElementsCsv = [[self.androidElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                                }
                            }
                        }
                    }
                    else {  //number of UI elements are NOT equal
                        
                        if ([columns1[5] intValue] > [columns2[5] intValue]) {
                            if ([columns1[1] isEqualToString:columns2[1]])  //remove duplicate States Ids
                                flag= true;
                            else
                                for (int l=1;l<elRows.count-1;l++){
                                    NSString* elRow1 = [elRows objectAtIndex:l];
                                    NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                                    
                                    if ([columns2[1] isEqualToString:elColumns1[0]]) {
                                        for (int k=l+1;k<elRows.count-1;k++){
                                            NSString* elRow2 = [elRows objectAtIndex:k];
                                            NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                            if ([columns1[1] isEqualToString:elColumns2[0]]) {
                                                if ([elColumns1[2] isEqualToString:elColumns2[2]] &&  [elColumns1[4] isEqualToString:elColumns2[4]]) { //Element Type and Action
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
                                if(![columns2[1] isEqualToString:columns1[1]]) {
                                    NSArray* otherRows = [self.androidElementsCsv componentsSeparatedByString:@"\n"];
                                    for (NSString* otherRow1 in otherRows){
                                        if([otherRow1 rangeOfString:[NSString stringWithFormat:@"%@,",columns2[1]] options:NSCaseInsensitiveSearch].location != NSNotFound)
                                            self.androidElementsCsv = [[self.androidElementsCsv stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n",otherRow1] withString:@""] mutableCopy];
                                    }
                                }
                            }
                        }
                        else if ([columns1[5] intValue] < [columns2[5] intValue]){
                            if ([columns1[1] isEqualToString:columns2[1]])   //remove duplicate States Ids
                                flag= true;
                            else
                                for (int l=1;l<elRows.count-1;l++){
                                    NSString* elRow1 = [elRows objectAtIndex:l];
                                    NSArray* elColumns1 = [elRow1 componentsSeparatedByString:@","];
                                    
                                    if ([columns1[1] isEqualToString:elColumns1[0]]) {
                                        for (int k=l+1;k<elRows.count-1;k++){
                                            NSString* elRow2 = [elRows objectAtIndex:k];
                                            NSArray* elColumns2 = [elRow2 componentsSeparatedByString:@","];
                                            if ([columns2[1] isEqualToString:elColumns2[0]]) {
                                                if ([elColumns1[2] isEqualToString:elColumns2[2]] &&  [elColumns1[4] isEqualToString:elColumns2[4]]) { //Element Type and Action
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
}

- (void)outputInconsistencies
{
    //get the android-iphone states and elements arrays
    [self getStateAndElementsArray];
    
    //get the android-iphone edges arrays
    [self getEdgesArray];
    
    //heuristic for Merging MoreViewsController in tab bar
    NSMutableArray* moreStates = [self findMoreViewsControllerState];
    for (NSMutableDictionary* moreState in moreStates){
        [self heuristicsOnMoreStateAndEdges:moreState];
    }
    
    [self.similarityCsv appendString:@"\n\n***iPhone Actions\nSrc -> Trg   TouchedElement(Type, Label, Action, Details)\n"];
    for (NSMutableDictionary* e in self.iphoneEdgesAry)
        //printout edges after checks
        [self.similarityCsv appendString:[NSString stringWithFormat:@"%@ -> %@      (%@, %@, %@, %@)\n",e[@"Source_State_ID"],e[@"Target_State_ID"],e[@"TouchedElement_Type"],e[@"TouchedElement_Label"],e[@"TouchedElement_Action"],e[@"TouchedElement_Details"]]];
    
    //Start Mapping: get the initial states
    [self.iphoneStatesAry[0] setObject:@1 forKey:@"Mapped"];
    NSMutableDictionary* iPhoneIntialState = self.iphoneStatesAry[0];
    [self.androidStatesAry[0] setObject:@1 forKey:@"Mapped"];
    NSMutableDictionary* androidIntialState = self.androidStatesAry[0];
    [self compareiPhoneState:iPhoneIntialState withAndroidState:androidIntialState];
    
    //get the initial edges
    self.edgePairs = [self compare1EdgePairsForiPhoneState:iPhoneIntialState andAndroidState:androidIntialState];
    
    //loop through all states, edges
    for (int i=0;i<self.edgePairs.count;i++){
        NSMutableDictionary* edgePair = [self.edgePairs objectAtIndex:i];
        
        if([edgePair[@"Mapped"] isEqualToNumber:@0]) {
            
            [self.similarityCsv appendString:@"\n***Closest Edges (Label, Action, Type)\n"];
            [self.similarityCsv appendString:[NSString stringWithFormat:@"iPhoneEdge: %@->%@ (%@, %@, %@) \nandroidEdge: %@->%@ (%@, %@, %@) \nMapping ID: %@\nDiff: %@ \n",edgePair[@"iPhone"][@"Source_State_ID"], edgePair[@"iPhone"][@"Target_State_ID"],edgePair[@"iPhone"][@"TouchedElement_Label"],edgePair[@"iPhone"][@"TouchedElement_Action"],edgePair[@"iPhone"][@"TouchedElement_Type"],edgePair[@"Android"][@"Source_State_ID"],edgePair[@"Android"][@"Target_State_ID"],edgePair[@"Android"][@"TouchedElement_Label"],edgePair[@"Android"][@"TouchedElement_Action"],edgePair[@"Android"][@"TouchedElement_Type"],edgePair[@"iPhone"][@"MappingLabel"], edgePair[@"Sum"]]];
        
            //Mark edge pair as mapped
            edgePair[@"Mapped"]=@1;
            NSMutableArray* nextEdgePairs = [self compareNextStates:edgePair];
            for (int k=0;k<nextEdgePairs.count;k++){
                NSMutableDictionary* nextEdgePair = [nextEdgePairs objectAtIndex:k];
                [self.edgePairs insertObject:nextEdgePair atIndex:i+k+1];
            }
        }
    }
    
    // Create paths to output xml files
    [self logPropertiesForEdges];
    [self logPropertiesForStates];
    [self outputiPhoneMappedFile:[self.iphoneXmlWriter toString]];
    [self outputAndroidMappedFile:[self.androidXmlWriter toString]];

    [self outputSimilarityCsvFile];
    
}

-(NSMutableArray*)findMoreViewsControllerState
{
    NSMutableArray* moreStatesAry = [[NSMutableArray alloc]init];
    for (NSMutableDictionary* s in self.iphoneStatesAry) {
        if([s[@"State_ClassName"] isEqualToString:@"MoreViewsController"]) {
            [moreStatesAry addObject:s];
        }
    }
    return moreStatesAry;
}

-(void)heuristicsOnMoreStateAndEdges:(NSMutableDictionary*)moreState
{
    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
    for (NSMutableDictionary* e in self.iphoneEdgesAry) {
        if([e[@"Target_State_ID"] isEqualToString:moreState[@"State_ID"]]) {
            NSInteger anIndex=[self.iphoneEdgesAry indexOfObject:e];
            NSMutableDictionary* nextEdge = (anIndex + 1 < self.iphoneEdgesAry.count) ?[self.iphoneEdgesAry objectAtIndex:anIndex+1]: nil;
            if (nextEdge) {
                e[@"Target_State_ID"] = nextEdge[@"Target_State_ID"];
                e[@"TouchedElement_Label"] = nextEdge[@"TouchedElement_Label"];
                [discardedItems addIndex:anIndex + 1];
            }
        }
    }
    [self.iphoneEdgesAry removeObjectsAtIndexes:discardedItems];
}

-(NSMutableArray*)compareNextStates:(NSMutableDictionary*)edgePair {
    
    NSMutableDictionary* iPhoneState = [self findState:edgePair[@"iPhone"][@"Target_State_ID"] inStates:self.iphoneStatesAry];
    NSMutableDictionary* androidState = [self findState:edgePair[@"Android"][@"Target_State_ID"] inStates:self.androidStatesAry];
    
    if (iPhoneState && androidState) {
        [self compareiPhoneState:iPhoneState withAndroidState:androidState];
        NSMutableArray* thisEdgePairs = [self compare1EdgePairsForiPhoneState:iPhoneState andAndroidState:androidState];
        return thisEdgePairs;
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

-(NSMutableDictionary*)findState2:(NSString*)stateId inStates:(NSArray*)statesAry
{
    for (NSMutableDictionary* s in statesAry) {
        if([s[@"State_ID"] isEqualToString:stateId]) {
            return s;
        }
    }
    return nil;
}


// combination 1 : ClassName
-(NSMutableArray*)compare1EdgePairsForiPhoneState:(NSMutableDictionary*)iPhoneState andAndroidState:(NSMutableDictionary*)androidState{
    
    NSMutableArray *thisEdgePairs = [NSMutableArray array];
    NSArray *iPhoneEdges =  [self getOutgoingEdgesFor:iPhoneState inEdges:self.iphoneEdgesAry];
    NSArray *androidEdges =  [self getOutgoingEdgesFor:androidState inEdges:self.androidEdgesAry];
    
    //To-Do: Sort edges array with TimeStamp
    
    //map outgoing edges
    if (iPhoneEdges.count <= androidEdges.count) {
        for (NSMutableDictionary* edge1 in iPhoneEdges) {
            
            NSMutableDictionary* iphoneTrgState = [self findState2:edge1[@"Target_State_ID"] inStates:self.iphoneStatesAry];
            
            if (![iphoneTrgState[@"State_ClassName"] isEqualToString:@""]) {
                
                NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                edgePair[@"iPhone"] = edge1;
                for (NSMutableDictionary* edge2 in androidEdges) {
                    
                    NSMutableDictionary* androidTrgState = [self findState2:edge2[@"Target_State_ID"] inStates:self.androidStatesAry];
                    
                    if ((![androidTrgState[@"State_ClassName"] isEqualToString:@""]) &&
                        (([edge2[@"Target_State_ID"] isEqualToString:edge2[@"Source_State_ID"]] && [edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]) ||
                         (![edge2[@"Target_State_ID"] isEqualToString: edge2[@"Source_State_ID"]] && ![edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]))) {
                        
                        //heuristic for ClassName (Activity == ViewController)
                        NSString* n1 = [iphoneTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
                        NSString* n2 = [androidTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSInteger r4 = [n1 levenshteinDistanceToString:n2];
                        
                        NSInteger max=n1.length;
                        if(n2.length>n1.length)
                            max=n2.length;
                        float sum = lroundf((WEIGHT_S_CLASS*((float)r4/(float)max))*100);
                        if (sum < maxDif) {
                            edgePair[@"Android"]=edge2;
                            edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                            edgePair[@"Mapped"]=@0;
                            maxDif = sum;
                        }
                    }
                }
                
                if (edgePair[@"Sum"]) {
                    
                    NSInteger thisEdgeMapId = self.edgeMapId++;
                    //TO DO: set the mapping color
                    edgePair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"Android"][@"MappingColor"]=edgePair[@"Sum"];
                    edgePair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"iPhone"][@"MappingColor"]=edgePair[@"Sum"];
                    
                    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
                    for (NSMutableDictionary* e in thisEdgePairs) {
                        
                        if (([e[@"Android"][@"TimeStamp"] isEqualToString:edgePair[@"Android"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"]) ||
                            ([e[@"iPhone"][@"TimeStamp"] isEqualToString:edgePair[@"iPhone"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"])){
                            NSInteger anIndex=[thisEdgePairs indexOfObject:e];
                            [discardedItems addIndex:anIndex];
                        }
                    }
                    if (discardedItems.count>0)
                        [thisEdgePairs removeObjectsAtIndexes:discardedItems];
                    [thisEdgePairs addObject:edgePair];
                }
            }
        }
    }
    else {
        for (NSMutableDictionary* edge1 in androidEdges) {
            
            NSMutableDictionary* androidTrgState = [self findState2:edge1[@"Target_State_ID"] inStates:self.androidStatesAry];
            
            if (![androidTrgState[@"State_ClassName"] isEqualToString:@""]) {
                
                NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                edgePair[@"Android"] = edge1;
                
                for (NSMutableDictionary* edge2 in iPhoneEdges) {
                    
                    NSMutableDictionary* iphoneTrgState = [self findState2:edge2[@"Target_State_ID"] inStates:self.iphoneStatesAry];
                    
                    if ((![iphoneTrgState[@"State_ClassName"] isEqualToString:@""]) &&
                        (([edge2[@"Target_State_ID"] isEqualToString:edge2[@"Source_State_ID"]] && [edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]) ||
                         (![edge2[@"Target_State_ID"] isEqualToString: edge2[@"Source_State_ID"]] && ![edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]))) {
                            
                        //heuristic for ClassName (Activity == ViewController)
                        NSString* n1 = [iphoneTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
                        NSString* n2 = [androidTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSUInteger r4 = [n1 levenshteinDistanceToString:n2];
                        
                        NSInteger max=n1.length;
                        if(n2.length>n1.length)
                            max=n2.length;
                        float sum = lroundf((WEIGHT_S_CLASS*((float)r4/(float)max))*100);
                        if (sum < maxDif) {
                            edgePair[@"iPhone"]=edge2;
                            edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                            edgePair[@"Mapped"]=@0;
                            maxDif = sum;
                        }
                    }
                }
                
                if (edgePair[@"Sum"]) {
                    
                    NSInteger thisEdgeMapId = self.edgeMapId++;
                    //TO DO: set the mapping color
                    edgePair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"Android"][@"MappingColor"]=edgePair[@"Sum"];
                    edgePair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"iPhone"][@"MappingColor"]=edgePair[@"Sum"];
                    
                    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
                    for (NSMutableDictionary* e in thisEdgePairs) {
                        
                        if (([e[@"Android"][@"TimeStamp"] isEqualToString:edgePair[@"Android"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"]) ||
                            ([e[@"iPhone"][@"TimeStamp"] isEqualToString:edgePair[@"iPhone"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"])){
                            NSInteger anIndex=[thisEdgePairs indexOfObject:e];
                            [discardedItems addIndex:anIndex];
                        }
                    }
                    if (discardedItems.count>0)
                        [thisEdgePairs removeObjectsAtIndexes:discardedItems];
                    [thisEdgePairs addObject:edgePair];
                }
            }
        }
    }
    return thisEdgePairs;
}


// combination 2 : Touched Element
-(NSMutableArray*)compare2EdgePairsForiPhoneState:(NSMutableDictionary*)iPhoneState andAndroidState:(NSMutableDictionary*)androidState{

    NSMutableArray *thisEdgePairs = [NSMutableArray array];
    NSArray *iPhoneEdges =  [self getOutgoingEdgesFor:iPhoneState inEdges:self.iphoneEdgesAry];
    NSArray *androidEdges =  [self getOutgoingEdgesFor:androidState inEdges:self.androidEdgesAry];
    
    //To-Do: Sort edges array with TimeStamp
    
    //map outgoing edges
    if (iPhoneEdges.count <= androidEdges.count) {
        for (NSMutableDictionary* edge1 in iPhoneEdges) {
            
            if (![edge1[@"TouchedElement_Action"] isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Label"]isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Type"]isEqualToString:@""]) {
                
                NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                edgePair[@"iPhone"] = edge1;
                for (NSMutableDictionary* edge2 in androidEdges) {
                    
                    if ((![edge2[@"TouchedElement_Action"] isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Label"]isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Type"]isEqualToString:@""]) &&
                        (([edge2[@"Target_State_ID"] isEqualToString:edge2[@"Source_State_ID"]] && [edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]) ||
                         (![edge2[@"Target_State_ID"] isEqualToString: edge2[@"Source_State_ID"]] && ![edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]))) {
                        
                        float rr1;
                        //heuristic for Actions (MenuItemClicked, ListViewCellClicked)
                        if(([edge1[@"TouchedElement_Action"] isEqualToString:@"tableCellClicked"] && [edge2[@"TouchedElement_Action"] isEqualToString:@"ListViewCellClicked"]) ||
                           ([edge1[@"TouchedElement_Action"] isEqualToString:@"itemClicked"] && [edge2[@"TouchedElement_Action"] isEqualToString:@"MenuItemClicked"]))
                            rr1 = 0;
                        
                        //heuristic for Action (MenuButtonClicked)
                        else if ([edge2[@"TouchedElement_Action"] isEqualToString:@"MenuButtonClicked"])
                            rr1 = 400;
                        
                        else {
                            rr1 = 0;
                            if ([edge1[@"TouchedElement_Action"] length]>0 || [edge2[@"TouchedElement_Action"] length]>0) {
                            NSInteger r1 = [edge1[@"TouchedElement_Action"] levenshteinDistanceToString:edge2[@"TouchedElement_Action"]];
                            NSInteger max=[edge1[@"TouchedElement_Action"] length];
                            if([edge2[@"TouchedElement_Action"] length]>[edge1[@"TouchedElement_Action"] length])
                                max=[edge2[@"TouchedElement_Action"] length];
                            rr1 = (WEIGHT_E_CLASS*((float)r1/(float)max));
                            }
                        }
                            
                        float rr2 = 0;
                        if ([edge1[@"TouchedElement_Label"] length]>0 || [edge2[@"TouchedElement_Label"] length]>0) {
                        NSInteger r2 = [edge1[@"TouchedElement_Label"] levenshteinDistanceToString:edge2[@"TouchedElement_Label"]];
                        NSInteger max=[edge1[@"TouchedElement_Label"] length];
                        if([edge2[@"TouchedElement_Label"] length]>[edge1[@"TouchedElement_Label"] length])
                            max=[edge2[@"TouchedElement_Label"] length];
                        rr2 = (WEIGHT_E_CLASS*((float)r2/(float)max));
                        }
                        
                        NSInteger r3 = [self mappedTypeE1:edge1[@"TouchedElement_Type"] withE2:edge2[@"TouchedElement_Type"]];
                        
                        NSInteger sum = lroundf(((WEIGHT_E_ACTION*rr1+WEIGHT_E_TITLE*rr2+WEIGHT_E_CLASS*r3)/3)*100);
                        if (sum < maxDif) {
                            edgePair[@"Android"]=edge2;
                            edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                            edgePair[@"Mapped"]=@0;
                            maxDif = sum;
                        }
                    }
                }
                
                if (edgePair[@"Sum"]) {
                    
                    NSInteger thisEdgeMapId = self.edgeMapId++;
                    //TO DO: set the mapping color
                    edgePair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"Android"][@"MappingColor"]=edgePair[@"Sum"];
                    edgePair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"iPhone"][@"MappingColor"]=edgePair[@"Sum"];
                    
                    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
                    for (NSMutableDictionary* e in thisEdgePairs) {
                        
                        if (([e[@"Android"][@"TimeStamp"] isEqualToString:edgePair[@"Android"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"]) ||
                            ([e[@"iPhone"][@"TimeStamp"] isEqualToString:edgePair[@"iPhone"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"])){
                            NSInteger anIndex=[thisEdgePairs indexOfObject:e];
                            [discardedItems addIndex:anIndex];
                        }
                    }
                    if (discardedItems.count>0)
                        [thisEdgePairs removeObjectsAtIndexes:discardedItems];
                    [thisEdgePairs addObject:edgePair];
                }
            }
        }
    }
    else {
        for (NSMutableDictionary* edge1 in androidEdges) {
            
            if (![edge1[@"TouchedElement_Action"] isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Label"]isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Type"]isEqualToString:@""]) {
                
                NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                edgePair[@"Android"] = edge1;
                
                for (NSMutableDictionary* edge2 in iPhoneEdges) {
                    
                    if ((![edge2[@"TouchedElement_Action"] isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Label"]isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Type"]isEqualToString:@""]) &&
                        (([edge2[@"Target_State_ID"] isEqualToString:edge2[@"Source_State_ID"]] && [edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]) ||
                         (![edge2[@"Target_State_ID"] isEqualToString: edge2[@"Source_State_ID"]] && ![edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]))) {
                        
                        float rr1;
                        //heuristic for Actions (MenuItemClicked, ListViewCellClicked)
                        if(([edge2[@"TouchedElement_Action"] isEqualToString:@"tableCellClicked"] && [edge1[@"TouchedElement_Action"] isEqualToString:@"ListViewCellClicked"]) ||
                           ([edge2[@"TouchedElement_Action"] isEqualToString:@"itemClicked"] && [edge1[@"TouchedElement_Action"] isEqualToString:@"MenuItemClicked"]))
                            rr1 = 0;
                        
                        //heuristic for Action (MenuButtonClicked)
                        else if ([edge1[@"TouchedElement_Action"] isEqualToString:@"MenuButtonClicked"])
                            rr1 = 400;
                        
                        else {
                            rr1 = 0;
                            if ([edge1[@"TouchedElement_Action"] length]>0 || [edge2[@"TouchedElement_Action"] length]>0) {
                            NSInteger r1 = [edge1[@"TouchedElement_Action"] levenshteinDistanceToString:edge2[@"TouchedElement_Action"]];
                            NSInteger max=[edge1[@"TouchedElement_Action"] length];
                            if([edge2[@"TouchedElement_Action"] length]>[edge1[@"TouchedElement_Action"] length])
                                max=[edge2[@"TouchedElement_Action"] length];
                            rr1 = (WEIGHT_E_CLASS*((float)r1/(float)max));
                            }
                        }
                         
                        float rr2 = 0;
                        if ([edge1[@"TouchedElement_Label"] length]>0 || [edge2[@"TouchedElement_Label"] length]>0) {
                        NSInteger r2 = [edge1[@"TouchedElement_Label"] levenshteinDistanceToString:edge2[@"TouchedElement_Label"]];
                        NSInteger max=[edge1[@"TouchedElement_Label"] length];
                        if([edge2[@"TouchedElement_Label"] length]>[edge1[@"TouchedElement_Label"] length])
                            max=[edge2[@"TouchedElement_Label"] length];
                        rr2 = (WEIGHT_E_CLASS*((float)r2/(float)max));
                        }
                            
                        NSInteger r3 = [self mappedTypeE1:edge2[@"TouchedElement_Type"] withE2:edge1[@"TouchedElement_Type"]];
                        
                        NSInteger sum = lroundf(((WEIGHT_E_ACTION*rr1+WEIGHT_E_TITLE*rr2+WEIGHT_E_CLASS*r3)/3)*100);
                        if (sum < maxDif) {
                            edgePair[@"iPhone"]=edge2;
                            edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                            edgePair[@"Mapped"]=@0;
                            maxDif = sum;
                        }
                    }
                }
                
                if (edgePair[@"Sum"]) {
                    
                    NSInteger thisEdgeMapId = self.edgeMapId++;
                    //TO DO: set the mapping color
                    edgePair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"Android"][@"MappingColor"]=edgePair[@"Sum"];
                    edgePair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"iPhone"][@"MappingColor"]=edgePair[@"Sum"];
                    
                    
                    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
                    for (NSMutableDictionary* e in thisEdgePairs) {
                        
                        if (([e[@"Android"][@"TimeStamp"] isEqualToString:edgePair[@"Android"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"]) ||
                            ([e[@"iPhone"][@"TimeStamp"] isEqualToString:edgePair[@"iPhone"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"])){
                            NSInteger anIndex=[thisEdgePairs indexOfObject:e];
                            [discardedItems addIndex:anIndex];
                        }
                    }
                    if (discardedItems.count>0)
                        [thisEdgePairs removeObjectsAtIndexes:discardedItems];
                    [thisEdgePairs addObject:edgePair];
                }
            }
        }
    }
    return thisEdgePairs;
}


// combination 3 : Touched Element + Classname
-(NSMutableArray*)compare3EdgePairsForiPhoneState:(NSMutableDictionary*)iPhoneState andAndroidState:(NSMutableDictionary*)androidState{
    
    NSMutableArray *thisEdgePairs = [NSMutableArray array];
    NSArray *iPhoneEdges =  [self getOutgoingEdgesFor:iPhoneState inEdges:self.iphoneEdgesAry];
    NSArray *androidEdges =  [self getOutgoingEdgesFor:androidState inEdges:self.androidEdgesAry];
    
    //To-Do: Sort edges array with TimeStamp
    
    //map outgoing edges
    if (iPhoneEdges.count <= androidEdges.count) {
        for (NSMutableDictionary* edge1 in iPhoneEdges) {
            
            NSMutableDictionary* iphoneTrgState = [self findState2:edge1[@"Target_State_ID"] inStates:self.iphoneStatesAry];
            
            if (![edge1[@"TouchedElement_Action"] isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Label"]isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Type"]isEqualToString:@""] ||
                ![iphoneTrgState[@"State_ClassName"] isEqualToString:@""]) {
                
                NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                edgePair[@"iPhone"] = edge1;
                for (NSMutableDictionary* edge2 in androidEdges) {
                    
                    NSMutableDictionary* androidTrgState = [self findState2:edge2[@"Target_State_ID"] inStates:self.androidStatesAry];
                    
                    if ((![edge2[@"TouchedElement_Action"] isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Label"]isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Type"]isEqualToString:@""] ||
                        ![androidTrgState[@"State_ClassName"] isEqualToString:@""]) &&
                        (([edge2[@"Target_State_ID"] isEqualToString:edge2[@"Source_State_ID"]] && [edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]) ||
                         (![edge2[@"Target_State_ID"] isEqualToString: edge2[@"Source_State_ID"]] && ![edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]))) {
                        
                        float rr1;
                        NSInteger max;
                        //heuristic for Actions (MenuItemClicked, ListViewCellClicked)
                        if(([edge1[@"TouchedElement_Action"] isEqualToString:@"tableCellClicked"] && [edge2[@"TouchedElement_Action"] isEqualToString:@"ListViewCellClicked"]) ||
                           ([edge1[@"TouchedElement_Action"] isEqualToString:@"itemClicked"] && [edge2[@"TouchedElement_Action"] isEqualToString:@"MenuItemClicked"]))
                            rr1 = 0;
                        
                        //heuristic for Action (MenuButtonClicked)
                        else if ([edge2[@"TouchedElement_Action"] isEqualToString:@"MenuButtonClicked"])
                            rr1 = 400;
                        
                        else {
                            rr1 = 0;
                            if ([edge1[@"TouchedElement_Action"] length]>0 || [edge2[@"TouchedElement_Action"] length]>0) {
                            NSInteger r1 = [edge1[@"TouchedElement_Action"] levenshteinDistanceToString:edge2[@"TouchedElement_Action"]];
                            max=[edge1[@"TouchedElement_Action"] length];
                            if([edge2[@"TouchedElement_Action"] length]>[edge1[@"TouchedElement_Action"] length])
                                max=[edge2[@"TouchedElement_Action"] length];
                            rr1 = (WEIGHT_E_CLASS*((float)r1/(float)max));
                            }
                        }
                        
                        float rr2 = 0;
                        if ([edge1[@"TouchedElement_Label"] length]>0 || [edge2[@"TouchedElement_Label"] length]>0) {
                        NSInteger r2 = [edge1[@"TouchedElement_Label"] levenshteinDistanceToString:edge2[@"TouchedElement_Label"]];
                        max=[edge1[@"TouchedElement_Label"] length];
                        if([edge2[@"TouchedElement_Label"] length]>[edge1[@"TouchedElement_Label"] length])
                            max=[edge2[@"TouchedElement_Label"] length];
                        rr2 = (WEIGHT_E_CLASS*((float)r2/(float)max));
                        }
                            
                        NSInteger r3 = [self mappedTypeE1:edge1[@"TouchedElement_Type"] withE2:edge2[@"TouchedElement_Type"]];
                        
                        //heuristic for ClassName (Activity == ViewController)
                        NSString* n1 = [iphoneTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
                        NSString* n2 = [androidTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSUInteger r4 = [n1 levenshteinDistanceToString:n2];
                        max=n1.length;
                        if(n2.length>n1.length)
                            max=n2.length;
                        float rr4 = (WEIGHT_S_CLASS*((float)r4/(float)max));
                            
                        NSInteger sum = lroundf(((WEIGHT_E_ACTION*rr1+WEIGHT_E_TITLE*rr2+WEIGHT_E_CLASS*r3+WEIGHT_S_CLASS*rr4)/4)*100);
                        if (sum < maxDif) {
                            edgePair[@"Android"]=edge2;
                            edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                            edgePair[@"Mapped"]=@0;
                            maxDif = sum;
                        }
                    }
                }
                
                if (edgePair[@"Sum"]) {
                    
                    NSInteger thisEdgeMapId = self.edgeMapId++;
                    //TO DO: set the mapping color
                    edgePair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"Android"][@"MappingColor"]=edgePair[@"Sum"];
                    edgePair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"iPhone"][@"MappingColor"]=edgePair[@"Sum"];
                    
                    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
                    for (NSMutableDictionary* e in thisEdgePairs) {
                        
                        if (([e[@"Android"][@"TimeStamp"] isEqualToString:edgePair[@"Android"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"]) ||
                            ([e[@"iPhone"][@"TimeStamp"] isEqualToString:edgePair[@"iPhone"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"])){
                            NSInteger anIndex=[thisEdgePairs indexOfObject:e];
                            [discardedItems addIndex:anIndex];
                        }
                    }
                    if (discardedItems.count>0)
                        [thisEdgePairs removeObjectsAtIndexes:discardedItems];
                    [thisEdgePairs addObject:edgePair];
                }
            }
        }
    }
    else {
        for (NSMutableDictionary* edge1 in androidEdges) {
            
            NSMutableDictionary* androidTrgState = [self findState2:edge1[@"Target_State_ID"] inStates:self.androidStatesAry];
            
            if (![edge1[@"TouchedElement_Action"] isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Label"]isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Type"]isEqualToString:@""] ||
                ![androidTrgState[@"State_ClassName"] isEqualToString:@""]) {
                
                NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                edgePair[@"Android"] = edge1;
                
                for (NSMutableDictionary* edge2 in iPhoneEdges) {
                    
                    NSMutableDictionary* iphoneTrgState = [self findState2:edge2[@"Target_State_ID"] inStates:self.iphoneStatesAry];
                    
                    if ((![edge2[@"TouchedElement_Action"] isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Label"]isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Type"]isEqualToString:@""] ||
                        ![iphoneTrgState[@"State_ClassName"] isEqualToString:@""]) &&
                        (([edge2[@"Target_State_ID"] isEqualToString:edge2[@"Source_State_ID"]] && [edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]) ||
                         (![edge2[@"Target_State_ID"] isEqualToString: edge2[@"Source_State_ID"]] && ![edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]))) {
                        
                        float rr1;
                        NSInteger max;
                        //heuristic for Actions (MenuItemClicked, ListViewCellClicked)
                        if(([edge2[@"TouchedElement_Action"] isEqualToString:@"tableCellClicked"] && [edge1[@"TouchedElement_Action"] isEqualToString:@"ListViewCellClicked"]) ||
                           ([edge2[@"TouchedElement_Action"] isEqualToString:@"itemClicked"] && [edge1[@"TouchedElement_Action"] isEqualToString:@"MenuItemClicked"]))
                            rr1 = 0;
                        
                        //heuristic for Action (MenuButtonClicked)
                        else if ([edge1[@"TouchedElement_Action"] isEqualToString:@"MenuButtonClicked"])
                            rr1 = 400;
                        
                        else{
                            rr1 = 0;
                            if ([edge1[@"TouchedElement_Action"] length]>0 || [edge2[@"TouchedElement_Action"] length]>0) {
                            NSInteger r1 = [edge1[@"TouchedElement_Action"] levenshteinDistanceToString:edge2[@"TouchedElement_Action"]];
                            max=[edge1[@"TouchedElement_Action"] length];
                            if([edge2[@"TouchedElement_Action"] length]>[edge1[@"TouchedElement_Action"] length])
                                max=[edge2[@"TouchedElement_Action"] length];
                            rr1 = (WEIGHT_E_CLASS*((float)r1/(float)max));
                            }
                        }
                            
                        float rr2 = 0;
                        if ([edge1[@"TouchedElement_Label"] length]>0 || [edge2[@"TouchedElement_Label"] length]>0) {
                        NSInteger r2 = [edge1[@"TouchedElement_Label"] levenshteinDistanceToString:edge2[@"TouchedElement_Label"]];
                        max=[edge1[@"TouchedElement_Label"] length];
                        if([edge2[@"TouchedElement_Label"] length]>[edge1[@"TouchedElement_Label"] length])
                            max=[edge2[@"TouchedElement_Label"] length];
                        rr2 = (WEIGHT_E_CLASS*((float)r2/(float)max));
                        }
                        
                        NSInteger r3 = [self mappedTypeE1:edge2[@"TouchedElement_Type"] withE2:edge1[@"TouchedElement_Type"]];
                        
                        //heuristic for ClassName (Activity == ViewController)
                        NSString* n1 = [iphoneTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
                        NSString* n2 = [androidTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSUInteger r4 = [n1 levenshteinDistanceToString:n2];
                        max=n1.length;
                        if(n2.length>n1.length)
                            max=n2.length;
                        float rr4 = (WEIGHT_S_CLASS*((float)r4/(float)max));
                        
                        NSInteger sum = lroundf(((WEIGHT_E_ACTION*rr1+WEIGHT_E_TITLE*rr2+WEIGHT_E_CLASS*r3+WEIGHT_S_CLASS*rr4)/4)*100);
                        if (sum < maxDif) {
                            edgePair[@"iPhone"]=edge2;
                            edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                            edgePair[@"Mapped"]=@0;
                            maxDif = sum;
                        }
                    }
                }
                
                if (edgePair[@"Sum"]) {
                    
                    NSInteger thisEdgeMapId = self.edgeMapId++;
                    //TO DO: set the mapping color
                    edgePair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"Android"][@"MappingColor"]=edgePair[@"Sum"];
                    edgePair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"iPhone"][@"MappingColor"]=edgePair[@"Sum"];
                    
                    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
                    for (NSMutableDictionary* e in thisEdgePairs) {
                        
                        if (([e[@"Android"][@"TimeStamp"] isEqualToString:edgePair[@"Android"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"]) ||
                            ([e[@"iPhone"][@"TimeStamp"] isEqualToString:edgePair[@"iPhone"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"])){
                            NSInteger anIndex=[thisEdgePairs indexOfObject:e];
                            [discardedItems addIndex:anIndex];
                        }
                    }
                    if (discardedItems.count>0)
                        [thisEdgePairs removeObjectsAtIndexes:discardedItems];
                    [thisEdgePairs addObject:edgePair];
                }
            }
        }
    }
    return thisEdgePairs;
}


// combination 4 : Touched Element + Classname + Title
-(NSMutableArray*)compare4EdgePairsForiPhoneState:(NSMutableDictionary*)iPhoneState andAndroidState:(NSMutableDictionary*)androidState{
    
    NSMutableArray *thisEdgePairs = [NSMutableArray array];
    NSArray *iPhoneEdges =  [self getOutgoingEdgesFor:iPhoneState inEdges:self.iphoneEdgesAry];
    NSArray *androidEdges =  [self getOutgoingEdgesFor:androidState inEdges:self.androidEdgesAry];
    
    //To-Do: Sort edges array with TimeStamp
    
    //map outgoing edges
    if (iPhoneEdges.count <= androidEdges.count) {
        for (NSMutableDictionary* edge1 in iPhoneEdges) {
            
            NSMutableDictionary* iphoneTrgState = [self findState2:edge1[@"Target_State_ID"] inStates:self.iphoneStatesAry];
            
            if (![edge1[@"TouchedElement_Action"] isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Label"]isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Type"]isEqualToString:@""] ||
                ![iphoneTrgState[@"State_ClassName"] isEqualToString:@""] ||
                ![iphoneTrgState[@"State_Title"] isEqualToString:@""]) {
                
                NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                edgePair[@"iPhone"] = edge1;
                for (NSMutableDictionary* edge2 in androidEdges) {
                    
                    NSMutableDictionary* androidTrgState = [self findState2:edge2[@"Target_State_ID"] inStates:self.androidStatesAry];
                    
                    if ((![edge2[@"TouchedElement_Action"] isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Label"]isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Type"]isEqualToString:@""] ||
                         ![androidTrgState[@"State_ClassName"] isEqualToString:@""] ||
                         ![androidTrgState[@"State_Title"] isEqualToString:@""] ||
                        ![androidTrgState[@"State_Title"] isEqualToString:@""]) &&
                        (([edge2[@"Target_State_ID"] isEqualToString:edge2[@"Source_State_ID"]] && [edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]) ||
                         (![edge2[@"Target_State_ID"] isEqualToString: edge2[@"Source_State_ID"]] && ![edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]))) {
                        
                        float rr1;
                        NSInteger max;
                        //heuristic for Actions (MenuItemClicked, ListViewCellClicked)
                        if(([edge1[@"TouchedElement_Action"] isEqualToString:@"tableCellClicked"] && [edge2[@"TouchedElement_Action"] isEqualToString:@"ListViewCellClicked"]) ||
                           ([edge1[@"TouchedElement_Action"] isEqualToString:@"itemClicked"] && [edge2[@"TouchedElement_Action"] isEqualToString:@"MenuItemClicked"]))
                            rr1 = 0;
                        
                        //heuristic for Action (MenuButtonClicked)
                        else if ([edge2[@"TouchedElement_Action"] isEqualToString:@"MenuButtonClicked"])
                            rr1 = 400;
                        
                        else {
                            rr1 = 0;
                            if ([edge1[@"TouchedElement_Action"] length]>0 || [edge2[@"TouchedElement_Action"] length]>0) {
                            NSInteger r1 = [edge1[@"TouchedElement_Action"] levenshteinDistanceToString:edge2[@"TouchedElement_Action"]];
                            max=[edge1[@"TouchedElement_Action"] length];
                            if([edge2[@"TouchedElement_Action"] length]>[edge1[@"TouchedElement_Action"] length])
                                max=[edge2[@"TouchedElement_Action"] length];
                            rr1 = (WEIGHT_E_CLASS*((float)r1/(float)max));
                            }
                        }
                            
                        float rr2 = 0;
                        if ([edge1[@"TouchedElement_Label"] length]>0 || [edge2[@"TouchedElement_Label"] length]>0) {
                        NSInteger r2 = [edge1[@"TouchedElement_Label"] levenshteinDistanceToString:edge2[@"TouchedElement_Label"]];
                        max=[edge1[@"TouchedElement_Label"] length];
                        if([edge2[@"TouchedElement_Label"] length]>[edge1[@"TouchedElement_Label"] length])
                            max=[edge2[@"TouchedElement_Label"] length];
                        rr2 = (WEIGHT_E_CLASS*((float)r2/(float)max));
                        }
                            
                        NSInteger r3 = [self mappedTypeE1:edge1[@"TouchedElement_Type"] withE2:edge2[@"TouchedElement_Type"]];
                        
                        //heuristic for ClassName (Activity == ViewController)
                        NSString* n1 = [iphoneTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
                        NSString* n2 = [androidTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSUInteger r4 = [n1 levenshteinDistanceToString:n2];
                        max=n1.length;
                        if(n2.length>n1.length)
                            max=n2.length;
                        float rr4 = (WEIGHT_S_CLASS*((float)r4/(float)max));
                          
                        float rr5 = 0;
                        if ([iphoneTrgState[@"State_Title"] length]>0 || [androidTrgState[@"State_Title"] length]>0) {
                        NSUInteger r5 = [iphoneTrgState[@"State_Title"] levenshteinDistanceToString:androidTrgState[@"State_Title"]];
                        max=[iphoneTrgState[@"State_Title"] length];
                        if([androidTrgState[@"State_Title"] length]>[iphoneTrgState[@"State_Title"] length])
                            max=[androidTrgState[@"State_Title"] length];
                        rr5 = (WEIGHT_S_CLASS*((float)r5/(float)max));
                        }
                            
                        NSInteger sum = lroundf(((WEIGHT_E_ACTION*rr1+WEIGHT_E_TITLE*rr2+WEIGHT_E_CLASS*r3+WEIGHT_S_CLASS*rr4+WEIGHT_S_TITLE*rr5)/5)*100);
                        if (sum < maxDif) {
                            edgePair[@"Android"]=edge2;
                            edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                            edgePair[@"Mapped"]=@0;
                            maxDif = sum;
                        }
                    }
                }
                
                if (edgePair[@"Sum"]) {
                    
                    NSInteger thisEdgeMapId = self.edgeMapId++;
                    //TO DO: set the mapping color
                    edgePair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"Android"][@"MappingColor"]=edgePair[@"Sum"];
                    edgePair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"iPhone"][@"MappingColor"]=edgePair[@"Sum"];
                    
                    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
                    for (NSMutableDictionary* e in thisEdgePairs) {
                        
                        if (([e[@"Android"][@"TimeStamp"] isEqualToString:edgePair[@"Android"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"]) ||
                            ([e[@"iPhone"][@"TimeStamp"] isEqualToString:edgePair[@"iPhone"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"])){
                            NSInteger anIndex=[thisEdgePairs indexOfObject:e];
                            [discardedItems addIndex:anIndex];
                        }
                    }
                    if (discardedItems.count>0)
                        [thisEdgePairs removeObjectsAtIndexes:discardedItems];
                    [thisEdgePairs addObject:edgePair];
                }
            }
        }
    }
    else {
        for (NSMutableDictionary* edge1 in androidEdges) {
            
            NSMutableDictionary* androidTrgState = [self findState2:edge1[@"Target_State_ID"] inStates:self.androidStatesAry];
            
            if (![edge1[@"TouchedElement_Action"] isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Label"]isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Type"]isEqualToString:@""] ||
                ![androidTrgState[@"State_ClassName"] isEqualToString:@""] ||
                ![androidTrgState[@"State_Title"] isEqualToString:@""]) {
                
                NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                edgePair[@"Android"] = edge1;
                
                for (NSMutableDictionary* edge2 in iPhoneEdges) {
                    
                    NSMutableDictionary* iphoneTrgState = [self findState2:edge2[@"Target_State_ID"] inStates:self.iphoneStatesAry];
                    
                    if ((![edge2[@"TouchedElement_Action"] isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Label"]isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Type"]isEqualToString:@""] ||
                        ![iphoneTrgState[@"State_ClassName"] isEqualToString:@""] ||
                        ![iphoneTrgState[@"State_Title"] isEqualToString:@""]) &&
                        (([edge2[@"Target_State_ID"] isEqualToString:edge2[@"Source_State_ID"]] && [edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]) ||
                         (![edge2[@"Target_State_ID"] isEqualToString: edge2[@"Source_State_ID"]] && ![edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]))) {
                        
                        float rr1;
                        NSInteger max;
                        //heuristic for Actions (MenuItemClicked, ListViewCellClicked)
                        if(([edge2[@"TouchedElement_Action"] isEqualToString:@"tableCellClicked"] && [edge1[@"TouchedElement_Action"] isEqualToString:@"ListViewCellClicked"]) ||
                           ([edge2[@"TouchedElement_Action"] isEqualToString:@"itemClicked"] && [edge1[@"TouchedElement_Action"] isEqualToString:@"MenuItemClicked"]))
                            rr1 = 0;
                        
                        //heuristic for Action (MenuButtonClicked)
                        else if ([edge1[@"TouchedElement_Action"] isEqualToString:@"MenuButtonClicked"])
                            rr1 = 400;
                        
                        else {
                            rr1 = 0;
                            if ([edge1[@"TouchedElement_Action"] length]>0 || [edge2[@"TouchedElement_Action"] length]>0) {
                            NSInteger r1 = [edge1[@"TouchedElement_Action"] levenshteinDistanceToString:edge2[@"TouchedElement_Action"]];
                            max=[edge1[@"TouchedElement_Action"] length];
                            if([edge2[@"TouchedElement_Action"] length]>[edge1[@"TouchedElement_Action"] length])
                                max=[edge2[@"TouchedElement_Action"] length];
                            rr1 = (WEIGHT_E_CLASS*((float)r1/(float)max));
                            }
                        }
                            
                        float rr2 = 0;
                        if ([edge1[@"TouchedElement_Label"] length]>0 || [edge2[@"TouchedElement_Label"] length]>0) {
                        NSInteger r2 = [edge1[@"TouchedElement_Label"] levenshteinDistanceToString:edge2[@"TouchedElement_Label"]];
                        max=[edge1[@"TouchedElement_Label"] length];
                        if([edge2[@"TouchedElement_Label"] length]>[edge1[@"TouchedElement_Label"] length])
                            max=[edge2[@"TouchedElement_Label"] length];
                        rr2 = (WEIGHT_E_CLASS*((float)r2/(float)max));
                        }
                            
                        NSInteger r3 = [self mappedTypeE1:edge2[@"TouchedElement_Type"] withE2:edge1[@"TouchedElement_Type"]];
                        
                        //heuristic for ClassName (Activity == ViewController)
                        NSString* n1 = [iphoneTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
                        NSString* n2 = [androidTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSUInteger r4 = [n1 levenshteinDistanceToString:n2];
                        max=n1.length;
                        if(n2.length>n1.length)
                            max=n2.length;
                        float rr4 = (WEIGHT_S_CLASS*((float)r4/(float)max));
                            
                        float rr5 = 0;
                        if ([iphoneTrgState[@"State_Title"] length]>0 || [androidTrgState[@"State_Title"] length]>0) {
                        NSUInteger r5 = [iphoneTrgState[@"State_Title"] levenshteinDistanceToString:androidTrgState[@"State_Title"]];
                        max=[iphoneTrgState[@"State_Title"] length];
                        if([androidTrgState[@"State_Title"] length]>[iphoneTrgState[@"State_Title"] length])
                            max=[androidTrgState[@"State_Title"] length];
                        rr5 = (WEIGHT_S_CLASS*((float)r5/(float)max));
                        }
                            
                        NSInteger sum = lroundf(((WEIGHT_E_ACTION*rr1+WEIGHT_E_TITLE*rr2+WEIGHT_E_CLASS*r3+WEIGHT_S_CLASS*rr4+WEIGHT_S_TITLE*rr5)/5)*100);
                        if (sum < maxDif) {
                            edgePair[@"iPhone"]=edge2;
                            edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                            edgePair[@"Mapped"]=@0;
                            maxDif = sum;
                        }
                    }
                }
                
                if (edgePair[@"Sum"]) {
                    
                    NSInteger thisEdgeMapId = self.edgeMapId++;
                    //TO DO: set the mapping color
                    edgePair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"Android"][@"MappingColor"]=edgePair[@"Sum"];
                    edgePair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"iPhone"][@"MappingColor"]=edgePair[@"Sum"];
                    
                    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
                    for (NSMutableDictionary* e in thisEdgePairs) {
                        
                        if (([e[@"Android"][@"TimeStamp"] isEqualToString:edgePair[@"Android"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"]) ||
                            ([e[@"iPhone"][@"TimeStamp"] isEqualToString:edgePair[@"iPhone"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"])){
                            NSInteger anIndex=[thisEdgePairs indexOfObject:e];
                            [discardedItems addIndex:anIndex];
                        }
                    }
                    if (discardedItems.count>0)
                        [thisEdgePairs removeObjectsAtIndexes:discardedItems];
                    [thisEdgePairs addObject:edgePair];
                }
            }
        }
    }
    return thisEdgePairs;
}


// combination 5 : Touched Element + Classname + Title + UIElements
-(NSMutableArray*)compare5EdgePairsForiPhoneState:(NSMutableDictionary*)iPhoneState andAndroidState:(NSMutableDictionary*)androidState{
    
    NSMutableArray *thisEdgePairs = [NSMutableArray array];
    NSArray *iPhoneEdges =  [self getOutgoingEdgesFor:iPhoneState inEdges:self.iphoneEdgesAry];
    NSArray *androidEdges =  [self getOutgoingEdgesFor:androidState inEdges:self.androidEdgesAry];
    
    //To-Do: Sort edges array with TimeStamp
    
    //map outgoing edges
    if (iPhoneEdges.count <= androidEdges.count) {
        for (NSMutableDictionary* edge1 in iPhoneEdges) {
            
            NSMutableDictionary* iphoneTrgState = [self findState2:edge1[@"Target_State_ID"] inStates:self.iphoneStatesAry];
            
            if (![edge1[@"TouchedElement_Action"] isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Label"]isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Type"]isEqualToString:@""] ||
                ![iphoneTrgState[@"State_ClassName"] isEqualToString:@""] ||
                ![iphoneTrgState[@"State_Title"] isEqualToString:@""]) {
                
                NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                edgePair[@"iPhone"] = edge1;
                for (NSMutableDictionary* edge2 in androidEdges) {
                    
                    NSMutableDictionary* androidTrgState = [self findState2:edge2[@"Target_State_ID"] inStates:self.androidStatesAry];
                    
                    if ((![edge2[@"TouchedElement_Action"] isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Label"]isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Type"]isEqualToString:@""] ||
                        ![androidTrgState[@"State_ClassName"] isEqualToString:@""] ||
                        ![androidTrgState[@"State_Title"] isEqualToString:@""]) &&
                        (([edge2[@"Target_State_ID"] isEqualToString:edge2[@"Source_State_ID"]] && [edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]) ||
                         (![edge2[@"Target_State_ID"] isEqualToString: edge2[@"Source_State_ID"]] && ![edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]))) {
                        
                        float rr1;
                        NSInteger max;
                        //heuristic for Actions (MenuItemClicked, ListViewCellClicked)
                        if(([edge1[@"TouchedElement_Action"] isEqualToString:@"tableCellClicked"] && [edge2[@"TouchedElement_Action"] isEqualToString:@"ListViewCellClicked"]) ||
                           ([edge1[@"TouchedElement_Action"] isEqualToString:@"itemClicked"] && [edge2[@"TouchedElement_Action"] isEqualToString:@"MenuItemClicked"]))
                            rr1 = 0;
                        
                        //heuristic for Action (MenuButtonClicked)
                        else if ([edge2[@"TouchedElement_Action"] isEqualToString:@"MenuButtonClicked"])
                            rr1 = 400;
                        
                        else {
                            rr1 = 0;
                            if ([edge1[@"TouchedElement_Action"] length]>0 || [edge2[@"TouchedElement_Action"] length]>0) {
                            NSInteger r1 = [edge1[@"TouchedElement_Action"] levenshteinDistanceToString:edge2[@"TouchedElement_Action"]];
                            max=[edge1[@"TouchedElement_Action"] length];
                            if([edge2[@"TouchedElement_Action"] length]>[edge1[@"TouchedElement_Action"] length])
                                max=[edge2[@"TouchedElement_Action"] length];
                            rr1 = (WEIGHT_E_CLASS*((float)r1/(float)max));
                            }
                        }
                        
                        float rr2 = 0;
                        if ([edge1[@"TouchedElement_Label"] length]>0 || [edge2[@"TouchedElement_Label"] length]>0) {
                        NSInteger r2 = [edge1[@"TouchedElement_Label"] levenshteinDistanceToString:edge2[@"TouchedElement_Label"]];
                        max=[edge1[@"TouchedElement_Label"] length];
                        if([edge2[@"TouchedElement_Label"] length]>[edge1[@"TouchedElement_Label"] length])
                            max=[edge2[@"TouchedElement_Label"] length];
                        rr2 = (WEIGHT_E_CLASS*((float)r2/(float)max));
                        }
                            
                        NSInteger r3 = [self mappedTypeE1:edge1[@"TouchedElement_Type"] withE2:edge2[@"TouchedElement_Type"]];
                        
                        //heuristic for ClassName (Activity == ViewController)
                        NSString* n1 = [iphoneTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
                        NSString* n2 = [androidTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSUInteger r4 = [n1 levenshteinDistanceToString:n2];
                        max=n1.length;
                        if(n2.length>n1.length)
                            max=n2.length;
                        float rr4 = (WEIGHT_S_CLASS*((float)r4/(float)max));
                            
                        float rr5 = 0;
                        if ([iphoneTrgState[@"State_Title"] length]>0 || [androidTrgState[@"State_Title"] length]>0) {
                        NSUInteger r5 = [iphoneTrgState[@"State_Title"] levenshteinDistanceToString:androidTrgState[@"State_Title"]];
                        max=[iphoneTrgState[@"State_Title"] length];
                        if([androidTrgState[@"State_Title"] length]>[iphoneTrgState[@"State_Title"] length])
                            max=[androidTrgState[@"State_Title"] length];
                        rr5 = (WEIGHT_S_CLASS*((float)r5/(float)max));
                        }
                            
                        NSMutableArray *thisElPairs = [self calculateElementsPairSimilarityE1:iphoneTrgState[@"Elements"] withE2:androidTrgState[@"Elements"]];
                        float r6 = (float)(thisElPairs.count*2)/(float)([iphoneTrgState[@"Elements"] count]+[androidTrgState[@"Elements"] count]);
                            
//                        int totalPairSim = 0;
//                        NSUInteger sum4 = 0;
//                        if (thisElPairs.count>0) {
//                            for (NSMutableDictionary* elPair in thisElPairs)
//                                totalPairSim = totalPairSim+[elPair[@"Sum"] intValue];
//                            sum4 = (totalPairSim/thisElPairs.count);
//                        }
                        
                        NSInteger sum = lroundf(((WEIGHT_E_ACTION*rr1+WEIGHT_E_TITLE*rr2+WEIGHT_E_CLASS*r3+WEIGHT_S_CLASS*rr4+WEIGHT_S_TITLE*rr5+WEIGHT_S_ELEMENTS*r6)/6)*100);
                        if (sum < maxDif) {
                            edgePair[@"Android"]=edge2;
                            edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                            edgePair[@"Mapped"]=@0;
                            maxDif = sum;
                        }
                    }
                }
                
                if (edgePair[@"Sum"]) {
                    
                    NSInteger thisEdgeMapId = self.edgeMapId++;
                    //TO DO: set the mapping color
                    edgePair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"Android"][@"MappingColor"]=edgePair[@"Sum"];
                    edgePair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"iPhone"][@"MappingColor"]=edgePair[@"Sum"];
                    
                    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
                    for (NSMutableDictionary* e in thisEdgePairs) {
                        
                        if (([e[@"Android"][@"TimeStamp"] isEqualToString:edgePair[@"Android"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"]) ||
                            ([e[@"iPhone"][@"TimeStamp"] isEqualToString:edgePair[@"iPhone"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"])){
                            NSInteger anIndex=[thisEdgePairs indexOfObject:e];
                            [discardedItems addIndex:anIndex];
                        }
                    }
                    if (discardedItems.count>0)
                        [thisEdgePairs removeObjectsAtIndexes:discardedItems];
                    [thisEdgePairs addObject:edgePair];
                }
            }
        }
    }
    else {
        for (NSMutableDictionary* edge1 in androidEdges) {
            
            NSMutableDictionary* androidTrgState = [self findState2:edge1[@"Target_State_ID"] inStates:self.androidStatesAry];
            
            if (![edge1[@"TouchedElement_Action"] isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Label"]isEqualToString:@""] ||
                ![edge1[@"TouchedElement_Type"]isEqualToString:@""] ||
                ![androidTrgState[@"State_ClassName"] isEqualToString:@""] ||
                ![androidTrgState[@"State_Title"] isEqualToString:@""]) {
                
                NSMutableDictionary* edgePair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                edgePair[@"Android"] = edge1;
                
                for (NSMutableDictionary* edge2 in iPhoneEdges) {
                    
                    NSMutableDictionary* iphoneTrgState = [self findState2:edge2[@"Target_State_ID"] inStates:self.iphoneStatesAry];
                    
                    if ((![edge2[@"TouchedElement_Action"] isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Label"]isEqualToString:@""] ||
                        ![edge2[@"TouchedElement_Type"]isEqualToString:@""] ||
                        ![iphoneTrgState[@"State_ClassName"] isEqualToString:@""] ||
                        ![iphoneTrgState[@"State_Title"] isEqualToString:@""]) &&
                        (([edge2[@"Target_State_ID"] isEqualToString:edge2[@"Source_State_ID"]] && [edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]) ||
                         (![edge2[@"Target_State_ID"] isEqualToString: edge2[@"Source_State_ID"]] && ![edge1[@"Target_State_ID"] isEqualToString:edge1[@"Source_State_ID"]]))) {
                        
                        float rr1;
                        NSInteger max;
                        //heuristic for Actions (MenuItemClicked, ListViewCellClicked)
                        if(([edge2[@"TouchedElement_Action"] isEqualToString:@"tableCellClicked"] && [edge1[@"TouchedElement_Action"] isEqualToString:@"ListViewCellClicked"]) ||
                           ([edge2[@"TouchedElement_Action"] isEqualToString:@"itemClicked"] && [edge1[@"TouchedElement_Action"] isEqualToString:@"MenuItemClicked"]))
                            rr1 = 0;
                        
                        //heuristic for Action (MenuButtonClicked)
                        else if ([edge1[@"TouchedElement_Action"] isEqualToString:@"MenuButtonClicked"])
                            rr1 = 400;
                        
                        else {
                            rr1 = 0;
                            if ([edge1[@"TouchedElement_Action"] length]>0 || [edge2[@"TouchedElement_Action"] length]>0) {
                            NSInteger r1 = [edge1[@"TouchedElement_Action"] levenshteinDistanceToString:edge2[@"TouchedElement_Action"]];
                            max=[edge1[@"TouchedElement_Action"] length];
                            if([edge2[@"TouchedElement_Action"] length]>[edge1[@"TouchedElement_Action"] length])
                                max=[edge2[@"TouchedElement_Action"] length];
                            rr1 = (WEIGHT_E_CLASS*((float)r1/(float)max));
                            }
                        }
                        
                        float rr2 = 0;
                        if ([edge1[@"TouchedElement_Label"] length]>0 || [edge2[@"TouchedElement_Label"] length]>0) {
                        NSInteger r2 = [edge1[@"TouchedElement_Label"] levenshteinDistanceToString:edge2[@"TouchedElement_Label"]];
                        max=[edge1[@"TouchedElement_Label"] length];
                        if([edge2[@"TouchedElement_Label"] length]>[edge1[@"TouchedElement_Label"] length])
                            max=[edge2[@"TouchedElement_Label"] length];
                        rr2 = (WEIGHT_E_CLASS*((float)r2/(float)max));
                        }
                            
                        NSInteger r3 = [self mappedTypeE1:edge2[@"TouchedElement_Type"] withE2:edge1[@"TouchedElement_Type"]];
                        
                        //heuristic for ClassName (Activity == ViewController)
                        NSString* n1 = [iphoneTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"viewcontroller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
                        n1 = [n1 stringByReplacingOccurrencesOfString:@"controller" withString:@""];
                        NSString* n2 = [androidTrgState[@"State_ClassName"] stringByReplacingOccurrencesOfString:@"Activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@"activity" withString:@""];
                        n2 = [n2 stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSUInteger r4 = [n1 levenshteinDistanceToString:n2];
                        max=n1.length;
                        if(n2.length>n1.length)
                            max=n2.length;
                        float rr4 = (WEIGHT_S_CLASS*((float)r4/(float)max));
                          
                        float rr5 = 0;
                        if ([iphoneTrgState[@"State_Title"] length]>0 || [androidTrgState[@"State_Title"] length]>0) {
                        NSUInteger r5 = [iphoneTrgState[@"State_Title"] levenshteinDistanceToString:androidTrgState[@"State_Title"]];
                        max=[iphoneTrgState[@"State_Title"] length];
                        if([androidTrgState[@"State_Title"] length]>[iphoneTrgState[@"State_Title"] length])
                            max=[androidTrgState[@"State_Title"] length];
                        rr5 = (WEIGHT_S_CLASS*((float)r5/(float)max));
                        }
                            
                        NSMutableArray *thisElPairs = [self calculateElementsPairSimilarityE1:iphoneTrgState[@"Elements"] withE2:androidTrgState[@"Elements"]];
                        float r6 = (float)(thisElPairs.count*2)/(float)([iphoneTrgState[@"Elements"] count]+[androidTrgState[@"Elements"] count]);
                            
                        NSInteger sum = lroundf(((WEIGHT_E_ACTION*rr1+WEIGHT_E_TITLE*rr2+WEIGHT_E_CLASS*r3+WEIGHT_S_CLASS*rr4+WEIGHT_S_TITLE*rr5+WEIGHT_S_ELEMENTS*r6)/6)*100);
                        if (sum < maxDif) {
                            edgePair[@"iPhone"]=edge2;
                            edgePair[@"Sum"]=[NSNumber numberWithInteger:sum];
                            edgePair[@"Mapped"]=@0;
                            maxDif = sum;
                        }
                    }
                }
                
                if (edgePair[@"Sum"]) {
                    
                    NSInteger thisEdgeMapId = self.edgeMapId++;
                    //TO DO: set the mapping color
                    edgePair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"Android"][@"MappingColor"]=edgePair[@"Sum"];
                    edgePair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisEdgeMapId];
                    edgePair[@"iPhone"][@"MappingColor"]=edgePair[@"Sum"];
                    
                    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
                    for (NSMutableDictionary* e in thisEdgePairs) {
                        
                        if (([e[@"Android"][@"TimeStamp"] isEqualToString:edgePair[@"Android"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"]) ||
                            ([e[@"iPhone"][@"TimeStamp"] isEqualToString:edgePair[@"iPhone"][@"TimeStamp"]] && e[@"Sum"] > edgePair[@"Sum"])){
                            NSInteger anIndex=[thisEdgePairs indexOfObject:e];
                            [discardedItems addIndex:anIndex];
                        }
                    }
                    if (discardedItems.count>0)
                        [thisEdgePairs removeObjectsAtIndexes:discardedItems];
                    [thisEdgePairs addObject:edgePair];
                }
            }
        }
    }
    return thisEdgePairs;
}
            
-(NSMutableArray*)calculateElementsPairSimilarityE1:(NSMutableArray*)iphoneElements withE2:(NSMutableArray*)androidElements
{
    NSMutableArray *thisElPairs = [NSMutableArray array];
    NSMutableString *report = [[NSMutableString alloc] init];
    
    //map elements
    if (iphoneElements.count <= androidElements.count) {
        for (NSMutableDictionary* element1 in iphoneElements) {
            
            if (![element1[@"UIElement_Label"]isEqualToString:@""] ||
                ![element1[@"UIElement_Details"]isEqualToString:@""]) {
                
                NSMutableDictionary* elPair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                elPair[@"iPhone"] = element1;
                for (NSMutableDictionary* element2 in androidElements) {
                    
                    if (!element2[@"MappingLabel"] &&
                        (![element2[@"UIElement_Label"]isEqualToString:@""] ||
                         ![element2[@"UIElement_Details"]isEqualToString:@""])) {
                            
                            if(![self mappedTypeE1:element1[@"UIElement_Type"] withE2:element2[@"UIElement_Type"]]){
                            
                                [report setString:@""];
                                float rr1 = 0;
                                NSInteger max;
                                //heuristic for number of cells in tabels
                                if([element1[@"UIElement_Type"] isEqualToString:@"UITableView"] &&
                                   [element2[@"UIElement_Type"] isEqualToString:@"ListView"] &&
                                   ([element1[@"UIElement_Details"] intValue] !=0 ||
                                    [element2[@"UIElement_Details"] intValue] !=0)) {
                                    rr1 = (float)(abs([element1[@"UIElement_Details"] intValue] - [element2[@"UIElement_Details"] intValue]))/(float)([element1[@"UIElement_Details"] intValue] + [element2[@"UIElement_Details"] intValue]);
                                    
                                    if (rr1>0)
                                        [report appendString:[NSString stringWithFormat:@"Inconsistency in # tabel cells: iPhone (%@) vs. Android (%@)\n", element1[@"UIElement_Details"], element2[@"UIElement_Details"]]];
                                   }
                                
                                //heuristic for Action (MenuButtonClicked)
                                else if ([element2[@"UIElement_Action"] isEqualToString:@"MenuButtonClicked"])
                                    rr1 = 400;
                                
//                                else {
//                                    rr1 = 0;
//                                    if ([element1[@"UIElement_Action"] length]>0 && [element2[@"UIElement_Action"] length]>0) {
//                                    NSInteger r1 = [element1[@"UIElement_Action"] levenshteinDistanceToString:element2[@"UIElement_Action"]];
//                                    max=[element1[@"UIElement_Action"] length];
//                                    if([element2[@"UIElement_Action"] length]>[element1[@"UIElement_Action"] length])
//                                        max=[element2[@"UIElement_Action"] length];
//                                    rr1 = (WEIGHT_E_CLASS*((float)r1/(float)max));
//                                    }
//                                }

                                float rr2 = 0;
                                if ([element1[@"UIElement_Label"] length]>0 && [element2[@"UIElement_Label"] length]>0) {
                                NSInteger r2 = [element1[@"UIElement_Label"] levenshteinDistanceToString:element2[@"UIElement_Label"]];
                                max=[element1[@"UIElement_Label"] length];
                                if([element2[@"UIElement_Label"] length]>[element1[@"UIElement_Label"] length])
                                    max=[element2[@"UIElement_Label"] length];
                                    rr2 = (WEIGHT_E_CLASS*((float)r2/(float)max));
                                }
                                
                                NSInteger sum = lroundf(((WEIGHT_E_ACTION*rr1+WEIGHT_E_TITLE*rr2)/2)*100);
                                if (sum < maxDif) {
                                    elPair[@"Android"]=element2;
                                    elPair[@"Sum"]=[NSNumber numberWithInteger:sum];
                                    elPair[@"Mapped"]=@0;
                                    maxDif = sum;
                                    if (sum==0)
                                        break;
                                }
                        }
                    }
                }
                
                if (elPair[@"Sum"]) {
                    
                    if ([elPair[@"Android"][@"UIElement_Label"] length]>0 || [elPair[@"iPhone"][@"UIElement_Label"] length]>0) {
                       
                        elPair[@"Sum"] = [NSNumber numberWithInteger:[elPair[@"Android"][@"UIElement_Label"] levenshteinDistanceToString:elPair[@"iPhone"][@"UIElement_Label"]]];
                        
                        if ([elPair[@"Sum"] intValue]>0) {
                            [report appendString:[NSString stringWithFormat:@"\nInconsistency in the element: iPhone (%@,%@,%@) vs. Android (%@,%@,%@)\n", elPair[@"iPhone"][@"UIElement_Type"],elPair[@"iPhone"][@"UIElement_Label"],elPair[@"iPhone"][@"UIElement_Action"],elPair[@"Android"][@"UIElement_Type"],elPair[@"Android"][@"UIElement_Label"],elPair[@"Android"][@"UIElement_Action"]]];
                        }
                    }
                    
                    if ([report length]==0)
                        elPair[@"Sum"] = [NSNumber numberWithInteger:0];
                    
                    NSInteger thisElemMapId = self.elemMapId++;
                    elPair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisElemMapId];
                    elPair[@"Android"][@"MappingColor"]=elPair[@"Sum"];
                    elPair[@"Android"][@"MappingReport"]=[NSString stringWithFormat:@"%@",report];
                    
                    elPair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisElemMapId];
                    elPair[@"iPhone"][@"MappingColor"]=elPair[@"Sum"];
                    elPair[@"iPhone"][@"MappingReport"]=[NSString stringWithFormat:@"%@",report];
                    
                    [thisElPairs addObject:elPair];
                }
            }
        }
    }
    else {
        for (NSMutableDictionary* element1 in androidElements) {
            
            if (![element1[@"UIElement_Label"]isEqualToString:@""] ||
                ![element1[@"UIElement_Details"]isEqualToString:@""]) {
                
                NSMutableDictionary* elPair = [NSMutableDictionary dictionary];
                NSInteger maxDif=100;
                elPair[@"Android"] = element1;
                
                for (NSMutableDictionary* element2 in iphoneElements) {
                    
                    if (!element2[@"MappingLabel"] &&
                        (![element2[@"UIElement_Label"]isEqualToString:@""] ||
                         ![element2[@"UIElement_Details"]isEqualToString:@""])) {
                            
                            if(![self mappedTypeE1:element2[@"UIElement_Type"] withE2:element1[@"UIElement_Type"]]){
                                
                                [report setString:@""];
                                float rr1= 0;
                                NSInteger max;
                                //heuristic for number of cells in tabels
                                if([element2[@"UIElement_Type"] isEqualToString:@"UITableView"] &&
                                   [element1[@"UIElement_Type"] isEqualToString:@"ListView"] &&
                                   ([element1[@"UIElement_Details"] intValue] !=0 ||
                                    [element2[@"UIElement_Details"] intValue] !=0)) {
                                    rr1 = (float)(abs([element1[@"UIElement_Details"] intValue] - [element2[@"UIElement_Details"] intValue]))/(float)([element1[@"UIElement_Details"] intValue] + [element2[@"UIElement_Details"] intValue]);
                                
                                    if (rr1>0)
                                        [report appendString:[NSString stringWithFormat:@"Inconsistency in # tabel cells: iPhone (%@) vs. Android (%@)\n", element2[@"UIElement_Details"], element1[@"UIElement_Details"]]];
                                }
                                
                                //heuristic for Action (MenuButtonClicked)
                                else if ([element1[@"UIElement_Action"] isEqualToString:@"MenuButtonClicked"])
                                    rr1 = 400;
                                
//                                else {
//                                    rr1 = 0;
//                                    if ([element1[@"UIElement_Action"] length]>0 && [element2[@"UIElement_Action"] length]>0) {
//                                    NSInteger r1 = [element1[@"UIElement_Action"] levenshteinDistanceToString:element2[@"UIElement_Action"]];
//                                    max=[element1[@"UIElement_Action"] length];
//                                    if([element2[@"UIElement_Action"] length]>[element1[@"UIElement_Action"] length])
//                                        max=[element2[@"UIElement_Action"] length];
//                                    rr1 = (WEIGHT_E_CLASS*((float)r1/(float)max));
//                                    }
//                                }

                                float rr2 = 0;
                                if ([element1[@"UIElement_Label"] length]>0 && [element2[@"UIElement_Label"] length]>0) {
                                    NSInteger r2 = [element1[@"UIElement_Label"] levenshteinDistanceToString:element2[@"UIElement_Label"]];
                                    max=[element1[@"UIElement_Label"] length];
                                    if([element2[@"UIElement_Label"] length]>[element1[@"UIElement_Label"] length])
                                        max=[element2[@"UIElement_Label"] length];
                                    rr2 = (WEIGHT_E_CLASS*((float)r2/(float)max));
                                }
                                
                                NSInteger sum = lroundf(((WEIGHT_E_ACTION*rr1+WEIGHT_E_TITLE*rr2)/2)*100);
                                if (sum < maxDif) {
                                    elPair[@"iPhone"]=element2;
                                    elPair[@"Sum"]=[NSNumber numberWithInteger:sum];
                                    elPair[@"Mapped"]=@0;
                                    maxDif = sum;
                                    if (sum==0)
                                        break;
                                }
                            }
                        }
                }
                
                if (elPair[@"Sum"]) {
                    
                    if ([elPair[@"Android"][@"UIElement_Label"] length]>0 || [elPair[@"iPhone"][@"UIElement_Label"] length]>0) {
                        
                        elPair[@"Sum"] = [NSNumber numberWithInteger:[elPair[@"Android"][@"UIElement_Label"] levenshteinDistanceToString:elPair[@"iPhone"][@"UIElement_Label"]]];
                        
                        if ([elPair[@"Sum"] intValue]>0) {
                            [report appendString:[NSString stringWithFormat:@"\nInconsistency in the element: iPhone (%@,%@,%@) vs. Android (%@,%@,%@)", elPair[@"iPhone"][@"UIElement_Type"],elPair[@"iPhone"][@"UIElement_Label"],elPair[@"iPhone"][@"UIElement_Action"],elPair[@"Android"][@"UIElement_Type"],elPair[@"Android"][@"UIElement_Label"],elPair[@"Android"][@"UIElement_Action"]]];
                        }
                    }
                    
                    if ([report length]==0)
                        elPair[@"Sum"] = [NSNumber numberWithInteger:0];
                    
                    NSInteger thisElemMapId = self.elemMapId++;
                    //TO DO: set the mapping color
                    elPair[@"Android"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisElemMapId];
                    elPair[@"Android"][@"MappingColor"]=elPair[@"Sum"];
                    elPair[@"Android"][@"MappingReport"]=[NSString stringWithFormat:@"%@",report];
                    
                    elPair[@"iPhone"][@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisElemMapId];
                    elPair[@"iPhone"][@"MappingColor"]=elPair[@"Sum"];
                    elPair[@"iPhone"][@"MappingReport"]=[NSString stringWithFormat:@"%@",report];
                    
                    [thisElPairs addObject:elPair];
                }
            }
        }
    }
    return thisElPairs;
}

-(void)compareiPhoneState:(NSMutableDictionary*)iPhoneState withAndroidState:(NSMutableDictionary*)androidState {
    
    NSUInteger thisStateMapId = self.stateMapId++;
    NSMutableString *report = [[NSMutableString alloc] init];
    NSUInteger inconsCount =0;
    
    [report appendString:@""];
    float rr1 = 0;
    if ([iPhoneState[@"State_Title"] length]>0 || [androidState[@"State_Title"] length]>0) {
    NSUInteger r1 = [iPhoneState[@"State_Title"] levenshteinDistanceToString:androidState[@"State_Title"]];
    NSInteger max=[iPhoneState[@"State_Title"] length];
    if([androidState[@"State_Title"] length]>[iPhoneState[@"State_Title"] length])
        max=[androidState[@"State_Title"] length];
    rr1 = (WEIGHT_S_TITLE*((float)r1/(float)max));
    }
    
    if (rr1>0) {
        inconsCount++;
        [report appendString:[NSString stringWithFormat:@"Inconsistency in Title: iPhone '%@' vs. Android '%@' \n", iPhoneState[@"State_Title"], androidState[@"State_Title"]]];
    }
    
    NSMutableArray *thisElPairs = [self calculateElementsPairSimilarityE1:iPhoneState[@"Elements"] withE2:androidState[@"Elements"]];
    //float r2 = (float)(thisElPairs.count*2)/(float)([iPhoneState[@"Elements"] count]+[androidState[@"Elements"] count]);
    //NSUInteger sum5 = lroundf(((WEIGHT_S_TITLE*rr1 + WEIGHT_S_ELEMENTS*r2)/2)*100);
    
    if (thisElPairs.count>0) {
        for (NSMutableDictionary* elPair in thisElPairs) {
            if ([elPair[@"Sum"] intValue]>0) {
                 inconsCount++;
                [report appendString:elPair[@"iPhone"][@"MappingReport"]];
            }
        }
    }
    
    //iPhoneState[@"MappingColor"]=[NSNumber numberWithInteger:sum5];
    iPhoneState[@"MappingColor"]=[NSNumber numberWithInteger:inconsCount];
    iPhoneState[@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisStateMapId];
    iPhoneState[@"MappingReport"]=[NSString stringWithFormat:@"%@",report];
    
    androidState[@"MappingColor"]=[NSNumber numberWithInteger:inconsCount];
    androidState[@"MappingLabel"]=[NSString stringWithFormat:@"MappedID%tu",thisStateMapId];
    androidState[@"MappingReport"]=[NSString stringWithFormat:@"%@",report];
    
    [self.similarityCsv appendString:@"\n***Closest States\n"];
    [self.similarityCsv appendString:[NSString stringWithFormat:@"iPhoneState: %@ \nandroidState: %@\nMapping ID: %@\n",iPhoneState[@"State_ID"],androidState[@"State_ID"],iPhoneState[@"MappingLabel"]]];
    [self.similarityCsv appendString:[NSString stringWithFormat:@"Number of Inconsistencies (Title, Elements): %@ \n%@ \n ",iPhoneState[@"MappingColor"],iPhoneState[@"MappingReport"]]];
}

- (void)logPropertiesForEdges {
    
    for (NSMutableDictionary* edge in self.iphoneEdgesAry){
        
        [self.iphoneXmlWriter writeCharacters:@"\n\n"];
        
        [self.iphoneXmlWriter writeStartElement:@"Edge"];
    
        [self.iphoneXmlWriter writeStartElement:@"TimeStamp"];
        [self.iphoneXmlWriter writeCharacters:edge[@"TimeStamp"]];
        [self.iphoneXmlWriter writeEndElement];
    
        [self.iphoneXmlWriter writeStartElement:@"Source_State_ID"];
        [self.iphoneXmlWriter writeCharacters:edge[@"Source_State_ID"]];
        [self.iphoneXmlWriter writeEndElement];
    
        [self.iphoneXmlWriter writeStartElement:@"Target_State_ID"];
        [self.iphoneXmlWriter writeCharacters:edge[@"Target_State_ID"]];
        [self.iphoneXmlWriter writeEndElement];
    
        [self.iphoneXmlWriter writeStartElement:@"TouchedElement"];
        if ([edge[@"TouchedElement_Type"] length]>0 || [edge[@"TouchedElement_Label"] length]>0||
            [edge[@"TouchedElement_Action"] length]>0 || [edge[@"TouchedElement_Details"] length]>0)
        {
            [self.iphoneXmlWriter writeStartElement:@"UIElement_Type"];
            [self.iphoneXmlWriter writeCharacters:edge[@"TouchedElement_Type"]];
            [self.iphoneXmlWriter writeEndElement];
        
            [self.iphoneXmlWriter writeStartElement:@"UIElement_Label"];
            [self.iphoneXmlWriter writeCharacters:edge[@"TouchedElement_Label"]];
            [self.iphoneXmlWriter writeEndElement];
        
            [self.iphoneXmlWriter writeStartElement:@"UIElement_Action"];
            [self.iphoneXmlWriter writeCharacters:edge[@"TouchedElement_Action"]];
            [self.iphoneXmlWriter writeEndElement];
        
            [self.iphoneXmlWriter writeStartElement:@"UIElement_Details"];
            [self.iphoneXmlWriter writeCharacters:edge[@"TouchedElement_Details"]];
            [self.iphoneXmlWriter writeEndElement];
        }
        [self.iphoneXmlWriter writeEndElement];
        
        [self.iphoneXmlWriter writeStartElement:@"Methods"];
        for(NSString * method in edge[@"Methods"]){
            if ([method length]>0) {
                [self.iphoneXmlWriter writeStartElement:@"Method"];
                [self.iphoneXmlWriter writeCharacters:[NSString stringWithFormat:@"%@", method]];
                [self.iphoneXmlWriter writeEndElement];
            }
        }
        [self.iphoneXmlWriter writeEndElement];
        
        //Add the mapping color and label
        [self.iphoneXmlWriter writeStartElement:@"MappingColor"];
        [self.iphoneXmlWriter writeCharacters:[NSString stringWithFormat:@"%@",edge[@"MappingColor"]]];
        [self.iphoneXmlWriter writeEndElement];
        
        [self.iphoneXmlWriter writeStartElement:@"MappingLabel"];
        [self.iphoneXmlWriter writeCharacters:edge[@"MappingLabel"]];
        [self.iphoneXmlWriter writeEndElement];
        
        [self.iphoneXmlWriter writeEndElement];
    }
    
    for (NSMutableDictionary* edge in self.androidEdgesAry){
        
        [self.androidXmlWriter writeCharacters:@"\n\n"];
        
        [self.androidXmlWriter writeStartElement:@"Edge"];
        
        [self.androidXmlWriter writeStartElement:@"TimeStamp"];
        [self.androidXmlWriter writeCharacters:edge[@"TimeStamp"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"Source_State_ID"];
        [self.androidXmlWriter writeCharacters:edge[@"Source_State_ID"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"Target_State_ID"];
        [self.androidXmlWriter writeCharacters:edge[@"Target_State_ID"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"TouchedElement"];
        if ([edge[@"TouchedElement_Type"] length]>0 || [edge[@"TouchedElement_Label"] length]>0||
            [edge[@"TouchedElement_Action"] length]>0 || [edge[@"TouchedElement_Details"] length]>0)
        {
            [self.androidXmlWriter writeStartElement:@"UIElement_Type"];
            [self.androidXmlWriter writeCharacters:edge[@"TouchedElement_Type"]];
            [self.androidXmlWriter writeEndElement];
        
            [self.androidXmlWriter writeStartElement:@"UIElement_Label"];
            [self.androidXmlWriter writeCharacters:edge[@"TouchedElement_Label"]];
            [self.androidXmlWriter writeEndElement];
        
            [self.androidXmlWriter writeStartElement:@"UIElement_Action"];
            [self.androidXmlWriter writeCharacters:edge[@"TouchedElement_Action"]];
            [self.androidXmlWriter writeEndElement];
        
            [self.androidXmlWriter writeStartElement:@"UIElement_Details"];
            [self.androidXmlWriter writeCharacters:edge[@"TouchedElement_Details"]];
            [self.androidXmlWriter writeEndElement];
        }
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"Methods"];
        for(NSString * method in edge[@"Methods"]){
            if ([method length]>0) {
                [self.androidXmlWriter writeStartElement:@"Method"];
                [self.androidXmlWriter writeCharacters:[NSString stringWithFormat:@"%@", method]];
                [self.androidXmlWriter writeEndElement];
            }
        }
        [self.androidXmlWriter writeEndElement];
        
        //Add the mapping color and label
        [self.androidXmlWriter writeStartElement:@"MappingColor"];
        [self.androidXmlWriter writeCharacters:[NSString stringWithFormat:@"%@",edge[@"MappingColor"]]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"MappingLabel"];
        [self.androidXmlWriter writeCharacters:edge[@"MappingLabel"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeEndElement];
    }
}

- (void)logPropertiesForStates {
    
    for (NSMutableDictionary* state in self.iphoneStatesAry){
        
        [self.iphoneXmlWriter writeCharacters:@"\n\n"];
    
        [self.iphoneXmlWriter writeStartElement:@"State"];
    
        [self.iphoneXmlWriter writeStartElement:@"TimeStamp"];
        [self.iphoneXmlWriter writeCharacters:state[@"TimeStamp"]];
        [self.iphoneXmlWriter writeEndElement];
	
        [self.iphoneXmlWriter writeStartElement:@"State_ID"];
        [self.iphoneXmlWriter writeCharacters:state[@"State_ID"]];
        [self.iphoneXmlWriter writeEndElement];
    
        [self.iphoneXmlWriter writeStartElement:@"State_ClassName"];
        [self.iphoneXmlWriter writeCharacters:state[@"State_ClassName"]];
        [self.iphoneXmlWriter writeEndElement];
	
        [self.iphoneXmlWriter writeStartElement:@"State_Title"];
        [self.iphoneXmlWriter writeCharacters:state[@"State_Title"]];
        [self.iphoneXmlWriter writeEndElement];
	
        [self.iphoneXmlWriter writeStartElement:@"State_ScreenshotPath"];
        [self.iphoneXmlWriter writeCharacters:state[@"State_ScreenshotPath"]];
        [self.iphoneXmlWriter writeEndElement];
    
        [self.iphoneXmlWriter writeStartElement:@"State_NumberOfElements"];
        [self.iphoneXmlWriter writeCharacters:state[@"State_NumberOfElements"]];
        [self.iphoneXmlWriter writeEndElement];
        
        [self.iphoneXmlWriter writeStartElement:@"MappingLabel"];
        [self.iphoneXmlWriter writeCharacters:state[@"MappingLabel"]];
        [self.iphoneXmlWriter writeEndElement];
        
        [self.iphoneXmlWriter writeStartElement:@"MappingColor"];
        [self.iphoneXmlWriter writeCharacters:[NSString stringWithFormat:@"%@",state[@"MappingColor"]]];
        [self.iphoneXmlWriter writeEndElement];
        
        [self.iphoneXmlWriter writeStartElement:@"MappingReport"];
        [self.iphoneXmlWriter writeCharacters:state[@"MappingReport"]];
        [self.iphoneXmlWriter writeEndElement];
    
        [self.iphoneXmlWriter writeStartElement:@"UIElements"];
    
        for(NSMutableDictionary *element in state[@"Elements"]){
    
            [self.iphoneXmlWriter writeStartElement:@"UIElement"];
        
            [self.iphoneXmlWriter writeStartElement:@"Parent_State_ID"];
            [self.iphoneXmlWriter writeCharacters:element[@"State_ID"]];
            [self.iphoneXmlWriter writeEndElement];
        
            [self.iphoneXmlWriter writeStartElement:@"UIElement_ID"];
            [self.iphoneXmlWriter writeCharacters:element[@"UIElement_ID"]];
            [self.iphoneXmlWriter writeEndElement];
        
            [self.iphoneXmlWriter writeStartElement:@"UIElement_Type"];
            [self.iphoneXmlWriter writeCharacters:element[@"UIElement_Type"]];
            [self.iphoneXmlWriter writeEndElement];
        
            [self.iphoneXmlWriter writeStartElement:@"UIElement_Label"];
            [self.iphoneXmlWriter writeCharacters:element[@"UIElement_Label"]];
            [self.iphoneXmlWriter writeEndElement];
        
            [self.iphoneXmlWriter writeStartElement:@"UIElement_Action"];
            [self.iphoneXmlWriter writeCharacters:element[@"UIElement_Action"]];
            [self.iphoneXmlWriter writeEndElement];
        
            [self.iphoneXmlWriter writeStartElement:@"UIElement_Details"];
            [self.iphoneXmlWriter writeCharacters:element[@"UIElement_Details"]];
            [self.iphoneXmlWriter writeEndElement];
        
            [self.iphoneXmlWriter writeEndElement];
        }
    
        [self.iphoneXmlWriter writeEndElement];
    
        [self.iphoneXmlWriter writeEndElement];
    }
    
    for (NSMutableDictionary* state in self.androidStatesAry){
        
        [self.androidXmlWriter writeCharacters:@"\n\n"];
        
        [self.androidXmlWriter writeStartElement:@"State"];
        
        [self.androidXmlWriter writeStartElement:@"TimeStamp"];
        [self.androidXmlWriter writeCharacters:state[@"TimeStamp"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"State_ID"];
        [self.androidXmlWriter writeCharacters:state[@"State_ID"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"State_ClassName"];
        [self.androidXmlWriter writeCharacters:state[@"State_ClassName"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"State_Title"];
        [self.androidXmlWriter writeCharacters:state[@"State_Title"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"State_ScreenshotPath"];
        [self.androidXmlWriter writeCharacters:state[@"State_ScreenshotPath"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"State_NumberOfElements"];
        [self.androidXmlWriter writeCharacters:state[@"State_NumberOfElements"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"MappingLabel"];
        [self.androidXmlWriter writeCharacters:state[@"MappingLabel"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"MappingColor"];
        [self.androidXmlWriter writeCharacters:[NSString stringWithFormat:@"%@",state[@"MappingColor"]]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"MappingReport"];
        [self.androidXmlWriter writeCharacters:state[@"MappingReport"]];
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeStartElement:@"UIElements"];
        
        for(NSMutableDictionary *element in state[@"Elements"]){
            
            [self.androidXmlWriter writeStartElement:@"UIElement"];
            
            [self.androidXmlWriter writeStartElement:@"Parent_State_ID"];
            [self.androidXmlWriter writeCharacters:element[@"State_ID"]];
            [self.androidXmlWriter writeEndElement];
            
            [self.androidXmlWriter writeStartElement:@"UIElement_ID"];
            [self.androidXmlWriter writeCharacters:element[@"UIElement_ID"]];
            [self.androidXmlWriter writeEndElement];
            
            [self.androidXmlWriter writeStartElement:@"UIElement_Type"];
            [self.androidXmlWriter writeCharacters:element[@"UIElement_Type"]];
            [self.androidXmlWriter writeEndElement];
            
            [self.androidXmlWriter writeStartElement:@"UIElement_Label"];
            [self.androidXmlWriter writeCharacters:element[@"UIElement_Label"]];
            [self.androidXmlWriter writeEndElement];
            
            [self.androidXmlWriter writeStartElement:@"UIElement_Action"];
            [self.androidXmlWriter writeCharacters:element[@"UIElement_Action"]];
            [self.androidXmlWriter writeEndElement];
            
            [self.androidXmlWriter writeStartElement:@"UIElement_Details"];
            [self.androidXmlWriter writeCharacters:element[@"UIElement_Details"]];
            [self.androidXmlWriter writeEndElement];
            
            [self.androidXmlWriter writeEndElement];
        }
        
        [self.androidXmlWriter writeEndElement];
        
        [self.androidXmlWriter writeEndElement];
    }
}

- (NSMutableArray*)getOutgoingEdgesFor:(NSMutableDictionary*)state inEdges:(NSArray*)edgesAry
{
    NSMutableArray *outgoingEdges = [NSMutableArray array];
    
    for (NSMutableDictionary* edge in edgesAry) {
        if([state[@"State_ID"] isEqualToString:edge[@"Source_State_ID"]]) //||            ([edge[@"Source_State_ID"] isEqualToString:edge[@"Target_State_ID"] && )
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
            [row setObject:@"" forKey:@"MappingColor"];
            [row setObject:@"" forKey:@"MappingLabel"];
            [row setObject:@"" forKey:@"MappingReport"];
            
            //printout states
            [self.similarityCsv appendString:[NSString stringWithFormat:@"%@            %@      %@      %@\n",rows[1],rows[2],rows[3],rows[5]]];
            
            //get the elements for the iphone next state
            NSMutableArray *elements = [NSMutableArray array];
            NSString *line;
            for(int j=1; j< [[self.iphoneElementsCsv componentsSeparatedByString:@"\n"] count]; j++) {
                line = [self.iphoneElementsCsv componentsSeparatedByString:@"\n"][j];
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
            [row setObject:@"" forKey:@"MappingColor"];
            [row setObject:@"" forKey:@"MappingLabel"];
            [row setObject:@"" forKey:@"MappingReport"];
            
            //printout states
            [self.similarityCsv appendString:[NSString stringWithFormat:@"%@            %@          %@      %@\n",rows[1],rows[2],rows[3],rows[5]]];
            
            //get the elements for the android next state
            NSMutableArray *elements = [NSMutableArray array];
            NSString *line;
            for(int j=1; j< [[self.androidElementsCsv componentsSeparatedByString:@"\n"] count]; j++) {
                line = [self.androidElementsCsv componentsSeparatedByString:@"\n"][j];
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
    //[self.similarityCsv appendString:@"\n\n***iPhone Actions\nSource -> Target     TouchedElement(Type     Label       Action       Details)\n"];
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
            [row setObject:@"" forKey:@"MappingColor"];
            [row setObject:@"" forKey:@"MappingLabel"];
            
            //printout edges
            //[self.similarityCsv appendString:[NSString stringWithFormat:@"%@    ->  %@      %@      %@      %@      %@\n",rows[1],rows[2],rows[3],rows[4],rows[5],rows[6]]];
            
            //get the methods for the iphone action
            NSMutableArray *methods = [NSMutableArray array];
            if ([rows[7] length]>0) {
                methods = (NSMutableArray*)[rows[7] componentsSeparatedByString:@";"];
            }
            
            [row setObject:methods forKey:@"Methods"];
            [self.iphoneEdgesAry addObject:row];
        }
    }
    
    [self.similarityCsv appendString:@"\n\n***Android Actions\nSrc -> Trg     TouchedElement(Type, Label, Action, Details)\n"];
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
            [row setObject:@"" forKey:@"MappingColor"];
            [row setObject:@"" forKey:@"MappingLabel"];
            
            //printout edges
            [self.similarityCsv appendString:[NSString stringWithFormat:@"%@ -> %@      (%@, %@, %@, %@)\n",rows[1],rows[2],rows[3],rows[4],rows[5],rows[6]]];
            
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
    float similarity = 1;
    
    NSString* iphoneElement = iphoneE[@"UIElement_Type"];
    NSString* androidElement = androidE[@"UIElement_Type"];
    
    //mona: add deatails label comparision here
    
    //string contains sub-string
    if (([iphoneElement rangeOfString:@"UIImageView"].location != NSNotFound) &&
        ([androidElement rangeOfString:@"ImageView"].location != NSNotFound))
        similarity = 0;
    
    else if (([iphoneElement rangeOfString:@"UIButton"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"Button"].location != NSNotFound)) {
        similarity = 0;
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
    
    else if (([iphoneElement rangeOfString:@"UITabBarButton"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"MenuItem"].location != NSNotFound))
        similarity = 1;
    
    else if (([iphoneElement rangeOfString:@"UITableViewCell"].location != NSNotFound) &&
             ([androidElement rangeOfString:@"ListViewCell"].location != NSNotFound))
        similarity = 1;

    return similarity;
}

-(NSInteger)mappedTypeE1:(NSString*)iphoneElement withE2:(NSString*)androidElement
{
    NSInteger similarity = 1;
    
    //string contains sub-string
    if ([iphoneElement isEqualToString:@"UIImageView"] && [androidElement isEqualToString:@"ImageView"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIButton"] && [androidElement isEqualToString:@"Button"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIButton"] && [androidElement isEqualToString:@"CheckBox"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIButton"] && [androidElement isEqualToString:@"CheckBox"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UISwitch"] && [androidElement isEqualToString:@"Switch"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UILable"] && [androidElement isEqualToString:@"TextView"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UITextView"] && [androidElement isEqualToString:@"EditText"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UITextField"] && [androidElement isEqualToString:@"EditText"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UITableView"] && [androidElement isEqualToString:@"ListView"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIPickerView"] && [androidElement isEqualToString:@"Spinner"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIPickerView"] && [androidElement isEqualToString:@"Picker"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIDatePicker"] && [androidElement isEqualToString:@"Picker"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIProgressView"] && [androidElement isEqualToString:@"ProgressBar"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UISlider"] && [androidElement isEqualToString:@"SeekBar"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UISlider"] && [androidElement isEqualToString:@"RatingBar"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UICollectionView"] && [androidElement isEqualToString:@"GridView"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIScrollView"] && [androidElement isEqualToString:@"ScrollView"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UICollectionView"] && [androidElement isEqualToString:@"GridView"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UISearchBar"] && [androidElement isEqualToString:@"SearchView"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIWebView"] && [androidElement isEqualToString:@"Webview"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIAlertView"] && [androidElement isEqualToString:@"AlertDialog"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIAlertView"] && [androidElement isEqualToString:@"Toast"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIPageControl"] && [androidElement isEqualToString:@"ViewPager"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIPageControl"] && [androidElement isEqualToString:@"tab"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UITabBar"] && [androidElement isEqualToString:@"Tab"])
        similarity = 0;
    //Customized
//    else if ([iphoneElement isEqualToString:@"UITabBar"] && [androidElement isEqualToString:@"Button"])
//        similarity = 0;
    //Customized
    else if ([iphoneElement isEqualToString:@"UISegmentedControl"] && [androidElement isEqualToString:@"Button"])
        similarity = 0;
    //Customized
    else if ([iphoneElement isEqualToString:@"UIToolBar"] && [androidElement isEqualToString:@"Button"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIToolBar"] && [androidElement isEqualToString:@"Tab"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIActionSheet"] && [androidElement isEqualToString:@"ActionBar"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIActionSheet"] && [androidElement isEqualToString:@"Spinner"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIStepper"] && [androidElement isEqualToString:@"Button"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UIMenuController"] && [androidElement isEqualToString:@"PopupMenu"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UITabBarButton"] && [androidElement isEqualToString:@"MenuItem"])
        similarity = 0;
    
    else if ([iphoneElement isEqualToString:@"UITableViewCell"] && [androidElement isEqualToString:@"ListViewCell"])
        similarity = 0;
    
    return similarity;
}


-(NSUInteger)calculateActionsPairSimilarityE1:(NSMutableArray*)iphoneElements withE2:(NSMutableArray*)androidElements
{
    NSUInteger similarity = 0;

    return similarity;
}

#pragma mark - output methods

-(void)outputAndroidCsvFiles
{
    NSString *path1 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidStates.csv"]];
    freopen([path1 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler1 = [NSFileHandle fileHandleForUpdatingAtPath:path1];
    //[fileHandler1 seekToEndOfFile];
    [fileHandler1 writeData:[self.androidStatesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler1 closeFile];

    NSString *path2 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidElements.csv"]];
    freopen([path2 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler2 = [NSFileHandle fileHandleForUpdatingAtPath:path2];
    //[fileHandler2 seekToEndOfFile];
    [fileHandler2 writeData:[self.androidElementsCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler2 closeFile];

    NSString *path3 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidEdges.csv"]];
    freopen([path3 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler3 = [NSFileHandle fileHandleForUpdatingAtPath:path3];
    //[fileHandler3 seekToEndOfFile];
    [fileHandler3 writeData:[self.androidEdgesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler3 closeFile];
}

-(void)outputAndroidOriginalCsvFiles
{
    NSString *path1 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidOriginalStates.csv"]];
    freopen([path1 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler1 = [NSFileHandle fileHandleForUpdatingAtPath:path1];
    //[fileHandler1 seekToEndOfFile];
    [fileHandler1 writeData:[self.androidStatesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler1 closeFile];
    
    NSString *path2 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidOriginalElements.csv"]];
    freopen([path2 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler2 = [NSFileHandle fileHandleForUpdatingAtPath:path2];
    //[fileHandler2 seekToEndOfFile];
    [fileHandler2 writeData:[self.androidElementsCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler2 closeFile];
    
    NSString *path3 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidOriginalEdges.csv"]];
    freopen([path3 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler3 = [NSFileHandle fileHandleForUpdatingAtPath:path3];
    //[fileHandler3 seekToEndOfFile];
    [fileHandler3 writeData:[self.androidEdgesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler3 closeFile];
}

-(void)outputiPhoneCsvFile
{
    NSString *path1 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneStates.csv"]];
    freopen([path1 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler1 = [NSFileHandle fileHandleForUpdatingAtPath:path1];
    //[fileHandler1 seekToEndOfFile];
    [fileHandler1 writeData:[self.iphoneStatesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler1 closeFile];

    NSString *path2 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneElements.csv"]];
    freopen([path2 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler2 = [NSFileHandle fileHandleForUpdatingAtPath:path2];
    //[fileHandler2 seekToEndOfFile];
    [fileHandler2 writeData:[self.iphoneElementsCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler2 closeFile];

    NSString *path3 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneEdges.csv"]];
    freopen([path3 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler3 = [NSFileHandle fileHandleForUpdatingAtPath:path3];
    //[fileHandler3 seekToEndOfFile];
    [fileHandler3 writeData:[self.iphoneEdgesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler3 closeFile];
}

-(void)outputiPhoneOriginalCsvFile
{
    NSString *path1 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneOriginalStates.csv"]];
    freopen([path1 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler1 = [NSFileHandle fileHandleForUpdatingAtPath:path1];
    //[fileHandler1 seekToEndOfFile];
    [fileHandler1 writeData:[self.iphoneStatesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler1 closeFile];
    
    NSString *path2 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneOriginalElements.csv"]];
    freopen([path2 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler2 = [NSFileHandle fileHandleForUpdatingAtPath:path2];
    //[fileHandler2 seekToEndOfFile];
    [fileHandler2 writeData:[self.iphoneElementsCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler2 closeFile];
    
    NSString *path3 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneOriginalEdges.csv"]];
    freopen([path3 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler3 = [NSFileHandle fileHandleForUpdatingAtPath:path3];
    //[fileHandler3 seekToEndOfFile];
    [fileHandler3 writeData:[self.iphoneEdgesCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler3 closeFile];
}


-(void)outputSimilarityCsvFile
{
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"SimilarityMapping.txt"]];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //[fileHandler seekToEndOfFile];
    [fileHandler writeData:[self.similarityCsv dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

- (void)outputiPhoneMappedFile:(NSMutableString*)outputString {
	// Create paths to State Graph output txt file
	NSString *path1 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneMapped.xml"]];
    freopen([path1 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
	NSFileHandle *fileHandler1 = [NSFileHandle fileHandleForUpdatingAtPath:path1];
	[fileHandler1 seekToEndOfFile];
	[fileHandler1 writeData:[outputString dataUsingEncoding:NSUTF8StringEncoding]];
	[fileHandler1 closeFile];
}

- (void)outputAndroidMappedFile:(NSMutableString*)outputString {
    // Create paths to State Graph output txt file
	NSString *path2 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidMapped.xml"]];
    freopen([path2 cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
	NSFileHandle *fileHandler2 = [NSFileHandle fileHandleForUpdatingAtPath:path2];
	[fileHandler2 seekToEndOfFile];
	[fileHandler2 writeData:[outputString dataUsingEncoding:NSUTF8StringEncoding]];
	[fileHandler2 closeFile];
}

#pragma mark - setup methods

- (void)setupOutputFiles {
	//Grab and empty a reference to the output files
    NSString *path = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"SimilarityMapping.txt"]];
	[@"" writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path1 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneEdges.csv"]];
	[@"" writeToFile:path1 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path2 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneElements.csv"]];
	[@"" writeToFile:path2 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path3 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneStates.csv"]];
	[@"" writeToFile:path3 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path4 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidEdges.csv"]];
	[@"" writeToFile:path4 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path5 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidElements.csv"]];
	[@"" writeToFile:path5 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path6 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidStates.csv"]];
	[@"" writeToFile:path6 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];

    NSString *path7 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneOriginalEdges.csv"]];
	[@"" writeToFile:path7 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path8 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneOriginalElements.csv"]];
	[@"" writeToFile:path8 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path9 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneOriginalStates.csv"]];
	[@"" writeToFile:path9 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path10 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidOriginalEdges.csv"]];
	[@"" writeToFile:path10 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path11 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidOriginalElements.csv"]];
	[@"" writeToFile:path11 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path12 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidOriginalStates.csv"]];
	[@"" writeToFile:path12 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];

    [self setupOutputStateGraphFile];
}

- (void)setupOutputStateGraphFile {
	//Grab and empty a reference to the output txt file
	NSString *path1 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"iPhoneMapped.xml"]];
	[@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?> \n\
     <!DOCTYPE document SYSTEM \"\" > \n \
     <Model>" writeToFile:path1 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    NSString *path2 = [[NSString alloc] initWithFormat:@"%@",[@"/Users/monaerfani/Desktop/mapping-projects/CAMPChecker/outputFiles/" stringByAppendingPathComponent:@"AndroidMapped.xml"]];
	[@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?> \n\
     <!DOCTYPE document SYSTEM \"\" > \n \
     <Model>" writeToFile:path2 atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

@end


