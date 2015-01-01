#import <MapKit/MapKit.h>
#import "RoadkillReport.h"

@implementation RoadkillReport

- (RoadkillReport *)initWithDictionary:(NSDictionary *)dict {
  
  self = [self init];
  
  _reportId = [[dict objectForKey:@"report_id"] intValue];
  _animalName = [[dict objectForKey:@"name"] stringValue];
  _distance = [[dict objectForKey:@"dist"] floatValue];
  _latitude = [[dict objectForKey:@"lat"] floatValue];
  _longitude = [[dict objectForKey:@"lon"] floatValue];
  _loc_updated = [[dict objectForKey:@"loc_updated"] boolValue];
  _accuracy = [[dict objectForKey:@"accuracy"] floatValue];
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.sss'Z'"];
  _dateReported = [formatter dateFromString:[dict objectForKey:@"time"]];
  
  return self;
}

+ (RoadkillReport *)findReportInDictionary:(NSDictionary *)dictionary WithReportId:(int)reportId {
  NSArray *reports = [dictionary objectForKey:@"rows"];
  for (NSDictionary *reportDict in reports) {
    if ([[reportDict objectForKey:@"report_id"] intValue] == reportId) {
      return [[RoadkillReport alloc] initWithDictionary:reportDict];
    }
  }
  return nil;
}

- (NSString *)getTitle {
  return [self getDistanceText];
}

- (NSString *)getSubtitle {
  return [[self getAccuracyText] stringByAppendingString:[NSString stringWithFormat:@"  %@",[self getAgeText]]];
}

- (NSString *)animalName {
  if ([_animalName length] == 0) {
    return @"Raccoon";
  }
  else {
    return _animalName;
  }
}

- (NSString *)getDistanceText {
  NSString *distanceText;
  if (_distance < 1000) {
    distanceText = [NSString stringWithFormat:@"%dm away",(int)_distance];
  }
  else {
    distanceText = [NSString stringWithFormat:@"%dkm away",(int)_distance/1000];
  }
  return distanceText;
}

- (NSString *)getAccuracyText {
  NSString *accuracyText;
  if (_accuracy < 1000) {
    accuracyText = [NSString stringWithFormat:@"accurate within %dm",(int)_accuracy];
  }
  else {
    accuracyText = [NSString stringWithFormat:@"accurate within %dkm",(int)_accuracy/1000];
  }
  return accuracyText;
}

- (NSString *)getDistanceAccuracyText {
  return [[self getDistanceText] stringByAppendingFormat:@", %@",[self getAccuracyText]];
}

- (NSString *)getAgeText {
  
  int daysOld = [self getAgeInDays];
  
  NSString *ageText;
  switch (daysOld) {
    case 0:
      ageText = @"Today!";
      break;
    case 1:
      ageText = @"Yesterday";
      break;
    default:
      ageText = [NSString stringWithFormat:@"%d days ago",daysOld];
      break;
  }
  return ageText;
}

- (NSString *)getAgeNameText {
  return [self.animalName stringByAppendingFormat:@", %@",[self getAgeText]];
}

- (NSTimeInterval)getAgeInSeconds {
  NSDate *now = [[NSDate alloc] init];
  return [now timeIntervalSinceDate:_dateReported];
}

- (int)getAgeInHours {
  return [self getAgeInSeconds]/3600;
}

- (int)getAgeInDays {
  return [self getAgeInHours]/24;
}

- (CLLocationCoordinate2D)coordinate {
  return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
  self.latitude = coordinate.latitude;
  self.longitude = coordinate.longitude;
}

@end
