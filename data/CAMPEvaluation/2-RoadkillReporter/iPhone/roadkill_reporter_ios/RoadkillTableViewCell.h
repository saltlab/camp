#import <UIKit/UIKit.h>

@interface RoadkillTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *animalLabel;
@property (strong, nonatomic) IBOutlet UILabel *distLabel;
@property (strong, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIImageView *warningIcon;

@end
