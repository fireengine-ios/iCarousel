//
//  ImagePreviewController.h
//  Depo
//
//  Created by Mahir on 10/5/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "MetaFile.h"
#import "FileDetailFooter.h"
#import "CustomButton.h"

#import "DeleteDao.h"
#import "FavoriteDao.h"
#import "RenameDao.h"
#import "ShareLinkDao.h"

@protocol ImagePreviewDelegate <NSObject>
- (void) previewedImageWasDeleted:(MetaFile *) deletedFile;
@end

@interface ImagePreviewController : MyViewController <UIScrollViewDelegate, FileDetailFooterDelegate> {
    UIImageView *imgView;
    FileDetailFooter *footer;
    CustomButton *moreButton;
    UIScrollView *mainScroll;

    DeleteDao *deleteDao;
    FavoriteDao *favDao;
    RenameDao *renameDao;
    ShareLinkDao *shareDao;
}

@property (nonatomic, strong) id<ImagePreviewDelegate> delegate;
@property (nonatomic, strong) MetaFile *file;

- (id)initWithFile:(MetaFile *) _file;

@end
