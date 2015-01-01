#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RoadkillReport : NSObject

@property (nonatomic) int reportId;
@property (nonatomic) NSString *animalName;
@property (nonatomic) float distance;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) BOOL loc_updated;
@property (nonatomic) float accuracy;
@property (nonatomic, strong) NSDate *dateReported;

- (RoadkillReport *)initWithDictionary:(NSDictionary *)dict;
+ (RoadkillReport *)findReportInDictionary:(NSDictionary *)dictionary WithReportId:(int)reportId;
- (NSString *)getTitle;
- (NSString *)getSubtitle;
- (NSString *)getDistanceText;
- (NSString *)getAccuracyText;
- (NSString *)getDistanceAccuracyText;
- (NSString *)getAgeText;
- (NSString *)getAgeNameText;
- (NSTimeInterval)getAgeInSeconds;
- (CLLocationCoordinate2D)coordinate;
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate;
- (int)getAgeInHours;
- (int)getAgeInDays;

@end
