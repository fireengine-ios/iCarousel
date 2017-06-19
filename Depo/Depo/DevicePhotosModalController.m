//
//  DevicePhotosModalController.m
//  Depo
//
//  Created by Mahir Tarlan on 10/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DevicePhotosModalController.h"
#import "CustomLabel.h"
#import "Util.h"
#import "UploadRef.h"
#import "SyncUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "ALAssetRepresentation+MD5.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface DevicePhotosModalController () {
    ALAssetsLibrary *al;
    BOOL imagesLoaded;
    BOOL footerLoaded;
    float imageWidth;
    int imgCount;
    int videoCount;
}
@end

@implementation DevicePhotosModalController

@synthesize modalDelegate;
@synthesize assets;
@synthesize selectedAssets;
@synthesize collView;
@synthesize footerView;
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
        cancelItem.isAccessibilityElement = YES;
        cancelItem.accessibilityIdentifier = @"cancelButtonDevicePhotos";
        self.navigationItem.rightBarButtonItem = cancelItem;
        
        al = [[ALAssetsLibrary alloc] init];
        self.assets = [[NSMutableArray alloc] init];
        self.selectedAssets = [[NSMutableArray alloc] init];
        
        if(IS_IPAD) {
            imageWidth = (self.view.frame.size.width - 28)/6;
        } else {
            imageWidth = (self.view.frame.size.width - 10)/4;
        }
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100) collectionViewLayout:layout];
        collView.dataSource = self;
        collView.delegate = self;
        collView.backgroundColor = [UIColor whiteColor];
        [collView registerClass:[DevicePhotoCell class] forCellWithReuseIdentifier:@"DEVICE_PHOTO_CELL"];
        [collView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
        collView.isAccessibilityElement = YES;
        collView.accessibilityIdentifier = @"collViewDevicePhotos";
        [self.view addSubview:collView];
        
        [al enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    NSString *albumName = [group valueForProperty:ALAssetsGroupPropertyName];
                    if(asset && [albumName isEqualToString:self.album.albumName]) {
                        [assets addObject:asset];
                        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                            videoCount ++;
                        } else {
                            imgCount ++;
                        }
                    }
                }];
            } else {
                [self showImages];
            }
        } failureBlock:^(NSError *error) {
            if (error.code == ALAssetsLibraryAccessUserDeniedError || error.code == ALAssetsLibraryAccessGloballyDeniedError) {
                [self showErrorAlertWithMessage:NSLocalizedString(@"ALAssetsAccessError", @"")];
            }
        }];
        
        footerView = [[MultipleUploadFooterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 124, self.view.frame.size.width, 60)];
        footerView.delegate = self;
        footerView.isAccessibilityElement = YES;
        footerView.accessibilityIdentifier = @"footerViewDevicePhotos";
        [self.view addSubview:footerView];
        
    }
    return self;
}

- (void) showImages {
    [assets sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [obj1 valueForProperty:ALAssetPropertyDate];
        NSDate *date2 = [obj2 valueForProperty:ALAssetPropertyDate];
        return ([date1 compare:date2] == NSOrderedAscending ? NSOrderedDescending : NSOrderedAscending);
    }];
    
    imagesLoaded = YES;
    self.title = [NSString stringWithFormat:NSLocalizedString(@"AddPhotosTitle", @""), [selectedAssets count], [assets count]];
    [self.collView reloadData];
}

- (void) devicePhotoAssetDidBecomeSelected:(ALAsset *)selectedAsset {
    if(![selectedAssets containsObject:selectedAsset]) {
        [selectedAssets addObject:selectedAsset];
    }
    self.title = [NSString stringWithFormat:NSLocalizedString(@"AddPhotosTitle", @""), [selectedAssets count], [assets count]];
}

- (void) devicePhotoAssetDidBecomeDeselected:(ALAsset *)deselectedAsset {
    if([selectedAssets containsObject:deselectedAsset]) {
        [selectedAssets removeObject:deselectedAsset];
    }
    self.title = [NSString stringWithFormat:NSLocalizedString(@"AddPhotosTitle", @""), [selectedAssets count], [assets count]];
}

