//
//  RememberMeEmailViewController.m
//  Depo
//
//  Created by Mahir on 20/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RememberMeEmailViewController.h"
#import "Util.h"
#import "CustomLabel.h"

#define kOFFSET_FOR_KEYBOARD 100.0

@interface RememberMeEmailViewController () {
    UIScrollView* container;
}

@end

@implementation RememberMeEmailViewController

@synthesize emailField;
@synthesize captchaField;
@synthesize captchaView;
@synthesize refreshButton;
@synthesize okButton;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"ForgotPassTitle", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        self.navigationItem.leftBarButtonItem = nil;
        
        captchaDao = [[RequestCaptchaDao alloc] init];
        captchaDao.delegate = self;
        captchaDao.successMethod = @selector(captchaSuccessCallback:);
        captchaDao.failMethod = @selector(captchaFailCallback:);

        forgotPassDao = [[ForgotPassDao alloc] init];
        forgotPassDao.delegate = self;
        forgotPassDao.successMethod = @selector(forgotPassSuccessCallback:);
        forgotPassDao.failMethod = @selector(forgotPassFailCallback:);
        
        float containerWidth = self.view.frame.size.width - 40;
        float logoPaddingTop = 20;
        if (IS_IPAD) {
            containerWidth = 480;
            logoPaddingTop = 200;
        }
        float containerLeftMargin = (self.view.frame.size.width - containerWidth)/2;
        
        container = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:container];
        
        UIImage *logoImage = [UIImage imageNamed:@"icon_lifebox.png"];
        UIImageView *logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - logoImage.size.width)/2, logoPaddingTop, logoImage.size.width, logoImage.size.height)];
        logoImgView.image = logoImage;
//        [self.view addSubview:logoImgView];
        [container addSubview:logoImgView];
        
//        CustomLabel *subInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width-40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:15] withColor:[Util UIColorForHexColor:@"3E3E3E"] withText:NSLocalizedString(@"EmailFieldRegistrationInfo", @"") withAlignment:NSTextAlignmentCenter];
//        [self.view addSubview:subInfoLabel];
        
        CustomLabel *emailLabel = [[CustomLabel alloc] initWithFrame:
                                   CGRectMake(containerLeftMargin, logoImgView.frame.origin.y + logoImgView.frame.size.height + 10, containerWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"FormEmailTitle", @"")];
//        [self.view addSubview:emailLabel];
        [container addSubview:emailLabel];
        
        emailField = [[LoginTextfield alloc] initWithFrame:CGRectMake(containerLeftMargin, emailLabel.frame.origin.y + 5, containerWidth, 43) withPlaceholder:/*NSLocalizedString(@"EmailPlaceholder", @"")*/@""];
        emailField.delegate = self;
        emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//        [self.view addSubview:emailField];
        emailField.isAccessibilityElement = YES;
        emailField.accessibilityIdentifier = @"emailFieldForgotPass";
        [container addSubview:emailField];
        
        captchaView = [[UIImageView alloc] initWithFrame:CGRectMake(containerLeftMargin, emailField.frame.origin.y + emailField.frame.size.height + 20, 200, 50)];
        UIImage *image = [UIImage imageNamed:@"bg_captcha.png"];
        CGSize newSize = captchaView.frame.size;
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        captchaView.backgroundColor = [UIColor colorWithPatternImage:newImage];
        //captchaView.contentMode = UIViewContentModeScaleAspectFill;
//        [self.view addSubview:captchaView];
        captchaView.isAccessibilityElement = YES;
        captchaView.accessibilityIdentifier = @"captchaViewForgotPass";
        [container addSubview:captchaView];
        
        refreshButton = [[CustomButton alloc] initWithFrame:CGRectMake(captchaView.frame.origin.x + captchaView.frame.size.width + 32, captchaView.frame.origin.y + (captchaView.frame.size.height - 18)/2, 18, 18) withImageName:@"icon_captcha_refresh.png"];
        refreshButton.hidden = YES;
        [refreshButton addTarget:self action:@selector(loadCaptcha) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:refreshButton];
        refreshButton.isAccessibilityElement = YES;
        refreshButton.accessibilityIdentifier = @"refreshButtonForgotPass";
        [container addSubview:refreshButton];
        
        CustomLabel *captchaLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(containerLeftMargin, captchaView.frame.origin.y + captchaView.frame.size.height + 20, containerWidth, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"CaptchaTitle", @"")];
//        [self.view addSubview:captchaLabel];
        [container addSubview:captchaLabel];

        captchaField = [[LoginTextfield alloc] initWithFrame:CGRectMake(containerLeftMargin, captchaLabel.frame.origin.y + 5, containerWidth, 43) withPlaceholder:/*NSLocalizedString(@"CaptchaPlaceholder", @"")*/@""];
        captchaField.delegate = self;
        captchaField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//        [self.view addSubview:captchaField];
        captchaField.isAccessibilityElement = YES;
        captchaField.accessibilityIdentifier = @"captchaFieldForgotPass";
        [container addSubview:captchaField];
        
        UIFont *infoFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:17];
        float infoHeight = [Util calculateHeightForText:NSLocalizedString(@"ForgetPass2222Info", @"") forWidth:containerWidth-20 forFont:infoFont] + 20;
        CustomLabel *smsInfoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(containerLeftMargin+10, captchaField.frame.origin.y + captchaField.frame.size.height + 20, containerWidth-20, infoHeight) withFont:infoFont withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"ForgetPass2222Info", @"") withAlignment:NSTextAlignmentCenter numberOfLines:0];
