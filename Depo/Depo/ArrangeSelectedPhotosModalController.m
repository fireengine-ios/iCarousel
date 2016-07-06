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

@interface ArrangeSelectedPhotosModalController ()

@end

@implementation ArrangeSelectedPhotosModalController

@synthesize story;
@synthesize photosScroll;
@synthesize photoList;
@synthesize selectedFileList;

- (id) initWithStory:(Story *) rawStory {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"CreateStoryTitle", @"");
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.story = rawStory;
        
        photoList  = [[NSMutableArray alloc] init];
        selectedFileList = [[NSMutableArray alloc] init];
        
        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex)];
        [self.view addSubview:photosScroll];
        
        CustomLabel *infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, photosScroll.frame.size.width, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:13] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"VideofySequenceInfo", @"")];
        infoLabel.adjustsFontSizeToFitWidth = YES;
        [photosScroll addSubview:infoLabel];
        
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
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30) withImageName:@"icon_ustbar_close.png"];
    [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    CustomButton *nextButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30) withImageName:@"icon_ustbar_forward.png"];
    [nextButton addTarget:self action:@selector(triggerNext) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    self.navigationItem.rightBarButtonItem = nextItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) triggerNext {
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
