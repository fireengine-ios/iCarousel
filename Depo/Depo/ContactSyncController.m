//
//  ContactSyncController.m
//  Depo
//
//  Created by Mahir on 06/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ContactSyncController.h"
#import "Util.h"
#import "SyncUtil.h"
#import "CacheUtil.h"
#import "AppUtil.h"
#import "ContactSyncResultCell.h"
#import "ContactSyncResultTitleCell.h"
#import "SimpleButton.h"
#import "ContactSyncSDK.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "AppConstants.h"
#import "BaseViewController.h"
#import "RequestTokenDao.h"
#import "RadiusDao.h"
#import "Reachability.h"
#import "ContactSyncView.h"
#import "ContactSyncProgressView.h"
#import "ContactSyncFooterElement.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#define tableViewHeaderHeight 40.0f
#define tableViewRowHeight 40.0f
#define tableViewRowCount 5

@interface ContactSyncController () {
//    sayfa degistirildiginde 1 saniyeligine daha ekran kalmasi icin super view'deki kullanilmadi
    ProcessFooterView *processView;
    SYNCMode syncMode;
    
}

@property (nonatomic, assign) BOOL triedAgain;
@property (nonatomic) NSString* errMessage;
@property (nonatomic) RequestTokenDao *tokenDao;
@property (nonatomic) RadiusDao *radiusDao;
@property (nonatomic) int constant;
@property (nonatomic) ContactSyncFooterElement *totalContactElement;
@property (nonatomic) ContactSyncFooterElement *cleanContactElement;
@property (nonatomic) ContactSyncFooterElement *deleteContactElement;
@property (nonatomic) NSString *syncProcessStepToLog;

@end

@implementation ContactSyncController

@synthesize oldSyncOption;
@synthesize backupButton;
@synthesize restoreButton;
@synthesize lastSyncDateLabel;
@synthesize progressView;
@synthesize syncView;
@synthesize syncResultView;
@synthesize totalContactElement;
@synthesize cleanContactElement;
@synthesize deleteContactElement;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"ContactSyncTitle", @"");
        
        // Get Last Sync Results
        if([SyncUtil readLastContactSyncDate] == nil) {
            lastSyncDateLabel.hidden = YES;
        } else {
            APPDELEGATE.session.syncResult = [ContactSyncResult loadData];;
        }
        
        self.topContainer = [[UIView alloc] initWithFrame:CGRectMake(20, IS_IPHONE_6P_OR_HIGHER ? 40 : 20, self.view.frame.size.width-40, (self.view.frame.size.height/5)*(IS_IPAD ? 3.5 : 2.5))];
//        self.topContainer.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:self.topContainer];
        
        // Contact Progress View
        progressView = [[ContactSyncProgressView alloc] initWithFrame:CGRectMake(0, 0, self.topContainer.frame.size.width, self.topContainer.frame.size.height)];
        
        // Contact Sync View
        syncView = [[ContactSyncView alloc] initWithFrame:CGRectMake(0, 20, self.topContainer.frame.size.width, self.topContainer.frame.size.height)];
        syncView.delegate = self;
        
        // Contact Sync Result View
        syncResultView = [[ContactSyncResultView alloc] initWithFrame:CGRectMake(0, 20, self.topContainer.frame.size.width, self.topContainer.frame.size.height)];
        
        progressView.pieChart.dataSource = self;
        progressView.pieChart.delegate = self;
        progressView.pieChart.startPieAngle = -M_PI_2;
