//
//  MasterViewController.h
//  XMLAnalyzer
//
//  Created by Mona Erfani on 2013-06-24.
//  Copyright (c) 2013 Mona Erfani. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Webkit/Webkit.h>

@interface MasterViewController : NSViewController
    
@property (nonatomic, strong) NSMutableData *androidXmlData;
@property (nonatomic, strong) NSMutableData *iphoneXmlData;

@property (nonatomic, retain) NSMutableString *androidStatesCsv;
@property (nonatomic, retain) NSMutableString *androidElementsCsv;
@property (nonatomic, retain) NSMutableString *androidEdgesCsv;

@property (nonatomic, retain) NSMutableString *iphoneStatesCsv;
@property (nonatomic, retain) NSMutableString *iphoneElementsCsv;
@property (nonatomic, retain) NSMutableString *iphoneEdgesCsv;

@property (nonatomic, strong) NSMutableArray *androidStatesAry;
@property (nonatomic, strong) NSMutableArray *androidElementsAry;
@property (nonatomic, strong) NSMutableArray *androidTouchedViewsAry;

@property (nonatomic, strong) NSMutableArray *iphoneStatesAry;
@property (nonatomic, strong) NSMutableArray *iphoneElementsAry;
@property (nonatomic, strong) NSMutableArray *iphoneTouchedViewsAry;

@property (nonatomic, strong) NSTextField *instructionLabel;
@property (nonatomic, strong) NSTextField *summaryLabel;
@property (nonatomic, strong) NSButton *myButton;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) NSInteger statusCode;


@property (nonatomic, strong) NSURL * jiraUrl;

-(IBAction)selectFile;

@end
