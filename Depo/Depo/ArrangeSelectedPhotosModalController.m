//
//  ArrangeSelectedPhotosModalController.m
//  Depo
//
//  Created by Mahir Tarlan on 06/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "ArrangeSelectedPhotosModalController.h"
#import "Util.h"
#import "SquareSequencedPictureView.h"
#import "MetaFile.h"
#import "VideofyMusicListController.h"
#import "VideofyPreparationInfoView.h"
#import "AppDelegate.h"
#import "VideofyPreviewController.h"

@interface ArrangeSelectedPhotosModalController () {
    SquareSequencedPictureView *focusView;
    BOOL shouldAllowPan;
    UIPanGestureRecognizer *panGesture;
    UITapGestureRecognizer *tapGesture;
    UILongPressGestureRecognizer *longGesture;
}
@end

@implementation ArrangeSelectedPhotosModalController

@synthesize story;
@synthesize photosScroll;
@synthesize photoList;
@synthesize selectedFileList;
@synthesize footerView;
@synthesize createDao;

- (id) initWithStory:(Story *) rawStory {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"CreateStoryTitle", @"");
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.story = rawStory;
        
        createDao = [[VideofyCreateDao alloc] init];
        createDao.delegate = self;
        createDao.successMethod = @selector(videofySuccessCallback);
        createDao.failMethod = @selector(videofyFailCallback:);
        
        photoList  = [[NSMutableArray alloc] init];
        selectedFileList = [[NSMutableArray alloc] init];
        
        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 60)];
        [self.view addSubview:photosScroll];
        
        footerView = [[VideofyFooterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.bottomIndex - 60, self.view.frame.size.width, 60)];
        footerView.delegate = self;
        [self.view addSubview:footerView];
        
        CustomLabel *infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, photosScroll.frame.size.width, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:13] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"VideofySequenceInfo", @"")];
        infoLabel.adjustsFontSizeToFitWidth = YES;
        [photosScroll addSubview:infoLabel];
        
        [self loadScrollView];
        
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panGesture.enabled = YES;
        panGesture.delegate = self;
        [photosScroll addGestureRecognizer:panGesture];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.delegate = self;
        [photosScroll addGestureRecognizer:tapGesture];
        [tapGesture requireGestureRecognizerToFail:panGesture];
        
        longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longGesture.delegate = self;
        [photosScroll addGestureRecognizer:longGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicHandler:) name:VIDEOFY_DEPO_MUSIC_SELECTED_NOTIFICATION object:nil];
        
    }
    return self;
}

- (void) musicHandler:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *audioId = [userInfo objectForKey:@"audio_file_selected"];
    if(audioId != nil) {
        self.story.musicFileId = [NSString stringWithFormat:@"%ld", audioId.longValue];
    } else {
        NSString *audioUuid = [userInfo objectForKey:@"depo_file_selected"];
        if(audioUuid != nil) {
            self.story.musicFileUuid = audioUuid;
        }
    }
}

- (void) loadScrollView {
    int counter = 0;
    
    int imagePerLine = 3;
    
    float imageWidth = 100;
    float interImageMargin = 5;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;
    
    for(MetaFile *row in self.story.fileList) {
        CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 35 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
        SquareSequencedPictureView *imgView = [[SquareSequencedPictureView alloc] initWithFrame:imgRect withFile:row withSequence:(counter+1)];
        [photosScroll addSubview:imgView];
        counter ++;
    }
    float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 40;
    if(contentSizeHeight <= photosScroll.frame.size.height) {
        contentSizeHeight = photosScroll.frame.size.height + 1;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ! shouldAllowPan) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if(UIGestureRecognizerStateBegan == recognizer.state) {
        shouldAllowPan = YES;
    }
}

- (void) handleTap:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer locationInView:photosScroll];
    
    for(UIView *subview in [photosScroll subviews]) {
        if([subview isKindOfClass:[SquareSequencedPictureView class]]) {
            if(CGRectContainsPoint(subview.frame, translation)) {
                SquareSequencedPictureView *castedView = (SquareSequencedPictureView *) subview;
                [castedView toggleMarked];
                if(castedView.isMarked) {
                    if(![selectedFileList containsObject:castedView.file.uuid]) {
                        [selectedFileList addObject:castedView.file.uuid];
                    }
                } else {
                    if([selectedFileList containsObject:castedView.file.uuid]) {
                        [selectedFileList removeObject:castedView.file.uuid];
                    }
                }
                break;
            }
        }
    }
}

