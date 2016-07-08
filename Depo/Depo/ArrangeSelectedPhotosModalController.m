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

@interface ArrangeSelectedPhotosModalController () {
    SquareSequencedPictureView *focusView;
}
@end

@implementation ArrangeSelectedPhotosModalController

@synthesize story;
@synthesize photosScroll;
@synthesize photoList;
@synthesize selectedFileList;
@synthesize footerView;

- (id) initWithStory:(Story *) rawStory {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"CreateStoryTitle", @"");
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.story = rawStory;
        
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
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panGesture.enabled = YES;
        [photosScroll addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.delegate = self;
        [photosScroll addGestureRecognizer:tapGesture];
        [tapGesture requireGestureRecognizerToFail:panGesture];
        
    }
    return self;
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
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    self.navigationItem.rightBarButtonItem = nextItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) triggerNext {
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
            [subview removeFromSuperview];
        }
        [self loadScrollView];
    }
}

- (void) videofyFooterMusicClicked {
    VideofyMusicListController *musicController = [[VideofyMusicListController alloc] init];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:musicController];
    [self presentViewController:modalNav animated:YES completion:nil];
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
