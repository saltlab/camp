#import "DetailViewController.h"
#import "RoadkillTableViewCell.h"
#import "RoadkillReport.h"
#import "ClarifyLocationView.h"
#import "UIView+UIView_Faster.h"

NSString *k_Userid = @"userid";

@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      [self createSelf];
    }
    return self;
}

- (void)createSelf {
  self.title = NSLocalizedString(@"Past Reports", @"Past Reports");
  self.tabBarItem.image = [UIImage imageNamed:@"past_reports"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _webData = [[NSMutableData alloc] init];
    _reportsData = [[NSDictionary alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
  [self getPastReports];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0 && _reportsData) {
    return [[_reportsData objectForKey:@"rowCount"] intValue];
  }
  else {
    return 0;
  }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return nil;
//  return @"Your Past Reports";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *MyIdentifier = @"RoadKillRow";
  RoadkillTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
  
  if (cell == nil){
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RoadkillTableViewCell" owner:self options:nil];
    cell = (RoadkillTableViewCell *)[nib objectAtIndex:0];
  }
  
  
  RoadkillReport *report = [[RoadkillReport alloc] initWithDictionary:[[_reportsData objectForKey:@"rows"] objectAtIndex:indexPath.row]];
  
  cell.animalLabel.text = report.animalName;
  cell.distLabel.text = [report getDistanceText];
  cell.accuracyLabel.text = [report getAccuracyText];
  cell.ageLabel.text = [report getAgeText];
  
  cell.warningIcon.hidden = YES;
  if (report.loc_updated) {
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryType = UITableViewCellAccessoryNone;
  } else {
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
  }
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    return 57;
  }
  else {
    return 44;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  RoadkillReport *report = [[RoadkillReport alloc] initWithDictionary:[[_reportsData objectForKey:@"rows"] objectAtIndex:indexPath.row]];
  
  //create a popover map if we don't have one yet
  if (!_popoverMap) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ClarifyLocationView" owner:self options:nil];
    _popoverMap = (ClarifyLocationView *)[nib objectAtIndex:0];
  }
  
  _popoverMap.delegate = self;
  _popoverMap.frame = self.view.frame;
  _popoverMap.topEdge = self.view.bottomEdge;
  _popoverMap.mapView.region = MKCoordinateRegionMakeWithDistance(report.coordinate, report.accuracy, report.accuracy);
  _popoverMap.tag = report.reportId;
  [self.view addSubview:_popoverMap];
  
  //animate popover onto the screen
  [UIView animateWithDuration:0.5 animations:^(void) {
    _popoverMap.topEdge = self.view.topEdge;
  }];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return(YES);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if(editingStyle == UITableViewCellEditingStyleDelete)
  {
    RoadkillReport *report = [[RoadkillReport alloc] initWithDictionary:[[_reportsData objectForKey:@"rows"] objectAtIndex:indexPath.row]];
    [self deleteReportNumber:report.reportId];
  }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
  RoadkillReport *report = [[RoadkillReport alloc] initWithDictionary:[[_reportsData objectForKey:@"rows"] objectAtIndex:indexPath.row]];
  
  //create a popover map if we don't have one yet
  if (!_popoverMap) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ClarifyLocationView" owner:self options:nil];
    _popoverMap = (ClarifyLocationView *)[nib objectAtIndex:0];
  }
  
  _popoverMap.delegate = self;
  _popoverMap.frame = self.view.frame;
  _popoverMap.topEdge = self.view.bottomEdge;
  _popoverMap.alpha = 0;
  _popoverMap.mapView.region = MKCoordinateRegionMakeWithDistance(report.coordinate, report.accuracy, report.accuracy);
  _popoverMap.tag = report.reportId;
  [self.view addSubview:_popoverMap];

  //animate popover onto the screen
  [UIView animateWithDuration:0.5 animations:^(void) {
    _popoverMap.topEdge = self.view.topEdge;
    _popoverMap.alpha = 1;
  }];
}


