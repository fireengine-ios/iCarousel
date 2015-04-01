//
//  UploadingImageCell.m
//  Depo
//
//  Created by Mahir on 10/6/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "UploadingImageCell.h"
#import "AppDelegate.h"
#import "AppSession.h"

@implementation UploadingImageCell

@synthesize uploadRef;
@synthesize imgView;
@synthesize postFile;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withUploadRef:(UploadRef *) ref atFolder:(NSString *) folderName {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.uploadRef = ref;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 16, 35, 35)];
        imgView.alpha = 0.5f;
        [self addSubview:imgView];

//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^(void) {
            @autoreleasepool {
                /*
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.uploadRef.tempThumbnailUrl];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imgView.image = image;
                });
                 */
                //ALAssetsLibrary'den alir hale getirildi mahir-26.02.15
                if(self.uploadRef.taskType == UploadTaskTypeAsset) {
                    if(self.uploadRef.assetUrl) {
                        NSURL *assetUrl = [NSURL URLWithString:self.uploadRef.assetUrl];
                        ALAssetsLibrary *assetsLibraryForSingle = [[ALAssetsLibrary alloc] init];
                        [assetsLibraryForSingle assetForURL:assetUrl resultBlock:^(ALAsset *myAsset) {
                            CGImageRef thumbnailRef = [myAsset thumbnail];
                            if (thumbnailRef) {
                                imgView.image = [UIImage imageWithCGImage:thumbnailRef];
                            }
                        } failureBlock:nil];
                    }
                } else if(self.uploadRef.taskType == UploadTaskTypeFile) {
                    UIImage *thumbImageFromCam = [UIImage imageWithContentsOfFile:self.uploadRef.tempUrl];
                    imgView.image = [Util imageWithImage:thumbImageFromCam scaledToFillSize:CGSizeMake(40, 40)];
                }
            }
//        });

        CGRect nameFieldRect = CGRectMake(70, 13, self.frame.size.width - 80, 22);
        CGRect detailFieldRect = CGRectMake(70, 35, self.frame.size.width - 80, 20);

        UIFont *nameFont = [self readNameFont];
        UIFont *detailFont = [self readDetailFont];

        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:uploadRef.fileName];
        [self addSubview:nameLabel];

        detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[self readDetailColor] withText:NSLocalizedString(@"UploadingPlaceholder", @"")];
        [self addSubview:detailLabel];

        for(UploadManager *manager in [APPDELEGATE.uploadQueue.uploadManagers copy]) {
            if(!manager.uploadRef.hasFinished && [manager.uploadRef.fileUuid isEqualToString:self.uploadRef.fileUuid]) {
                manager.delegate = self;
            }
        }

        progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 66, 1, 2)];
        progressSeparator.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
    }
    return self;
}

- (void) uploadManagerDidSendData:(long)sentBytes inTotal:(long)totalBytes {
    int progressWidth = sentBytes*self.frame.size.width/totalBytes;
    [self performSelectorOnMainThread:@selector(updateProgressByWidth:) withObject:[NSNumber numberWithInt:progressWidth] waitUntilDone:NO];
}

- (void) updateProgressByWidth:(NSNumber *) newWidth {
    progressSeparator.frame = CGRectMake(0, 66, [newWidth intValue], 2);
}

- (void) uploadManagerDidFailUploadingForAsset:(NSString *)assetToUpload {
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
    detailLabel.text = NSLocalizedString(@"UploadFailedPlaceholder", @"");
}

- (void) uploadManagerQuotaExceedForAsset:(NSString *) assetToUpload {
    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
    detailLabel.text = NSLocalizedString(@"QuotaExceedMessageShort", @"");
}

- (void) uploadManagerLoginRequiredForAsset:(NSString *) assetToUpload {
    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
    detailLabel.text = NSLocalizedString(@"LoginRequiredMessage", @"");
}

- (void) uploadManagerDidFailUploadingAsData {
    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
    detailLabel.text = NSLocalizedString(@"UploadFailedPlaceholder", @"");
}

- (void) uploadManagerDidFinishUploadingForAsset:(NSString *)assetToUpload withFinalFile:(MetaFile *) finalFile {
    self.postFile = finalFile;
    self.imgView.alpha = 1.0f;
    [self updateProgressByWidth:[NSNumber numberWithInt:self.frame.size.width]];
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
    detailLabel.text = NSLocalizedString(@"UploadFinishedPlaceholder", @"");
}

- (void) uploadManagerDidFinishUploadingAsData {
    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
    detailLabel.text = NSLocalizedString(@"UploadFinishedPlaceholder", @"");
}

@end
