//
//  ReachUsController.m
//  Depo
//
//  Created by Mahir Tarlan on 04/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "ReachUsController.h"
#import "SimpleButton.h"
#import "Util.h"
#import "CustomLabel.h"
#import "AppUtil.h"
#import "FeedbackChoiceCell.h"
#import "AppDelegate.h"
#import "ReachabilityManager.h"
#import "BaseViewController.h"

@interface ReachUsController () {
    NSNumber *selectedFeedbackType;
}
@end

@implementation ReachUsController

@synthesize dao;
@synthesize accountDao;
@synthesize choiceTable;
@synthesize textView;
@synthesize subscriptions;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [Util UIColorForHexColor:@"f5f5f5"];
        self.title = NSLocalizedString(@"ReachUsTitle", @"");

        float yIndex = (IS_IPAD ? 50 : IS_IPHONE_5 ? 20 : 0);

        dao = [[FeedbackDao alloc] init];
        dao.delegate = self;
        dao.successMethod = @selector(feedbackSuccessCallback);
        dao.failMethod = @selector(feedbackFailCallback:);

        accountDao = [[AccountDao alloc] init];
        accountDao.delegate = self;
        accountDao.successMethod = @selector(accountSuccessCallback:);
        accountDao.failMethod = @selector(accountFailCallback:);

        /*
        if(![AppUtil isAlreadyRated]) {
            SimpleButton *rateButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 150)/2, yIndex, 150, 44) withTitle:NSLocalizedString(@"RateButton", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:22];
            [rateButton addTarget:self action:@selector(triggerRateUs) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:rateButton];
        }
         */
        yIndex += 50;

        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, yIndex, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"888888"] withText:NSLocalizedString(@"ReachUsInfo", @"")];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:titleLabel];

        yIndex += 40;
        
        choiceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, yIndex, self.view.frame.size.width, 80) style:UITableViewStylePlain];
        choiceTable.delegate = self;
        choiceTable.dataSource = self;
        choiceTable.backgroundColor = [UIColor clearColor];
        choiceTable.backgroundView = nil;
        choiceTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        choiceTable.bounces = NO;
        [self.view addSubview:choiceTable];
        
        yIndex += 100;
        
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, yIndex, self.view.frame.size.width, 140)];
        textView.backgroundColor = [UIColor whiteColor];
        textView.delegate = self;
        textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:14];
        textView.text = NSLocalizedString(@"FeedbackPlaceholder", @"");
        textView.textColor = [Util UIColorForHexColor:@"aaaaaa"];
        [self.view addSubview:textView];

        yIndex += 160;

        CustomButton *sendButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"SendButton", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
//        SimpleButton *sendButton = [[SimpleButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2, yIndex, 100, 44) withTitle:NSLocalizedString(@"SendButton", @"") withTitleColor:[Util UIColorForHexColor:@"363e4f"] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withBorderColor:[Util UIColorForHexColor:@"ffe000"] withBgColor:[Util UIColorForHexColor:@"ffe000"] withCornerRadius:5];
        [sendButton addTarget:self action:@selector(triggerSend) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:sendButton];
        UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
        self.navigationItem.rightBarButtonItem = sendItem;

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];
        
        [accountDao requestActiveSubscriptions];
        [self showLoading];
        
        [self performSelector:@selector(selectInitialCell) withObject:nil afterDelay:0.1f];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuToggle) name:MENU_CLOSED_NOTIFICATION object:nil];
    }
    return self;
}

- (void) selectInitialCell {
    [self.choiceTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    selectedFeedbackType = [NSNumber numberWithInt:FeedBackTypeSuggestion];
}

- (void) accountSuccessCallback:(NSArray *) _subscriptions {
    [self hideLoading];
    self.subscriptions = _subscriptions;
}

- (void) accountFailCallback:(NSString *) errorMessage{
    [self hideLoading];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]] || [touch.view isDescendantOfView:choiceTable]) {
        return NO;
    }
    return YES;
}

- (void) triggerResign {
    [self.view endEditing:YES];
}

- (void) triggerSend {
    if(selectedFeedbackType == nil) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"FeedbackChoiceError", @"")];
        return;
    }
    if([textView.text isEqualToString:NSLocalizedString(@"FeedbackPlaceholder", @"")]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"FeedbackTextError", @"")];
        return;
    }
    
    [self triggerMailComposeView];