//        [self.view addSubview:smsInfoLabel];
        [container addSubview:smsInfoLabel];
        
        okButton = [[SimpleButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60) withTitle:NSLocalizedString(@"OK", @"") withTitleColor:[Util UIColorForHexColor:@"ffffff"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withBorderColor:[Util UIColorForHexColor:@"3FB0E8"] withBgColor:[Util UIColorForHexColor:@"3FB0E8"] withCornerRadius:0];
        [okButton addTarget:self action:@selector(forgotPassClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:okButton];
        okButton.isAccessibilityElement = YES;
        okButton.accessibilityIdentifier = @"okButtonForgotPass";
        [container addSubview:okButton];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];

        self.navigationItem.leftBarButtonItem.enabled = NO;
        
        [self performSelector:@selector(loadCaptcha) withObject:nil afterDelay:0.0f];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}

- (void) triggerResign {
    [self.view endEditing:YES];
}

- (void) loadCaptcha {
    captchaUniqueId = [[NSUUID UUID] UUIDString];
    [captchaDao requestCaptchaForType:@"IMAGE" andId:captchaUniqueId];
}

- (void) forgotPassClicked {
    if([emailField.text length] == 0 || ![Util isValidEmail:emailField.text]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"EmailFormatErrorMessage", @"")];
        return;
    }
    if([captchaField.text length] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"CaptchaFieldErrorMessage", @"")];
        return;
    }
    
    [self.view endEditing:YES];
    
    [forgotPassDao requestNotifyForgotPassWithEmail:emailField.text withCaptchaId:captchaUniqueId withCaptchaValue:captchaField.text];
    [self showLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 24, 24) withImageName:@"icon_ustbar_back.png"];
    [customBackButton addTarget:self action:@selector(innerTriggerBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) captchaSuccessCallback:(UIImage *) captchaImg {
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    captchaView.image = captchaImg;
    refreshButton.hidden = NO;
}

- (void) captchaFailCallback:(NSString *) errorMessage {
    self.navigationItem.leftBarButtonItem.enabled = YES;

    [self showErrorAlertWithMessage:errorMessage];
}

- (void) forgotPassSuccessCallback:(NSDictionary *) resultDict {
    [self hideLoading];
    NSString *errorMsg = [resultDict objectForKey:@"errorMsg"];
    if(errorMsg != nil && ![errorMsg isKindOfClass:[NSNull class]]) {
        if([errorMsg hasPrefix:@"User can not change password"]) {
            [self showInfoAlertWithMessage:NSLocalizedString(@"EmailError2222", @"")];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        } else if([errorMsg isEqualToString:@"ACCOUNT_NOT_FOUND_FOR_EMAIL"]) {
            [self showInfoAlertWithMessage:NSLocalizedString(@"EmailNotFound", @"")];
            return;
        }
    }
    [self showInfoAlertWithMessage:NSLocalizedString(@"PassSentToEmail", @"")];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) forgotPassFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
    
    captchaField.text = @"";
    [self loadCaptcha];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [emailField resignFirstResponder];
    [captchaField resignFirstResponder];
    return YES;
}

-(void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [self setViewMovedUp:YES keyboardSize:keyboardFrameBeginRect.size];
}

-(void)keyboardWillHide {
//    if (self.view.frame.origin.y < 0) {
        [self setViewMovedUp:NO keyboardSize:CGSizeZero];
//    }
}

//-(void)setViewMovedUp:(BOOL)movedUp {
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.2];
//    
//    CGRect rect = self.view.frame;
//    if (movedUp) {
//        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
//        rect.size.height += kOFFSET_FOR_KEYBOARD;
//    } else {
//        rect.origin.y += kOFFSET_FOR_KEYBOARD;
//        rect.size.height -= kOFFSET_FOR_KEYBOARD;
//    }
//    self.view.frame = rect;
//    
//    [UIView commitAnimations];
//}

- (void) innerTriggerBack {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setViewMovedUp:(BOOL)movedUp keyboardSize:(CGSize)ksize {
    if (movedUp) {
        
        container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + (IS_IPHONE_6P_OR_HIGHER ? 0 : IS_IPAD ? 0 : 280));
//        [container setContentOffset:CGPointMake(0, 230) animated:YES];
        okButton.frame = CGRectMake(0, self.view.frame.size.height - (IS_IPHONE_6P_OR_HIGHER ? 285 : IS_IPAD ? (ksize.height + 60) : 60), self.view.frame.size.width, 60);
        
    } else {
        container.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
//        [container setContentOffset:CGPointZero animated:YES];
        okButton.frame = CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60);
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