//        progressView.pieChart.animationSpeed = 0.5;
        progressView.pieChart.showLabel = NO;
        progressView.pieChart.showPercentage = NO;
        progressView.pieChart.pieBackgroundColor = [UIColor clearColor];
        //progressView.pieCenter = CGPointMake(200, 200);
        progressView.pieChart.userInteractionEnabled = NO;
        progressView.pieChart.labelShadowColor = [UIColor blackColor];
        
        
        // Footer Elements
        self.footerContainer = [[UIView alloc] initWithFrame:CGRectMake(20, self.topContainer.frame.origin.y + self.topContainer.frame.size.height + (IS_IPHONE_6P_OR_HIGHER ? 60 : 20), self.view.frame.size.width - 40, 20)];
        [self.view addSubview:self.footerContainer];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"D4D4D4"];
        [self.footerContainer addSubview:separator];
        
        totalContactElement = [[ContactSyncFooterElement alloc] initWithFrame:CGRectMake(0, 20, self.footerContainer.frame.size.width/3, self.footerContainer.frame.size.height) withTitle:NSLocalizedString(@"ContactLastSyncDetailContactsTitle", @"")];
        [self.footerContainer addSubview:totalContactElement];
        
        cleanContactElement = [[ContactSyncFooterElement alloc] initWithFrame:CGRectMake(totalContactElement.frame.size.width + 10, totalContactElement.frame.origin.y, self.footerContainer.frame.size.width/3, self.footerContainer.frame.size.height) withTitle:NSLocalizedString(@"ContactLastSyncDetailUpdateTitle", @"")];
        [self.footerContainer addSubview:cleanContactElement];
        
        deleteContactElement = [[ContactSyncFooterElement alloc] initWithFrame:CGRectMake(cleanContactElement.frame.origin.x + cleanContactElement.frame.size.width + 10, totalContactElement.frame.origin.y, self.footerContainer.frame.size.width/3, self.footerContainer.frame.size.height) withTitle:NSLocalizedString(@"ContactLastSyncDetailDeleteTitle", @"")];
        [self.footerContainer addSubview:deleteContactElement];
        
        [self refreshSyncResult:APPDELEGATE.session.syncResult.syncType];
        
        // Last Sync Date Label
        
        NSString *lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), NSLocalizedString(@"NoneTitle", @"")];
        if([SyncUtil readLastContactSyncDate] != nil) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
            lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), [dateFormat stringFromDate:[SyncUtil readLastContactSyncDate]]];
        }
        lastSyncDateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(((self.view.frame.size.width - (self.view.frame.size.width - 40))/2), self.view.frame.size.height - 110, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:12] withColor:[Util UIColorForHexColor:@"363e4f"] withText:lastSyncTitle withAlignment:NSTextAlignmentCenter];
        [self.view addSubview:lastSyncDateLabel];
        NSLog(@"%@", lastSyncTitle);
        
        
        // Sync Callback
        
        [SyncSettings shared].progressCallback = ^void(void){
            NSString *step = nil;
            switch ([SyncStatus shared].step){
                case SYNC_STEP_INITIAL:{
                    step = @"Initializing";
                    NSLog(@"progress : %@ %d",step,[[SyncStatus shared].progress intValue]);
                    break;
                }
                case SYNC_STEP_READ_LOCAL_CONTACTS:{
                    step = @"Processing local contacts";
                    NSLog(@"progress : %@ %d",step,[[SyncStatus shared].progress intValue]);
                    break;
                }
                case SYNC_STEP_CHECK_SERVER_STATUS:{
                    step = @"Reading server info";
                    NSLog(@"progress : %@ %d",step,[[SyncStatus shared].progress intValue]);
                    break;
                }
                case SYNC_STEP_SERVER_IN_PROGRESS:{
                    step = @"In progress...";
                    NSLog(@"progress : %@ %d",step,[[SyncStatus shared].progress intValue]);
                    break;
                }
                case SYNC_STEP_PROCESSING_RESPONSE:{
                    step = @"Processing response";
                    NSLog(@"progress : %@ %d",step,[[SyncStatus shared].progress intValue]);
                    break;
                }
            }
            
            if (![step isEqualToString:self.syncProcessStepToLog]) {
                self.syncProcessStepToLog = step;
                NSString *log = [NSString stringWithFormat:@"ContactSync current progress - %@",self.syncProcessStepToLog];
                IGLog(log);
            }
            
            self.processPercent = [[SyncStatus shared].progress floatValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadProgressBar:self.processPercent];
            });
        };
        
        [SyncSettings shared].token = APPDELEGATE.session.authToken;
        [SyncSettings shared].url = CONTACT_SYNC_SERVER_URL;
        [SyncSettings shared].debug = YES;
        [SyncSettings shared].callback = ^void(id data) {
            SyncStatus *status = [SyncStatus shared];
            switch (status.status) {
                case SYNC_RESULT_SUCCESS: {
                    ContactSyncResult *currentSyncResult = [[ContactSyncResult alloc] init];
                    currentSyncResult.clientUpdateCount = (int)status.updatedContactsReceived.count;
                    currentSyncResult.serverUpdateCount = (int)status.updatedContactsSent.count;
                    currentSyncResult.clientNewCount = (int)status.createdContactsReceived.count;
                    currentSyncResult.serverNewCount = (int)status.createdContactsSent.count;
                    currentSyncResult.clientDeleteCount = (int)status.deletedContactsOnDevice.count;
                    currentSyncResult.serverDeleteCount = (int)status.deletedContactsOnServer.count;
                    currentSyncResult.totalContactOnClient = [status.totalContactOnClient intValue];
                    currentSyncResult.totalContactOnServer = [status.totalContactOnServer intValue];
                    currentSyncResult.syncType = APPDELEGATE.session.syncType;
                    [currentSyncResult saveData];
                    APPDELEGATE.session.syncResult = currentSyncResult;
                    [SyncUtil writeLastContactSyncResult:currentSyncResult];
                }
                    break;
                case SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK:
                    [self showErrorAlertWithMessage:NSLocalizedString(@"AddressBookGrantError", @"")];
                    IGLog(@"ContactSync sync failed with AddressBookGrantError");
                    break;
                    
                case SYNC_RESULT_ERROR_REMOTE_SERVER: {
                    _errMessage = @"ContactSyncApiError";
                    if (data != nil) {
                        NSArray *mainArray = (NSArray*) data;
                        NSDictionary *mainDict = mainArray[0];
                        int errorCode = [[mainDict objectForKey:@"code"] intValue];
                        NSString *errorMessage = NSLocalizedString(@"ContactSync5000LimitError", @"");
                        
                        if (errorCode == 3000) {
                            [self showErrorAlertWithMessage:errorMessage];
                            break;
                        }
                    }
                }
                    
                case SYNC_RESULT_ERROR_NETWORK:
                    _errMessage = @"ContactSyncGeneralError";
                    
                default:
                    if (_triedAgain == NO) {
                        APPDELEGATE.session.authToken = nil;
                        _triedAgain = YES;
                        [self triggerNewToken];
                    } else {
                        [self showErrorAlertWithMessage:NSLocalizedString(_errMessage, @"")];
//                        [processView dismissWithFailureMessage];
//                        [self makeButtonsActive];
                        [self changeViews:progressView nextView:syncView];
                        
                        NSString *log = [NSString stringWithFormat:@"ContactSync sync failed with %@", _errMessage];
                        IGLog(log);
                    }
                    
                    return;
            }
            [self manualSyncFinalized];
        };
    }
    return self;
}

