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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withUploadRef:(UploadRef *) ref atFolder:(NSString *) folderName {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.uploadRef = ref;
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 16, 35, 35)];
        self.imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:self.uploadRef.tempUrl]];
        self.imgView.alpha = 0.5f;
        [self addSubview:self.imgView];

        CGRect nameFieldRect = CGRectMake(70, 13, self.frame.size.width - 80, 22);
        CGRect detailFieldRect = CGRectMake(70, 35, self.frame.size.width - 80, 20);

        UIFont *nameFont = [self readNameFont];
        UIFont *detailFont = [self readDetailFont];

        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[self readNameColor] withText:uploadRef.fileName];
        [self addSubview:nameLabel];

        detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[self readDetailColor] withText:NSLocalizedString(@"UploadingPlaceholder", @"")];
        [self addSubview:detailLabel];

        for(UploadManager *manager in APPDELEGATE.uploadQueue.uploadManagers) {
            if(!manager.hasFinished && [manager.uploadRef.fileUuid isEqualToString:self.uploadRef.fileUuid]) {
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

- (void) uploadManagerDidFailUploadingForAsset:(ALAsset *)assetToUpload {
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
    detailLabel.text = NSLocalizedString(@"UploadFailedPlaceholder", @"");
}

- (void) uploadManagerDidFailUploadingAsData {
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
    detailLabel.text = NSLocalizedString(@"UploadFailedPlaceholder", @"");
}

- (void) uploadManagerDidFinishUploadingForAsset:(ALAsset *)assetToUpload {
    self.imgView.alpha = 1.0f;
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
    detailLabel.text = NSLocalizedString(@"UploadFinishedPlaceholder", @"");
}

- (void) uploadManagerDidFinishUploadingAsData {
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
    detailLabel.text = NSLocalizedString(@"UploadFinishedPlaceholder", @"");
}

@end