#pragma mark - Roadkill Server Interactions
- (void)getPastReports {
  _reportsNeedUpdate = NO;
  
  NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:k_Userid];
  
  NSString *url = [NSString stringWithFormat:@"http://roadkill-reporter.herokuapp.com/reports/user/%@", userId];
  
  [self getUrl:url];
}

- (void)updateReportNumber:(int)reportNumber WithLocation:(CLLocationCoordinate2D)location {
  NSLog(@"updating report #%d to (%f,%f)",reportNumber,location.latitude,location.longitude);
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:k_Userid];
  NSString *url = [NSString stringWithFormat:@"http://roadkill-reporter.herokuapp.com/update_loc/%d/%f/%f/%@",reportNumber, location.latitude, location.longitude, userId];
  
  NSLog(@"%@",url);
  [self postUrl:url];
}

- (void)deleteReportNumber:(int)reportNumber {
  NSLog(@"deleting report #%d", reportNumber);
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:k_Userid];
  NSString *url = [NSString stringWithFormat:@"http://roadkill-reporter.herokuapp.com/delete/%d/%@",reportNumber,userId];
  [self getUrl:url];
}

#pragma mark - URLConnectionDelegate methods
- (void) getUrl:(NSString *)url {
  [self urlConnect:url method:@"get"];
}
- (void) postUrl:(NSString *)url {
  [self urlConnect:url method:@"post"];
}
- (void)urlConnect:(NSString *)url method:(NSString *)method {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  
  NSLog(@"%@ url:%@",method, url);
  
  NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
  [req setHTTPMethod:method];
  
  (void) [[NSURLConnection alloc] initWithRequest:req delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [_webData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
  [_webData appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                              message:[error localizedDescription]
                             delegate:nil
                    cancelButtonTitle:NSLocalizedString(@"OK", @"")
                    otherButtonTitles:nil] show];
  
  _reportsNeedUpdate = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSString *responseText = [[NSString alloc] initWithData:_webData encoding:NSUTF8StringEncoding];
  NSLog(@"RESPONSE:%@",responseText);
  responseText = [responseText substringFromIndex:21];
  NSError *myError = nil;
  NSData *stringData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
  
  NSDictionary *response = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableLeaves error:&myError];
  
  NSString *status = [response objectForKey:@"status"];
  if ([status isEqualToString:@"Reports"]) {
    _reportsData = [response objectForKey:@"info"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_reportsTable reloadData];
  }
  else if ([status isEqualToString:@"Found"]) {
    [self getPastReports];
  }
  else if ([status isEqualToString:@"Updated"]){
    [self getPastReports];
  }
  else if ([status isEqualToString:@"Deleted"]) {
    [self getPastReports];
    
  }
  else if ([status isEqualToString:@"Error"]) {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                message:@"Please try again"
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                      otherButtonTitles:nil] show];
  }
  else {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Catastrophic Error", @"")
                                message:[NSString stringWithFormat:@"%@",response]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                      otherButtonTitles:nil] show];
  }
}

#pragma mark - PopoverViewDelegate Protocol methods
- (void) popoverActionConfirmed:(UIView *)popover {
  
  ClarifyLocationView *theView = (ClarifyLocationView *)popover;
  CLLocationCoordinate2D betterLocation = CLLocationCoordinate2DMake(theView.mapView.centerCoordinate.latitude, theView.mapView.centerCoordinate.longitude);
  [self updateReportNumber:theView.tag WithLocation:betterLocation];
  
  [UIView animateWithDuration:0.5 animations:^(void) {
      _popoverMap.topEdge = self.view.bottomEdge;
    } completion:^(BOOL finished) {
      [popover removeFromSuperview];
    }
  ];
}
- (void) popoverActionCanceled:(UIView *)popover {
  [UIView animateWithDuration:0.5 animations:^(void) {
      _popoverMap.topEdge = self.view.bottomEdge;
    } completion:^(BOOL finished) {
      [popover removeFromSuperview];
    }
  ];
}
- (void) popoverDismissMe:(UIView *)popover {
  [UIView animateWithDuration:0.5 animations:^(void) {
      _popoverMap.topEdge = self.view.bottomEdge;
    } completion:^(BOOL finished) {
      [popover removeFromSuperview];
    }
  ];
}


@end
