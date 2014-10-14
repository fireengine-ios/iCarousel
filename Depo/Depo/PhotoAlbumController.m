//
//  PhotoAlbumController.m
//  Depo
//
//  Created by Mahir on 10/10/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoAlbumController.h"
#import "UIImageView+AFNetworking.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "MetaFile.h"
#import "ImagePreviewController.h"
#import "VideoPreviewController.h"

@interface PhotoAlbumController ()

@end

@implementation PhotoAlbumController

@synthesize album;
@synthesize photosScroll;
@synthesize photoList;

- (id)initWithAlbum:(PhotoAlbum *) _album {
    self = [super init];
    if (self) {
        self.album = _album;
        self.view.backgroundColor = [UIColor whiteColor];

        detailDao = [[AlbumDetailDao alloc] init];
        detailDao.delegate = self;
        detailDao.successMethod = @selector(albumDetailSuccessCallback:);
        detailDao.failMethod = @selector(albumDetailFailCallback:);
        
        photoList = [[NSMutableArray alloc] init];
        
        if(self.album.cover.url) {
            UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
            [bgImgView setImageWithURL:[NSURL URLWithString:self.album.cover.url]];
            [self.view addSubview:bgImgView];
            
            UIImageView *maskImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
            maskImgView.image = [UIImage imageNamed:@"album_mask.png"];
            [self.view addSubview:maskImgView];
        } else {
            emptyBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
            emptyBgImgView.image = [UIImage imageNamed:@"empty_album_header_bg.png"];
            [self.view addSubview:emptyBgImgView];
        }

        CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 30, 20, 34) withImageName:@"white_left_arrow.png"];
        [customBackButton addTarget:self action:@selector(triggerBack) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:customBackButton];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(40, 35, self.view.frame.size.width - 80, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:20] withColor:[UIColor whiteColor] withText:self.album.label];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:titleLabel];

        CustomButton *moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 30, 45, 20, 5) withImageName:@"dots_icon.png"];
        [moreButton addTarget:self action:@selector(triggerMore) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:moreButton];

        NSString *subTitleVal = @"";
        if(self.album.imageCount > 0 && self.album.videoCount > 0) {
            subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitle", @""), self.album.imageCount, self.album.videoCount];
        } else if(self.album.imageCount > 0) {
            subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitlePhotosOnly", @""), self.album.imageCount];
        } else if(self.album.videoCount > 0) {
            subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitleVideosOnly", @""), self.album.videoCount];
        }
        CustomLabel *subTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 124, self.view.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[UIColor whiteColor] withText:subTitleVal];
        [self.view addSubview:subTitleLabel];
        
        photosScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 160, self.view.frame.size.width, self.view.frame.size.height - 160)];
        [self.view addSubview:photosScroll];
        
        listOffset = 0;
        [detailDao requestDetailOfAlbum:self.album.albumId forStart:0 andSize:20];

    }
    return self;
}

- (void) albumDetailSuccessCallback:(NSArray *) contentList {
    int counter = [photoList count];
    for(MetaFile *row in contentList) {
        CGRect imgRect = CGRectMake(5 + (counter%3 * 105), 5 + ((int)floor(counter/3)*105), 100, 100);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, ((int)ceil(counter/3)+1)*105 + 20);
    [photoList addObjectsFromArray:contentList];
    isLoading = NO;
}

- (void) albumDetailFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) squareImageWasSelectedForFile:(MetaFile *)fileSelected {
    if(fileSelected.contentType == ContentTypePhoto) {
        ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFile:fileSelected];
        detail.nav = self.nav;
        [self.nav pushViewController:detail animated:NO];
    } else if(fileSelected.contentType == ContentTypeVideo) {
        VideoPreviewController *detail = [[VideoPreviewController alloc] initWithFile:fileSelected];
        detail.nav = self.nav;
        [self.nav pushViewController:detail animated:NO];
    }
}

- (void) triggerBack {
    [self.nav popViewControllerAnimated:YES];
}

- (void) triggerMore {
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nav setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.nav setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