- (void) multipleUploadFooterDidTriggerUpload {
    if([selectedAssets count] > 0) {
        if([selectedAssets count] > 100) {
            [self showErrorAlertWithMessage:NSLocalizedString(@"UploadCountLimitError", @"")];
            return;
        }
        NSMutableArray *selectedAssetUrls = [[NSMutableArray alloc] init];
        for(ALAsset *row in selectedAssets) {
            NSString *mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass
            ((__bridge CFStringRef)[row.defaultRepresentation UTI], kUTTagClassMIMEType);
            
            MetaFileSummary *summary = [[MetaFileSummary alloc] init];
            summary.fileName = [row.defaultRepresentation filename];
            summary.bytes = [row.defaultRepresentation size];
            
            UploadRef *ref = [[UploadRef alloc] init];
            ref.fileName = row.defaultRepresentation.filename;
            ref.filePath = [row.defaultRepresentation.url absoluteString];
            ref.mimeType = mimeType;
            ref.referenceFolderName = self.album.albumName;
            ref.summary = summary;
            ref.localHash = [SyncUtil md5StringOfString:[row.defaultRepresentation.url absoluteString]];
            if ([[row valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                ref.contentType = ContentTypeVideo;
            } else {
                ref.contentType = ContentTypePhoto;
            }
            NSDictionary *metadataDict = [row.defaultRepresentation metadata];
            if(metadataDict) {
                NSDictionary *tiffDict = [metadataDict objectForKey:@"{TIFF}"];
                if(tiffDict) {
                    NSString *softwareVal = [tiffDict objectForKey:@"Software"];
                    if(softwareVal) {
                        if([SPECIAL_LOCAL_ALBUM_NAMES containsObject:softwareVal]) {
                            ref.referenceFolderName = softwareVal;
                        }
                    }
                }
            }
            [selectedAssetUrls addObject:ref];
        }
        [modalDelegate devicePhotosDidTriggerUploadForUrls:selectedAssetUrls];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) multipleUploadFooterDidTriggerSelectAll {
    for(ALAsset *row in self.assets) {
        if(![selectedAssets containsObject:row]) {
            [selectedAssets addObject:row];
        }
    }
    [collView reloadData];
    self.title = [NSString stringWithFormat:NSLocalizedString(@"AddPhotosTitle", @""), [selectedAssets count], [assets count]];
}

- (void) multipleUploadFooterDidTriggerDeselectAll {
    [selectedAssets removeAllObjects];
    [collView reloadData];
    self.title = [NSString stringWithFormat:NSLocalizedString(@"AddPhotosTitle", @""), [selectedAssets count], [assets count]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"PhotoListModalController viewDidLoad");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.assets count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (DevicePhotoCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DevicePhotoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"DEVICE_PHOTO_CELL" forIndexPath:indexPath];
    ALAsset *rowAsset = [self.assets objectAtIndex:indexPath.row];
    [cell loadAsset:rowAsset isSelectedFlag:[self.selectedAssets containsObject:rowAsset]];
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DevicePhotoCell *cell = (DevicePhotoCell *) [collectionView cellForItemAtIndexPath:indexPath];
    ALAsset *rowAsset = cell.asset;
    if([selectedAssets containsObject:rowAsset]) {
        [selectedAssets removeObject:rowAsset];
        [cell manuallyDeselect];
    } else {
        [selectedAssets addObject:rowAsset];
        [cell manuallySelect];
    }
    self.title = [NSString stringWithFormat:NSLocalizedString(@"AddPhotosTitle", @""), [selectedAssets count], [assets count]];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(imageWidth, imageWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 10, 2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width, 50);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)theCollectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)theIndexPath {
    UICollectionReusableView *collFooterView = [theCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:theIndexPath];
    if(imagesLoaded && !footerLoaded) {
        footerLoaded = YES;
        collFooterView.backgroundColor = [UIColor clearColor];
        NSString *contentStr = [NSString stringWithFormat:NSLocalizedString(@"PhotoListContentFooterTitle", @""), imgCount, videoCount];
        CustomLabel *contentLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 0, collView.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:18] withColor:[Util UIColorForHexColor:@"1b1b1b"] withText:contentStr];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        [collFooterView addSubview:contentLabel];
    }
    if(kind == UICollectionElementKindSectionFooter) {
        return collFooterView;
    }
    collFooterView.frame = CGRectZero;
    return collFooterView;
}

@end
