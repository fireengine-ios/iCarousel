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
#import "ElasticSearchDao.h"
#import "CustomConfirmView.h"

@protocol ImagePreviewDelegate <NSObject>
- (void) previewedImageWasDeleted:(MetaFile *) deletedFile;
@end

@interface ImagePreviewController : MyViewController <UIScrollViewDelegate, FileDetailFooterDelegate, CustomConfirmDelegate> {
    UIImageView *imgView;
    FileDetailFooter *footer;
    CustomButton *moreButton;
    UIScrollView *mainScroll;
    
    ElasticSearchDao *elasticSearchDao;
    DeleteDao *deleteDao;
    FavoriteDao *favDao;
    RenameDao *renameDao;
    ShareLinkDao *shareDao;
    int listOffSet;
    int pagingEnabledFlag;
    MyNavigationController *printNav;
    BOOL refFromAlbumFlag;
}

@property (nonatomic, weak) id<ImagePreviewDelegate> delegate;
@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) NSMutableArray *files;
@property int cursor;

- (id)initWithFile:(MetaFile *) _file;
- (id)initWithFile:(MetaFile *) _file referencedFromAlbum:(BOOL) srcAlbumFlag;
- (id)initWithFiles:(NSArray *) _files withImage:(MetaFile *) _file withListOffset:(int) offset;
- (id) initWithFiles:(NSArray *)_files withImage:(MetaFile *)_file withListOffset:(int)offset printEnabled:(BOOL) printEnabledFlag;
- (id) initWithFiles:(NSArray *)_files withImage:(MetaFile *)_file withListOffset:(int)offset printEnabled:(BOOL) printEnabledFlag pagingEnabled:(BOOL) pagingEnabled;

@end
