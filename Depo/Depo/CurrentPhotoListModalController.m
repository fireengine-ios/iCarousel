//
//  CurrentPhotoListModalController.m
//  Depo
//
//  Created by Mahir Tarlan on 29/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "CurrentPhotoListModalController.h"
#import "AppDelegate.h"

@interface CurrentPhotoListModalController ()

@end

@implementation CurrentPhotoListModalController

@synthesize delegate;
@synthesize photosScroll;
@synthesize photoList;
@synthesize selectedFileList;
@synthesize footerView;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"PhotosTitle", @"");
        
        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(photoListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(photoListFailCallback:);

        photoList = [[NSMutableArray alloc] init];
        selectedFileList = [[NSMutableArray alloc] init];

        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.rightBarButtonItem = cancelItem;

        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 60)];
        photosScroll.delegate = self;
        photosScroll.tag = 111;
        [self.view addSubview:photosScroll];

        listOffset = 0;

        [elasticSearchDao requestPhotosForPage:listOffset andSize:IS_IPAD ? 30 : 21 andSortType:APPDELEGATE.session.sortType];

        footerView = [[MultipleUploadFooterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60) selectAllEnabled:NO];
        footerView.delegate = self;
        [self.view addSubview:footerView];
    }
    return self;
}

- (void) triggerOk {
    [delegate photoModalListReturnedWithSelectedList:self.selectedFileList];
    [self dismissViewControllerAnimated:YES completion:nil];
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
        CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 15 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row withSelectibleStatus:YES];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20;
    if(contentSizeHeight <= photosScroll.frame.size.height) {
        contentSizeHeight = photosScroll.frame.size.height + 1;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
    [photoList addObjectsFromArray:files];
    if (photoList.count == 0) {
        if (noItemView == nil)
            noItemView = [[NoItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, photosScroll.frame.size.height) imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        [photosScroll addSubview:noItemView];
    }
    else if (noItemView != nil)
        [noItemView removeFromSuperview];

    isLoading = NO;
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) squareImageWasSelectedForView:(SquareImageView *) squareRef {
}

- (void) squareImageWasSelectedForFile:(MetaFile *)fileSelected {
}

- (void) squareImageWasMarkedForFile:(MetaFile *)fileSelected {
    if(fileSelected.uuid) {
        if(![selectedFileList containsObject:fileSelected.uuid]) {
            [selectedFileList addObject:fileSelected.uuid];
        }
    }
    if([selectedFileList count] > 0) {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *)fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]];
    } else {
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
}

- (void) squareImageUploadFinishedForFile:(NSString *) fileUuid {
}

- (void) squareImageWasLongPressedForFile:(MetaFile *)fileSelected {
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
}

- (void) squareImageUploadLoginError:(MetaFile *)fileSelected {
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.tag == 111) {
        if(!isLoading) {
            CGFloat currentOffset = photosScroll.contentOffset.y;
            CGFloat maximumOffset = photosScroll.contentSize.height - photosScroll.frame.size.height;
            
            if (currentOffset - maximumOffset >= 0.0) {
                isLoading = YES;
                [self dynamicallyLoadNextPage];
            }
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [elasticSearchDao requestPhotosForPage:listOffset andSize:IS_IPAD ? 30 : 21 andSortType:APPDELEGATE.session.sortType];
}

- (void) multipleUploadFooterDidTriggerUpload {
    [delegate photoModalListReturnedWithSelectedList:self.selectedFileList];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) multipleUploadFooterDidTriggerSelectAll {
}

- (void) multipleUploadFooterDidTriggerDeselectAll {
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
