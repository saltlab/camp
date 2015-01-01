#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RoadkillReport.h"
#import "PopoverViewDelegate.h"

@interface ClarifyLocationView : UIView

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) id<PopoverViewDelegate> delegate;

@property (strong, nonatomic) RoadkillReport *report;

@end