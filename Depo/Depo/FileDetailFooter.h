//
//  FileDetailFooter.h
//  Depo
//
//  Created by Mahir on 10/20/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@protocol FileDetailFooterDelegate <NSObject>
- (void) fileDetailFooterDidTriggerDelete;
- (void) fileDetailFooterDidTriggerShare;
@end

@interface FileDetailFooter : UIView

@property (nonatomic, strong) id<FileDetailFooterDelegate> delegate;
@property (nonatomic, strong) CustomButton *shareButton;
@property (nonatomic, strong) CustomButton *deleteButton;

@end
