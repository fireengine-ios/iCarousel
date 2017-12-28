//
//  CRYShareViewController.h
//  CropyMain
//
//  Created by Fatih Caglar on 17/06/16.
//  Copyright © 2016 Alper KIRDÖK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLDUtils.h"
#import "CRYShareViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CRYReachability.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface CRYShareViewController : UIViewController <NSURLConnectionDelegate> {
    
    //** imageView
    __weak IBOutlet UIImageView *imageViewShareImage;
    __weak IBOutlet UIImageView *imageTriangleGsm;
    __weak IBOutlet UIImageView *imageTriangleEmail;
    __weak IBOutlet UIImageView *akilliDepoBeyazImageView;
    __weak IBOutlet UIImageView *akilliDepoBeyaz2ImageView;
    __weak IBOutlet UIImageView *akilliDepoMavi;

    //** scrollView
    __weak IBOutlet TPKeyboardAvoidingScrollView *scrollViewAkilliDepo;

    //**label
    __weak IBOutlet UILabel *labelInfo;
    __weak IBOutlet UILabel *labelUserContract;
    __weak IBOutlet UILabel *labelHeader;
    __weak IBOutlet UILabel *labelSignUpPopUpHeader;
    __weak IBOutlet UILabel *labelSignUpDescription;
    __weak IBOutlet UILabel *labelSignUpOffer;
    
    //** button
    __weak IBOutlet UIButton *buttonSaveAkilliDepo;
    __weak IBOutlet UIButton *buttonGsm;
    __weak IBOutlet UIButton *buttonEmail;
    __weak IBOutlet UIButton *buttonCancel;
    __weak IBOutlet UIButton *buttonLogin;
    __weak IBOutlet UIButton *buttonCheckBox;
    __weak IBOutlet UIButton *buttonNo;
    __weak IBOutlet UIButton *buttonYes;
    __weak IBOutlet UIButton *buttonSignUpPopUp;
    __weak IBOutlet UIButton *checkBoxButtonOutlet;
    
    //**view
    __weak IBOutlet UIView *viewGray;
    __weak IBOutlet UIView *viewLoginPopUp;
    __weak IBOutlet UIView *viewGsm;
    __weak IBOutlet UIView *viewEmail;
    __weak IBOutlet UIView *viewPassword;
    __weak IBOutlet UIView *viewEmailSmallContainer;
    __weak IBOutlet UIView *viewGsmNumberSmallContainer;
    __weak IBOutlet UIView *viewGsmPrefixSmallContainer;
    __weak IBOutlet UIView *viewPaswordSmallContainer;
    __weak IBOutlet UIView *viewSignUpContainer;
    __weak IBOutlet UIView *viewLoginContainer;
    __weak IBOutlet UIView *viewPopUpContainer;

    //** textField
    __weak IBOutlet UITextField *textfieldGsmPrefix;
    __weak IBOutlet UITextField *textFieldGsmNumber;
    __weak IBOutlet UITextField *textFieldEmail;
    __weak IBOutlet UITextField *textFieldPassword;
    
    __weak IBOutlet UIButton *backButtonOutlet;
    
}

+(CRYShareViewController*) getInstanceWithImage:(UIImage *)image;

#pragma mark - Properties
/* image */
@property (nonatomic, strong) UIImage *imageToShare;

/* string */
@property (nonatomic, strong) NSString *authToken;

/* integer */
@property (nonatomic, assign) NSInteger idFromEulaGetService;
@property (nonatomic, assign) NSInteger error401Counter;

/* bool */
@property (nonatomic, assign) BOOL isGsmSelected;
@property (nonatomic, assign) BOOL isUserContractFirstTimeOpened;
@property (nonatomic, assign) BOOL keyboardIsShown;
@property (nonatomic, assign) BOOL saveFirstTimeToAlbum;
@property (nonatomic, assign) BOOL sharedAndSaved;

#pragma mark - Button Actions
- (IBAction)buttonSaveAkilliDepoTapped:(id)sender;
- (IBAction)buttonCancelTapped:(id)sender;
- (IBAction)buttonLoginTapped:(id)sender;
- (IBAction)buttonGsmTapped:(id)sender;
- (IBAction)buttonEmailTapped:(id)sender;

- (IBAction)textFieldGsmPrefixDoneTapped:(id)sender;
- (IBAction)textFieldGsmNumberDoneTapped:(id)sender;
- (IBAction)textFieldEmailDoneTapped:(id)sender;
- (IBAction)textFieldPasswordDoneTapped:(id)sender;
- (IBAction)buttonSeeUserContractTapped:(id)sender;
- (IBAction)buttonCheckBoxTapped:(id)sender;
- (IBAction)buttonNoTapped:(id)sender;
- (IBAction)buttonYesTapped:(id)sender;
- (IBAction)textfieldPhonePrefixEditingBegin:(id)sender;
- (IBAction)buttonSignUpPopUpTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;

@end
