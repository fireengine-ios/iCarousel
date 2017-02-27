
#import <UIKit/UIKit.h>
#import "Usage.h"
#import "CustomLabel.h"

@interface QuotaInfoView : UIView

- (id) initWithFrame:(CGRect)frame withTitle:(NSString *) title withUsage:(Usage *) usage withControllerView:(UIView *) view showInternetData:(BOOL) shouldShow;

@property (nonatomic, strong) UIView *packageUsageContainer;
@property (nonatomic, strong) UIProgressView *packageUsageBar;
@property (nonatomic, strong) CustomLabel *sizeOfUsedPackageLabel;
@property (nonatomic, strong) CustomLabel *sizeOfPackageLabel;
@property (nonatomic, strong) CustomLabel *sizeUnitLabel;

@end
