//
//  SelectiblePhotoListModalController.m
//  Depo
//
//  Created by Mahir Tarlan on 05/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SelectiblePhotoListModalController.h"
#import "AppDelegate.h"
#import "CustomLabel.h"
#import "Util.h"
#import "ArrangeSelectedPhotosModalController.h"

@interface SelectiblePhotoListModalController ()

@end

@implementation SelectiblePhotoListModalController

@synthesize story;
@synthesize photosScroll;
@synthesize photoList;
@synthesize selectedFileList;
@synthesize listOffset;
@synthesize isLoading;

- (id) initWithStory:(Story *) rawStory {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"CreateStoryTitle", @"");
        self.view.backgroundColor = [UIColor whiteColor];

        self.story = rawStory;

        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(photoListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(photoListFailCallback:);

        listOffset = 0;
        photoList  = [[NSMutableArray alloc] init];
        selectedFileList = [[NSMutableArray alloc] init];
        
        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex)];
        photosScroll.delegate = self;
        [self.view addSubview:photosScroll];

        CustomLabel *infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, photosScroll.frame.size.width, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:13] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"VideofySelectibleInfo", @"")];
        [photosScroll addSubview:infoLabel];

        [elasticSearchDao requestPhotosForPage:listOffset andSize:IS_IPAD ? 30 : 21 andSortType:APPDELEGATE.session.sortType];
        [self showLoading];
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

- (void) photoListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    int counter = (int)[photoList count];
    
    int imagePerLine = 3;
    
    float imageWidth = 100;
    float interImageMargin = 5;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;
    
    for(MetaFile *row in files) {
        CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 35 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row withSelectibleStatus:YES];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 40;
    if(contentSizeHeight <= photosScroll.frame.size.height) {
        contentSizeHeight = photosScroll.frame.size.height + 1;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
    [photoList addObjectsFromArray:files];
    isLoading = NO;
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) squareImageWasMarkedForFile:(MetaFile *)fileSelected {
    if([selectedFileList count] >= 50) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"VideofySelectibleInfo", @"")];
    } else {
        if(fileSelected.uuid) {
            MetaFile *filePresent = [self selectedFileListContainingFile:fileSelected];
            if(!filePresent) {
                [selectedFileList addObject:fileSelected];
            }
        }
    }
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *)fileSelected {
    MetaFile *filePresent = [self selectedFileListContainingFile:fileSelected];
    if(filePresent) {
        [selectedFileList removeObject:fileSelected];
    }
}

- (MetaFile *) selectedFileListContainingFile:(MetaFile *) fileToCheck {
    for(MetaFile *row in selectedFileList) {
        if([fileToCheck.uuid isEqualToString:row.uuid]) {
            return row;
        }
    }
    return nil;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!isLoading) {
        CGFloat currentOffset = photosScroll.contentOffset.y;
        CGFloat maximumOffset = photosScroll.contentSize.height - photosScroll.frame.size.height;
        
        if (currentOffset - maximumOffset >= 0.0) {
            isLoading = YES;
            listOffset ++;
            [elasticSearchDao requestPhotosForPage:listOffset andSize:IS_IPAD ? 30 : 21 andSortType:APPDELEGATE.session.sortType];
        }
    }
}

- (void) triggerNext {
    NSLog(@"Next clicked");
    self.story.fileList = selectedFileList;
    ArrangeSelectedPhotosModalController *arrangeController = [[ArrangeSelectedPhotosModalController alloc] initWithStory:self.story];
    [self.navigationController pushViewController:arrangeController animated:YES];
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

- (void) cancelRequests {
    [elasticSearchDao cancelRequest];
    elasticSearchDao = nil;
}

@end
