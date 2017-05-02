//
//  PhotosHeaderSyncView.m
//  Depo
//
//  Created by Mahir Tarlan on 13/03/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "PhotosHeaderSyncView.h"
#import "AppConstants.h"
#import "Util.h"
#import "CustomLabel.h"
#import "UploadQueue.h"

@interface PhotosHeaderSyncView() {
    CustomLabel *infoLabel;
    CustomLabel *countLabel;
    CustomLabel *progressLabel;
    UIView *progress;
    UIView *progressBg;
    UIImageView *thumbView;
    NSString *assetUrlRef;
}
@end

@implementation PhotosHeaderSyncView

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"f9f9f8"];
        
        infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - 16)/2, 100, 16) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[Util UIColorForHexColor:@"8d8a85"] withText:NSLocalizedString(@"SyncInProgressHeaderTitle", @"") withAlignment:NSTextAlignmentLeft];
        infoLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:infoLabel];
        
        float maxProgressWidth = self.frame.size.width - infoLabel.frame.size.width - 130;
        
        progressBg = [[UIView alloc] initWithFrame:CGRectMake(infoLabel.frame.origin.x + infoLabel.frame.size.width + 5, (self.frame.size.height - 16)/2, maxProgressWidth, 16)];
        progressBg.layer.cornerRadius = 8;
        progressBg.backgroundColor = [Util UIColorForHexColor:@"058ba9"];
        [self addSubview:progressBg];
        
        progress = [[UIView alloc] initWithFrame:CGRectMake(infoLabel.frame.origin.x + infoLabel.frame.size.width + 5, (self.frame.size.height - 16)/2, 1, 16)];
        progress.layer.cornerRadius = 8;
        progress.backgroundColor = [Util UIColorForHexColor:@"00aadf"];
        [self addSubview:progress];
        
        progressLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(progressBg.frame.origin.x + progressBg.frame.size.width + 5, (self.frame.size.height - 16)/2, 40, 16) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[Util UIColorForHexColor:@"8d8a85"] withText:@"" withAlignment:NSTextAlignmentLeft];
        [self addSubview:progressLabel];
        
        thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 60, (self.frame.size.height - 40)/2, 40, 40)];
        thumbView.contentMode = UIViewContentModeScaleAspectFill;
        thumbView.clipsToBounds = YES;
        thumbView.backgroundColor = [UIColor grayColor];
        [self addSubview:thumbView];
    }
    return self;
}

- (void) loadAsset:(NSString *) assetUrlStr {
    assetUrlRef = assetUrlStr;
    NSURL *assetUrl = [NSURL URLWithString:assetUrlStr];
    ALAssetsLibrary *assetsLibraryForSingle = [[ALAssetsLibrary alloc] init];
    [assetsLibraryForSingle assetForURL:assetUrl resultBlock:^(ALAsset *myAsset) {
        if(myAsset) {
            thumbView.image = [UIImage imageWithCGImage:[myAsset aspectRatioThumbnail]];
        }
    } failureBlock:nil];
    [self checkProgressInfo];
}

- (void) loadLocalFileForCamUpload:(NSString *) localTempUrl {
    UIImage *thumbImageFromCam = [UIImage imageWithContentsOfFile:localTempUrl];
    thumbView.image = [Util imageWithImage:thumbImageFromCam scaledToFillSize:CGSizeMake(40, 40)];
}

- (void) uploadManagerDidSendData:(long)sentBytes inTotal:(long)totalBytes {
    int progressWidth = sentBytes*progressBg.frame.size.width/totalBytes;
    [self performSelectorOnMainThread:@selector(updateProgressByWidth:) withObject:[NSNumber numberWithInt:progressWidth] waitUntilDone:NO];
}

- (void) updateProgressByWidth:(NSNumber *) newWidth {
    progress.frame = CGRectMake(progress.frame.origin.x, progress.frame.origin.y, [newWidth intValue], progress.frame.size.height);
}

- (void) uploadManagerDidFailUploadingForAsset:(NSString *) assetToUpload {
    progress.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerQuotaExceedForAsset:(NSString *) assetToUpload {
    [self updateProgressByWidth:[NSNumber numberWithLong:progressBg.frame.size.width]];
    progress.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerLoginRequiredForAsset:(NSString *) assetToUpload {
    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    progress.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerDidFinishUploadingForAsset:(NSString *)assetToUpload withFinalFile:(MetaFile *) finalFile {
    [self updateProgressByWidth:[NSNumber numberWithLong:progressBg.frame.size.width]];
    progress.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
    [delegate photosHeaderSyncFinishedForAssetUrl:assetUrlRef];
//    [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0f];
}

- (void) uploadManagerDidFailUploadingAsData {
    [self updateProgressByWidth:[NSNumber numberWithLong:progressBg.frame.size.width]];
    progress.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerDidFinishUploadingAsData {
    [self updateProgressByWidth:[NSNumber numberWithLong:progressBg.frame.size.width]];
    progress.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
}

- (void) dismissView {
    [delegate photosHeaderSyncFinishedForAssetUrl:assetUrlRef];
}

- (void) checkProgressInfo {
    int totalUploadCount = (int) [[[UploadQueue sharedInstance] uploadManagers] count];
    int finishedUploadCount = [[UploadQueue sharedInstance] finishedUploadCount];
    NSString *infoMessage = [NSString stringWithFormat:@"%d/%d%@", finishedUploadCount + 1, totalUploadCount > AUTO_SYNC_ASSET_COUNT ? AUTO_SYNC_ASSET_COUNT : totalUploadCount, ((totalUploadCount%AUTO_SYNC_ASSET_COUNT==0) || totalUploadCount > AUTO_SYNC_ASSET_COUNT) ? @"+" : @""];
    progressLabel.text = infoMessage;
}

@end