- (void) backupClicked {
    if ([ContactSyncSDK isRunning]) {
        IGLog(@"ContactSync backup request is rejected because it is running");
        return;
    }
    
    IGLog(@"ContactSync backup started");
    APPDELEGATE.session.syncType = ContactSyncTypeBackup;
//    [self showProcessView];
//    [self makeButtonsPassive];
    
    [self changeViews:syncView nextView:progressView];
    progressView.progressLabel.text = NSLocalizedString(@"ContactSyncProgressOnServerText", @"");
    syncResultView.label.text = [NSLocalizedString(@"ContactSyncBackupResultTitle", @"") uppercaseString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ContactSyncSDK hasContactForBackup:^(SYNCResultType resultType) {
            switch (resultType) {
                case SYNC_RESULT_SUCCESS: {
                    _triedAgain = NO;
                    [ContactSyncSDK doSync:SYNCBackup];
                    syncMode = SYNCBackup;
                }
                    break;
                    
                case SYNC_RESULT_FAIL: {
                    [self showErrorAlertWithMessage:NSLocalizedString(@"ContactThereIsNoContact", @"")];
//                    [processView dismissWithFailureMessage];
//                    [self makeButtonsActive];
                }
                    break;
                    
                case SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK: {
                    [self showErrorAlertWithMessage:NSLocalizedString(@"AddressBookGrantError", @"")];
//                    [processView dismissWithFailureMessage];
//                    [self makeButtonsActive];
                }
                    break;
                    
                default:
                    break;
            }
        }];
    });
    
    
}

