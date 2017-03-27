//
//  FileDetailFooter.h
//  Depo
//
//  Created by Mahir on 10/20/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "PhotoAlbum.h"

@protocol FileDetailFooterDelegate <NSObject>
- (void) fileDetailFooterDidTriggerDelete;
- (void) fileDetailFooterDidTriggerDownload;
- (void) fileDetailFooterDidTriggerRemoveFromAlbum;
- (void) fileDetailFooterDidTriggerShare;
- (void) fileDetailFooterDidTriggerPrint;
@optional
- (void) fileDetailFooterDidTriggerSync;
@end

@interface FileDetailFooter : UIView

@property (nonatomic, strong) id<FileDetailFooterDelegate> delegate;
@property (nonatomic, strong) CustomButton *shareButton;
@property (nonatomic, strong) CustomButton *deleteButton;
@property (nonatomic, strong) CustomButton *downloadButton;
@property (nonatomic, strong) CustomButton *removeButton;
@property (nonatomic, strong) CustomButton *printButton;
@property (nonatomic, strong) CustomButton *syncButton;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *maskView;

- (id)initWithFrame:(CGRect)frame  withAlbum:(PhotoAlbum*)album;
- (id)initWithFrame:(CGRect)frame withPrintEnabled:(BOOL) printEnabledFlag withAlbum:(PhotoAlbum*)album;
- (id)initWithFrame:(CGRect)frame withPrintEnabled:(BOOL) printEnabledFlag withDeleteEnabled:(BOOL) deleteEnabledFlag withSyncEnabled:(BOOL) syncEnabledFlag withDownloadEnabled:(BOOL) downloadEnabledFlag withAlbum:(PhotoAlbum*)album;
- (void) updateInnerViews;

- (void) showMaskWithMessage:(NSString *) maskMsg;
- (void) hideMask;

@end