//    [dao requestSendFeedbackWithType:[selectedFeedbackType intValue] andMessage:textView.text];
//    [self showLoading];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *indicator = [NSString stringWithFormat:@"FEEDBACK_CELL_%d", (int)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indicator];
    if(!cell) {
        if(indexPath.row == 0) {
            cell = [[FeedbackChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indicator withType:FeedBackTypeSuggestion];
        } else {
            cell = [[FeedbackChoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indicator withType:FeedBackTypeComplaint];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        selectedFeedbackType = [NSNumber numberWithInt:FeedBackTypeSuggestion];
    } else {
        selectedFeedbackType = [NSNumber numberWithInt:FeedBackTypeComplaint];
    }
}

- (void) feedbackSuccessCallback {
    [self hideLoading];
    [self showInfoAlertWithMessage:NSLocalizedString(@"MessageSentSuccessfully", @"")];
}

- (void) feedbackFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) triggerRateUs {
}

- (void)textViewDidBeginEditing:(UITextView *)_textView {
    if ([textView.text isEqualToString:NSLocalizedString(@"FeedbackPlaceholder", @"")]) {
        textView.text = @"";
        textView.textColor = [Util UIColorForHexColor:@"555555"];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)_textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = NSLocalizedString(@"FeedbackPlaceholder", @"");
        textView.textColor = [Util UIColorForHexColor:@"aaaaaa"];
    }
    [textView resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"ReachUsController viewDidLoad");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) triggerMailComposeView {
    if([MFMailComposeViewController canSendMail]) {
        FeedBackType type = [selectedFeedbackType intValue];

        NSString *messageSubject = type == FeedBackTypeComplaint ? NSLocalizedString(@"ComplaintSubject", @"") : NSLocalizedString(@"SuggestionSubject", @"");
        
        NSMutableString *packageInfo = [[NSMutableString alloc] init];
        if(self.subscriptions) {
            for(Subscription *row in self.subscriptions) {
                [packageInfo appendString:[NSString stringWithFormat:@"%@\n", row.plan.displayName]];
            }
        }
        NSString *clientInfo = [NSString stringWithFormat:@"Application Version: %@\nMsisdn: %@\nCarrier: %@\nDevice:%@\nDevice OS:%@\nLanguage:%@\nNetwork Status:%@\nTotal Storage:%lld\nUsed Storage:%lld\nPackages:%@\n", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], APPDELEGATE.session.user.phoneNumber, [AppUtil operatorName], [UIDevice currentDevice].model, [[UIDevice currentDevice] systemVersion], [Util readLocaleCode], [ReachabilityManager isReachableViaWWAN] ? @"WWAN" : @"WIFI", APPDELEGATE.session.usage.totalStorage, APPDELEGATE.session.usage.usedStorage, packageInfo];

        NSString *messageBody = [NSString stringWithFormat:@"%@\n\n%@\n\n%@", textView.text, NSLocalizedString(@"MailWarning", @""), clientInfo];
        
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        
        [mailCont setSubject:messageSubject];
        [mailCont setToRecipients:[NSArray arrayWithObject:REACH_US_MAIL_ADDRESS]];
        [mailCont setMessageBody:messageBody isHTML:NO];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"iglogs.log"];
        if([[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
            NSData *logData = [NSData dataWithContentsOfFile:logPath];
            [mailCont addAttachmentData:logData mimeType:@"text/plain" fileName:@"logs.txt"];
        }

        [APPDELEGATE.base presentViewController:mailCont animated:YES completion:nil];
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(@"NoEmailAccountError", @"")];
    }
}

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if(result == 2) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"iglogs.log"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:logPath error:nil];

        CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withMessage:NSLocalizedString(@"MessageSentSuccessfully", @"") withModalType:ModalTypeSuccess];
        alert.delegate = self;
        [APPDELEGATE showCustomAlert:alert];
    }
}

- (void) didDismissCustomAlert:(CustomAlertView *) alertView {
    [[NSNotificationCenter defaultCenter] postNotificationName:PHOTOS_SCREEN_AUTO_TRIGGERED_NOTIFICATION object:nil];
}

- (void) menuToggle {
    [self.view endEditing:YES];
}

@end