- (void) restoreClicked {
    if ([ContactSyncSDK isRunning]) {
        IGLog(@"ContactSync restore request is rejected because it is running");
        return;
    }
    
    IGLog(@"ContactSync restore started");
    APPDELEGATE.session.syncType = ContactSyncTypeRestore;
    _triedAgain = NO;
    [ContactSyncSDK doSync:SYNCRestore];
    [self changeViews:syncView nextView:progressView];
    progressView.progressLabel.text = NSLocalizedString(@"ContactSyncProgressOnClientText", @"");
    syncResultView.label.text = [NSLocalizedString(@"ContactSyncRestoreResultTitle", @"") uppercaseString];
    syncMode = SYNCRestore;
    
//    [self showProcessView];
//    [self makeButtonsPassive];
}

- (void) manualSyncFinalized {
    IGLog(@"ContactSync sync successfully finished");
//    [self hideProcessView];
//    [self makeButtonsActive];
    
    [self refreshSyncResult:APPDELEGATE.session.syncType];
    [self changeViews:progressView nextView:syncResultView];
    
    [SyncUtil updateLastContactSyncDate];
    NSString *lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), NSLocalizedString(@"NoneTitle", @"")];
    if([SyncUtil readLastContactSyncDate] != nil) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
        lastSyncTitle = [NSString stringWithFormat:NSLocalizedString(@"ContactLastSyncDateTitle", @""), [dateFormat stringFromDate:[SyncUtil readLastContactSyncDate]]];
    }
    lastSyncDateLabel.text = lastSyncTitle;
    lastSyncDateLabel.hidden = NO;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    if([ContactSyncSDK isRunning]) {
//        [self showProcessView];
//        [self makeButtonsPassive];
//    } else {
//        [self makeButtonsActive];
//    }
}

- (void)showProcessView {
    BaseViewController *base = APPDELEGATE.base;
    
    NSString *processMessage, *successMessage, *failMessage;
    if (APPDELEGATE.session.syncType == ContactSyncTypeBackup) {
        processMessage = NSLocalizedString(@"ContactSyncBackupProgresssMessage", "");
        successMessage = NSLocalizedString(@"ContactSyncBackupSuccessMessage", "");
        failMessage = NSLocalizedString(@"ContactSyncBackupFailMessage", "");
    } else {
        processMessage = NSLocalizedString(@"ContactSyncRestoreProgresssMessage", "");
        successMessage = NSLocalizedString(@"ContactSyncRestoreSuccessMessage", "");
        failMessage = NSLocalizedString(@"ContactSyncRestoreFailMessage", "");
    }
    
    processView = [[ProcessFooterView alloc] initWithFrame:CGRectMake(0, base.view.frame.size.height - 60, base.view.frame.size.width, 60)
                                        withProcessMessage:processMessage
                                          withFinalMessage:successMessage
                                           withFailMessage:failMessage];
    processView.delegate = self;
    
    [base.view addSubview:processView];
    [processView startLoading];
}

- (void)hideProcessView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [processView dismissWithSuccessMessage];
        processView = nil;
    });
}

- (void) processFooterShouldDismissWithButtonKey:(NSString *) postButtonKeyVal {
//    [self hideProcessView];
}

#pragma mark - RequestTokenDao

