//
//  VideofyPreviewController.m
//  Depo
//
//  Created by Mahir Tarlan on 26/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VideofyPreviewController.h"
#import "Util.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

@interface VideofyPreviewController ()

@end

@implementation VideofyPreviewController

@synthesize story;
@synthesize avPlayer;
@synthesize createDao;
@synthesize bigPlayButton;

- (id) initWithStory:(Story *)_story {
    if(self = [super init]) {
        self.story = _story;
        self.view.backgroundColor = [UIColor blackColor];
        self.title = self.story.title;
        
        self.view.autoresizesSubviews = YES;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        createDao = [[VideofyCreateDao alloc] init];
        createDao.delegate = self;
        createDao.successMethod = @selector(videofySuccessCallback);
        createDao.failMethod = @selector(videofyFailCallback:);

        [self startAsyncVideoDownload];
        [self showLoading];
    }
    return self;
}

- (void) startAsyncVideoDownload {
    NSMutableArray *uuidList = [[NSMutableArray alloc] init];
    for(MetaFile *file in story.fileList) {
        [uuidList addObject:file.uuid];
    }
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:uuidList forKey:@"imageUUIDs"];
    [info setObject:story.title forKey:@"name"];
    if(story.musicFileUuid != nil) {
        [info setObject:story.musicFileUuid forKey:@"audioUUID"];
    } else if(story.musicFileId != nil) {
        [info setObject:story.musicFileId forKey:@"audioId"];
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:0 error:nil];
    NSString *urlString = VIDEOFY_PREVIEW_URL;
    NSString *encodedURLString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *finalUrl = [NSURL URLWithString:encodedURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finalUrl];
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:120];
    [request addValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    
//   TODO: REWRITE REQUEST
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"VIDEOFY_PREVIEW_FILENAME.mp4"];
//    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Successfully downloaded file to %@", path);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self hideLoading];
//            [self loadVideoForPath:path];
//        });
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self showErrorAlertWithMessage:NSLocalizedString(@"VideofyPreviewDownloadError", @"")];
//            [self hideLoading];
//        });
//    }];
//    
//    [operation start];
}

- (void) loadVideoForPath:(NSString *) path {
    [self hideLoading];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReady) name:VIDEO_READY_TO_PLAY_NOTIFICATION object:nil];

    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    avPlayer = [[CustomAVPlayer alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.topIndex) withVideoLink:fileUrl];
    avPlayer.delegate = self;
    [self.view addSubview:avPlayer];
    avPlayer.autoresizesSubviews = YES;
    avPlayer.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

    [avPlayer initializePlayer];
}

- (void) videoReady {
    if(!bigPlayButton) {
        self.bigPlayButton = [[CustomButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-68)/2, (self.view.frame.size.height-68)/2, 68, 68) withImageName:@"button_play.png"];
        [bigPlayButton addTarget:self action:@selector(bigPlayClicked) forControlEvents:UIControlEventTouchUpInside];
        bigPlayButton.isAccessibilityElement = YES;
        bigPlayButton.accessibilityIdentifier = @"bigPlayButtonVideofy";
        [self.view addSubview:bigPlayButton];
    }
}

- (void) bigPlayClicked {
    self.bigPlayButton.hidden = YES;
    [avPlayer manualPlay];
}

- (void) previewFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
    [self hideLoading];
}

- (void) videofySuccessCallback {
    if(avPlayer) {
        [avPlayer willDisappear];
    }
    [self hideLoading];
    VideofyPreparationInfoView *finalView = [[VideofyPreparationInfoView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.bounds.size.width, APPDELEGATE.window.bounds.size.height)];
    finalView.delegate = self;
    [APPDELEGATE.window addSubview:finalView];
}

- (void) videofyFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
    
    if(IS_BELOW_7) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[Util UIColorForHexColor:@"191e24"]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], UITextAttributeTextColor, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"TurkcellSaturaBol" size:18], UITextAttributeFont,nil]];
        
    } else {
        self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"191e24"];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [APPDELEGATE.session pauseAudioItem];
    
    if(avPlayer) {
        if(avPlayer.currentAsset) {
            [avPlayer.player play];
        } else {
            [avPlayer initializePlayer];
        }
    }
    
    CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"white_left_arrow.png"];
    [customBackButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
    backButton.isAccessibilityElement = YES;
    backButton.accessibilityIdentifier = @"backButtonVideofy";
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if(avPlayer) {
        [avPlayer willDisappear];
    }
    
    if(IS_BELOW_7) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[Util UIColorForHexColor:@"3fb0e8"]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], UITextAttributeTextColor, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"TurkcellSaturaBol" size:18], UITextAttributeFont,nil]];
        
    } else {
        self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"3fb0e8"];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
        
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
    }
}

- (void) customPlayerDidScrollInitialScreen {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.nav setNavigationBarHidden:NO animated:YES];
}

- (void) customPlayerDidScrollFullScreen {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.nav setNavigationBarHidden:YES animated:YES];
}

- (void) customPlayerDidStartPlay {
    if(self.bigPlayButton) {
        self.bigPlayButton.hidden = YES;
    }
}

- (void) customPlayerDidPause {
    if(self.bigPlayButton) {
        self.bigPlayButton.hidden = NO;
    }
}

- (void) triggerDismiss {
    if(avPlayer) {
        [avPlayer willDismiss];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"ViewPreviewController viewDidLoad");

    CustomButton *nextButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"Save", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [nextButton addTarget:self action:@selector(triggerSave) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    nextItem.isAccessibilityElement = YES;
    nextItem.accessibilityIdentifier = @"nextItemVideofy";
    self.navigationItem.rightBarButtonItem = nextItem;
}

- (void) triggerSave {
    [createDao requestVideofyCreateForStory:self.story];
    [self showLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (BOOL)shouldAutorotate {
//    if (self.avPlayer.player.rate > 0 && !self.avPlayer.player.error) {
//        return YES;
//    } else {
//        return NO;
//    }
//}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void) videofyPreparationViewShouldDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) cancelRequests {
    [createDao cancelRequest];
    createDao = nil;
}

@end
