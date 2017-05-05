
#import <UIKit/UIKit.h>
#import "Usage.h"
#import "CustomLabel.h"

@interface QuotaInfoCell : UITableViewCell

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) title withUsage:(Usage *) usage withCellRect:(CGRect) rect showInternetData:(BOOL) shouldShow;

- (id) initWithFrame:(CGRect)frame withTitle:(NSString *) title withUsage:(Usage *) usage withCellRect:(CGRect *) rect showInternetData:(BOOL) shouldShow;

@property (nonatomic, strong) UIView *packageUsageContainer;
@property (nonatomic, strong) UIProgressView *packageUsageBar;
@property (nonatomic, strong) CustomLabel *sizeOfUsedPackageLabel;
@property (nonatomic, strong) CustomLabel *sizeOfPackageLabel;
@property (nonatomic, strong) CustomLabel *sizeUnitLabel;

@end
