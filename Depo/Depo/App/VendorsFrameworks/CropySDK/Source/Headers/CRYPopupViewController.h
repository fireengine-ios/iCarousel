//
//  CRYPopupViewController.h
//  CropyMain
//
//  Created by Erkan Sulungoz on 16/06/2017.
//  Copyright © 2017 Alper KIRDÖK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CRYAlertControllerDelegate <NSObject>
- (void) showAlertController:(BOOL)cancelTapped checkFunc:(int) funcValue;
- (void)goToSettings;

@end

@interface CRYPopupViewController : UIViewController

@property (strong, nonatomic) id <CRYAlertControllerDelegate> alertViewControllerDelegate;

@property (weak, nonatomic) IBOutlet UIImageView *popupImageview;
@property (weak, nonatomic) IBOutlet UILabel *popupTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *popupDescLabel;

- (IBAction)dismissButtonTapped:(id)sender;

@property (nonatomic, strong) NSString *titleLabel;
@property (nonatomic, strong) NSString *descLabel;
@property (nonatomic, assign) int type;
@property (assign) BOOL checkLocalizedString;

@property (weak, nonatomic) IBOutlet UIButton *buttonTitle;
@property (nonatomic, strong) NSString *buttonLabel;
@property (nonatomic, strong) NSString *staticButtonText;
@property (weak, nonatomic) IBOutlet UIView *alertControllerView;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)okButtonTapped:(id)sender;

@property (assign) BOOL checkCancelView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonTitle;
@property (weak, nonatomic) IBOutlet UIButton *okButtonTitle;
@property (nonatomic, strong) NSString *okButtonLabel;
@property (nonatomic, strong) NSString *cancelButtonLabel;
@property (nonatomic, strong) NSString *cancelButtonLabelValue;
@property (nonatomic, strong) NSString *okButtonLabeValue;
@property (nonatomic, assign) int funcValue;

@property (nonatomic, assign)BOOL attributed;
@property (nonatomic, strong)NSMutableAttributedString *attributedString;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewTitleHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewHeightConstraint;
@end
