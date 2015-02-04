//
//  FileDetailInWebViewController.h
//  Depo
//
//  Created by Mahir on 10/5/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "MetaFile.h"

#import "DeleteDao.h"
#import "FavoriteDao.h"
#import "RenameDao.h"

@protocol FileDetailInWebViewDelegate <NSObject>
- (void) previewedFileWasDeleted:(MetaFile *) fileDeleted;
@end

@interface FileDetailInWebViewController : MyViewController <UIWebViewDelegate> {
    CustomButton *moreButton;
    
    DeleteDao *deleteDao;
    FavoriteDao *favDao;
    RenameDao *renameDao;
}

@property (nonatomic, strong) id<FileDetailInWebViewDelegate> delegate;
@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) UIWebView *webView;

- (id)initWithFile:(MetaFile *) _file;

@end
