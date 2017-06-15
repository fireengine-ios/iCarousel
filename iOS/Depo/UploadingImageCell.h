//
//  UploadingImageCell.h
//  Depo
//
//  Created by Mahir on 10/6/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AbstractFileFolderCell.h"
#import "UploadManager.h"
#import "UploadRef.h"

@interface UploadingImageCell : AbstractFileFolderCell <UploadManagerDelegate> {
    UIView *progressSeparator;
    CustomLabel *detailLabel;
}

@property (nonatomic, strong) UploadRef *uploadRef;
@property (nonatomic, strong) MetaFile *postFile;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  withUploadRef:(UploadRef *) ref atFolder:(NSString *) folderName;
- (void)uploadManagerDidFinishUploadingForAsset:(NSString *)assetToUpload withFinalFile:(MetaFile *)finalFile;
- (void) updateProgressByWidth:(NSNumber *)newWidth;
@end