- (void) handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer locationInView:photosScroll];
    
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        photosScroll.scrollEnabled = NO;
    }

    if(!focusView) {
        for(UIView *subview in [photosScroll subviews]) {
            if([subview isKindOfClass:[SquareSequencedPictureView class]]) {
                if(CGRectContainsPoint(subview.frame, translation)) {
                    focusView = (SquareSequencedPictureView *) subview;
                    break;
                }
            }
        }
    }
    
    if(focusView) {
        [photosScroll bringSubviewToFront:focusView];
        focusView.center = CGPointMake(translation.x, translation.y);
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        photosScroll.scrollEnabled = YES;
        
        int oldSeq = focusView.sequence;
        int newSeq = [self calculateSeqByPoint:focusView.center withInitialSeq:focusView.sequence];
        if(oldSeq != newSeq) {
            BOOL directionForward = newSeq > oldSeq;
            for(UIView *subview in [photosScroll subviews]) {
                if([subview isKindOfClass:[SquareSequencedPictureView class]]) {
                    SquareSequencedPictureView *castedView = (SquareSequencedPictureView *) subview;
                    if(castedView.sequence != oldSeq) {
                        if(castedView.sequence > oldSeq && castedView.sequence <= newSeq && directionForward) {
                            int newSeqForCastedView = castedView.sequence - 1;
                            castedView.frame = [self calculateReqBySeq:newSeqForCastedView];
                            [castedView updateSequence:newSeqForCastedView];
                        } else if(castedView.sequence < oldSeq && castedView.sequence >= newSeq && !directionForward) {
                            int newSeqForCastedView = castedView.sequence + 1;
                            castedView.frame = [self calculateReqBySeq:newSeqForCastedView];
                            [castedView updateSequence:newSeqForCastedView];
                        }
                    }
                }
            }
        }
        focusView.frame = [self calculateReqBySeq:newSeq];
        [focusView updateSequence:newSeq];
        focusView = nil;
        shouldAllowPan = NO;
    }
}

- (int) calculateSeqByPoint:(CGPoint) newPoint withInitialSeq:(int) initialSeq {
    int counter = 0;
    
    int imagePerLine = 3;
    
    float imageWidth = 100;
    float interImageMargin = 5;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;
    
    for(int i=0; i<[self.story.fileList count]; i++) {
        CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 35 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
        if(CGRectContainsPoint(imgRect, newPoint)) {
            return counter + 1;
        }
        counter ++;
    }
    return initialSeq;
}

- (CGRect) calculateReqBySeq:(int) newSeq {
    int pos = newSeq - 1;
    int imagePerLine = 3;
    
    float imageWidth = 100;
    float interImageMargin = 5;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;
    
    return CGRectMake(interImageMargin + (pos%imagePerLine * imageTotalWidth), 35 + ((int)floor(pos/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30) withImageName:@"icon_ustbar_close.png"];
    [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    CustomButton *nextButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 80, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCreate", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [nextButton addTarget:self action:@selector(triggerNext) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    self.navigationItem.rightBarButtonItem = nextItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) triggerNext {
    if([self.story.fileList count] == 0) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"VideofyFileListEmpty", @"")];
    } else if(self.story.musicFileId == nil && self.story.musicFileUuid == nil) {
        [self showInfoAlertWithMessage:NSLocalizedString(@"VideofyMusicEmpty", @"")];
    } else {
        NSMutableArray *finalArray = [[NSMutableArray alloc] init];
        for(UIView *subview in [photosScroll subviews]) {
            if([subview isKindOfClass:[SquareSequencedPictureView class]]) {
                SquareSequencedPictureView *castedView = (SquareSequencedPictureView *) subview;
                [finalArray addObject:castedView];
            }
        }

        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [finalArray sortedArrayUsingDescriptors:sortDescriptors];
        
        NSMutableArray *finalFileList = [[NSMutableArray alloc] init];
        for(SquareSequencedPictureView *row in sortedArray) {
            [finalFileList addObject:row.file];
        }
        
        self.story.fileList = finalFileList;
        
        VideofyPreviewController *previewController = [[VideofyPreviewController alloc] initWithStory:self.story];
        [self.navigationController pushViewController:previewController animated:YES];
    }
}

- (void) videofyFooterDeleteClicked {
    if([selectedFileList count] > 0) {
        NSMutableArray *newFileList = [[NSMutableArray alloc] init];
        for(MetaFile *file in self.story.fileList) {
            if(![selectedFileList containsObject:file.uuid]) {
                [newFileList addObject:file];
            }
        }
        self.story.fileList = newFileList;
        for(UIView *subview in [photosScroll subviews]) {
            if([subview isKindOfClass:[SquareSequencedPictureView class]]) {
                [subview removeFromSuperview];
            }
        }
        [self loadScrollView];
    }
}

- (void) videofyFooterMusicClicked {
    VideofyMusicListController *musicController = [[VideofyMusicListController alloc] initWithStory:self.story];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:musicController];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void) videofySuccessCallback {
    [self hideLoading];
    VideofyPreparationInfoView *finalView = [[VideofyPreparationInfoView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.bounds.size.width, APPDELEGATE.window.bounds.size.height)];
    [APPDELEGATE.window addSubview:finalView];
}

- (void) videofyFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
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

- (void) cancelRequests {
    [createDao cancelRequest];
    createDao = nil;
}

@end