- (void) triggerNewToken {
    IGLog(@"ContactSync at triggerNewToken");
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(networkStatus == kReachableViaWiFi || networkStatus == kReachableViaWWAN) {
        IGLog(@"ContactSync at triggerNewToken kReachableViaWiFi || kReachableViaWWAN");
        if([CacheUtil readRememberMeToken] != nil) {
            IGLog(@"ContactSync at triggerNewToken readRememberMeToken not null");
            _tokenDao = [[RequestTokenDao alloc] init];
            _tokenDao.delegate = self;
            _tokenDao.successMethod = @selector(tokenRevisitedSuccessCallback);
            _tokenDao.failMethod = @selector(tokenRevisitedFailCallback:);
            [_tokenDao requestTokenByRememberMe];
        } else {
            if(networkStatus == kReachableViaWiFi) {
                IGLog(@"ContactSync at triggerNewToken readRememberMeToken null - kReachableViaWiFi");
                //            [self shouldReturnFailWithMessage:LOGIN_REQ_ERROR_MESSAGE];
                //                NSLog(@"Login Required Triggered within triggerNewToken instead of fail method: %@", NSStringFromSelector(failMethod));
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_REQ_NOTIFICATION object:nil userInfo:nil];
            } else {
                IGLog(@"ContactSync at triggerNewToken readRememberMeToken null - not kReachableViaWiFi -  calling radiusDao");
                _radiusDao = [[RadiusDao alloc] init];
                _radiusDao.delegate = self;
                _radiusDao.successMethod = @selector(tokenRevisitedSuccessCallback);
                _radiusDao.failMethod = @selector(tokenRevisitedFailCallback:);
                [_radiusDao requestRadiusLogin];
            }
        }
    } else {
        [self showErrorAlertWithMessage:NSLocalizedString(@"NoConnErrorMessage", @"")];
//        [self hideProcessView];
//        [self makeButtonsActive];
    }
}

- (void) tokenRevisitedSuccessCallback {
    IGLog(@"ContactSync token request successed");
    [SyncSettings shared].token = APPDELEGATE.session.authToken;
    [ContactSyncSDK doSync:syncMode];
}

- (void) tokenRevisitedFailCallback:(NSString *) errorMessage {
    IGLog(@"ContactSync token request failed");
    [self showErrorAlertWithMessage:NSLocalizedString(_errMessage, @"")];
//    [self hideProcessView];
//    [self makeButtonsActive];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([ContactSyncSDK isRunning]) {
        IGLog(@"ContactSync viewWillAppear isRunning : YES");
        [self.topContainer addSubview:progressView];
        [self.footerContainer setHidden:YES];
        if (APPDELEGATE.session.syncType == ContactSyncTypeRestore) {
            progressView.progressLabel.text = NSLocalizedString(@"ContactSyncProgressOnClientText", @"");
            syncResultView.label.text = [NSLocalizedString(@"ContactSyncRestoreResultTitle", @"") uppercaseString];
        } else {
            progressView.progressLabel.text = NSLocalizedString(@"ContactSyncProgressOnServerText", @"");
            syncResultView.label.text = [NSLocalizedString(@"ContactSyncBackupResultTitle", @"") uppercaseString];
        }
        [self reloadProgressBar:self.processPercent];
        return;
    }
    [self.topContainer addSubview:syncView];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.view.superview == nil) {
            [UIView animateWithDuration:0.3 animations:^{
                processView.hidden = YES;
            }];
        }
    });
    
    /*
     if (autoSyncSwitch.isOn) {
     [CacheUtil writeCachedSettingSyncContacts:EnableOptionAuto];
     if (oldSyncOption == EnableOptionOff) {
     [SyncUtil startContactAutoSync];
     }
     } else {
     [CacheUtil writeCachedSettingSyncContacts:EnableOptionOff];
     [SyncUtil stopContactAutoSync];
     }
     */
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

//- (void)makeButtonsPassive {
//    backupButton.enabled = NO;
//    restoreButton.enabled = NO;
//    backupButton.alpha = 0.5f;
//    restoreButton.alpha = 0.5f;
//}
//
//- (void)makeButtonsActive {
//    backupButton.enabled = YES;
//    restoreButton.enabled = YES;
//    backupButton.alpha = 1.0f;
//    restoreButton.alpha = 1.0f;
//}



- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return [self.statusList count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    return [[self.statusList objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [self.statusColors objectAtIndex:(index % self.statusColors.count)];
}

- (void) drawFooter:(UIView *) view {
    
    float titleLabelWidth = (view.frame.size.width/3);
    
    CustomLabel *totalContactsLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 0, titleLabelWidth, 40) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:(IS_IPHONE_5 ? 14 : 18)] withColor:[Util UIColorForHexColor:@"363e4f"] withText:@"Total Contacts" withAlignment:NSTextAlignmentCenter];
    [view addSubview:totalContactsLabel];
    
    CustomLabel *cleanContactsLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((view.frame.size.width-titleLabelWidth)/2 , 0, titleLabelWidth, 40) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:(IS_IPHONE_5 ? 14 : 18)] withColor:[Util UIColorForHexColor:@"363e4f"] withText:@"Contacts after you clean" withAlignment:NSTextAlignmentCenter numberOfLines:2];
    cleanContactsLabel.adjustsFontSizeToFitWidth = YES;
    cleanContactsLabel.backgroundColor = [UIColor redColor];
    [view addSubview:cleanContactsLabel];
    
    CustomLabel *deleteLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((cleanContactsLabel.frame.origin.x + cleanContactsLabel.frame.size.width) + 20, 0, titleLabelWidth, 40) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:(IS_IPHONE_5 ? 14 : 18)] withColor:[Util UIColorForHexColor:@"363e4f"] withText:@"Delete" withAlignment:NSTextAlignmentLeft];
    [view addSubview:deleteLabel];
    
}

- (void) changeViews:(UIView *) currentView nextView:(UIView *) nextView {
    
    if ([nextView isKindOfClass:[ContactSyncProgressView class]]) {
        [self.footerContainer setHidden:YES];
    } else {
        [self.footerContainer setHidden:NO];
    }
    
    CGRect newFrame = nextView.frame;
    newFrame.origin = CGPointMake(self.view.frame.size.width + 50, nextView.frame.origin.y);
    [nextView setFrame:newFrame];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                             CGRect newFrame = currentView.frame;
                             newFrame.origin = CGPointMake(-self.view.frame.size.width, currentView.frame.origin.y);
                             [currentView setFrame:newFrame];
                         
                     } completion:^(BOOL finished) {
                         [currentView removeFromSuperview];
                     }];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.topContainer addSubview:nextView];
                         CGRect newFrame = nextView.frame;
                         newFrame.origin = CGPointMake(0, nextView.frame.origin.y);
                         [nextView setFrame:newFrame];
                         
                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (void) reloadProgressBar:(CGFloat) value {
    BOOL animate = YES;
    if (value == 0) {
        animate = NO;
    }
    
    [self.progressView.progressBar setProgress:value/100 animated:animate];
    
    int integerValue = (int) roundf(value);
    progressView.percentLabel.text = [NSString stringWithFormat:@"%% %d",integerValue];
}

- (void) refreshSyncResult:(ContactSyncType) syncType {
    
    int totalContact,updatedContact,deletedContact;
    ContactSyncResult *syncResult = APPDELEGATE.session.syncResult;
    
    if (syncType == ContactSyncTypeBackup) {
        totalContact = syncResult.totalContactOnServer;
        updatedContact = syncResult.serverUpdateCount;
        deletedContact = syncResult.serverDeleteCount;
        self.syncTargetLabel.text = NSLocalizedString(@"ContactResultBackupSectionTitle", @"");
    }
    else {
        totalContact = syncResult.totalContactOnClient;
        updatedContact = syncResult.clientUpdateCount;
        deletedContact = syncResult.clientDeleteCount;
        self.syncTargetLabel.text = NSLocalizedString(@"ContactResultRestoreSectionTitle", @"");
    }
    
    totalContactElement.countLabel.text = [NSString stringWithFormat:@"%d",totalContact];
    cleanContactElement.countLabel.text = [NSString stringWithFormat:@"%d",updatedContact];
    deleteContactElement.countLabel.text = [NSString stringWithFormat:@"%d",deletedContact];
    syncResultView.totalCountLabel.text = [NSString stringWithFormat:@"%d",updatedContact];
}

@end
