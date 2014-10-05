//
//  PhotoListModalController.m
//  Depo
//
//  Created by Mahir on 10/1/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoListModalController.h"
#import "CustomLabel.h"
#import "Util.h"

@interface PhotoListModalController ()

@end

@implementation PhotoListModalController

@synthesize assets;
@synthesize selectedAssets;
@synthesize mainScroll;
@synthesize footerView;
@synthesize al;
@synthesize album;

- (id)initWithAlbum:(MetaAlbum *) _album {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.album = _album;
        self.title = album.albumName;

        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.rightBarButtonItem = cancelItem;

        self.al = [[ALAssetsLibrary alloc] init];
        self.assets = [[NSMutableArray alloc] init];
        self.selectedAssets = [[NSMutableArray alloc] init];

        mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60)];
        [self.view addSubview:mainScroll];
        
        [al enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                     NSString *albumName = [group valueForProperty:ALAssetsGroupPropertyName];
                    NSLog(@"ALBUM NAME: %@", albumName);
                    if(asset && [albumName isEqualToString:self.album.albumName]) {
                        [assets addObject:asset];
                    }
                }];
            } else {
                [self showImages];
            }
         } failureBlock:^(NSError *error) {
         }];
        
        footerView = [[MultipleUploadFooterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
        footerView.delegate = self;
        [self.view addSubview:footerView];
        
    }
    return self;
}

- (void) showImages {
    int counter = 0;
    for(ALAsset *row in assets) {
        CGRect imgFrame = CGRectMake(4 + (counter%4 * 79), 4 + ((int)floor(counter/4) * 79), 75, 75);
        SelectibleAssetView *assetView = [[SelectibleAssetView alloc] initWithFrame:imgFrame withAsset:row];
        assetView.delegate = self;
        [mainScroll addSubview:assetView];
        counter++;
    }
    
    NSString *contentStr = [NSString stringWithFormat:NSLocalizedString(@"PhotoListContentFooterTitle", @""), [assets count], 0];
    
    CustomLabel *contentLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, (int)ceil(counter/4)*79 + 100, mainScroll.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:18] withColor:[Util UIColorForHexColor:@"1b1b1b"] withText:contentStr];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    [mainScroll addSubview:contentLabel];
    
    mainScroll.contentSize = CGSizeMake(mainScroll.frame.size.width, (int)ceil(counter/4)*79 + 140);
    self.title = [NSString stringWithFormat:NSLocalizedString(@"AddPhotosTitle", @""), [selectedAssets count], [assets count]];
}

- (void) selectibleAssetDidBecomeSelected:(ALAsset *)selectedAsset {
    if(![selectedAssets containsObject:selectedAsset]) {
        [selectedAssets addObject:selectedAsset];
    }
    self.title = [NSString stringWithFormat:NSLocalizedString(@"AddPhotosTitle", @""), [selectedAssets count], [assets count]];
}

- (void) selectibleAssetDidBecomeDeselected:(ALAsset *)deselectedAsset {
    if([selectedAssets containsObject:deselectedAsset]) {
        [selectedAssets removeObject:deselectedAsset];
    }
    self.title = [NSString stringWithFormat:NSLocalizedString(@"AddPhotosTitle", @""), [selectedAssets count], [assets count]];
}

- (void) multipleUploadFooterDidTriggerUpload {
    if([selectedAssets count] > 0) {
        ALAsset *firstAsset = [selectedAssets objectAtIndex:0];

        ALAssetRepresentation *representation = [firstAsset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(representation.size);

        NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
        NSData *sourceData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        
        uploadManager = [[UploadManager alloc] initWithAssetsLibrary:self.al];
        [uploadManager startUploadingData:sourceData atFolder:nil withFileName:representation.filename];
//        [uploadManager startUploadingData:sourceData atFolder:nil withFileName:firstAsset.defaultRepresentation.filename];
    }
}

- (void) multipleUploadFooterDidTriggerSelectAll {
}

- (void) multipleUploadFooterDidTriggerDeselectAll {
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
