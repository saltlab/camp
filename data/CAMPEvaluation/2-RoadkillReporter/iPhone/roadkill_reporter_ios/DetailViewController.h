//
//  DetailViewController.h
//  roadkill_reporter_ios
//
//  Created by Caleb Gomer on 12/14/12.
//  Copyright (c) 2012 Caleb Gomer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverViewDelegate.h"
#import "ClarifyLocationView.h"

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLConnectionDataDelegate, UIAlertViewDelegate, PopoverViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *reportsTable;
@property (strong, nonatomic) IBOutlet UIBarItem *refreshButton;

@property (strong, nonatomic) ClarifyLocationView *popoverMap;

@property (strong, nonatomic) NSMutableData *webData;
@property (strong, nonatomic) NSDictionary *reportsData;

@property (atomic) BOOL reportsNeedUpdate;

@end
