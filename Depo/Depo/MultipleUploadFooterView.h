//
//  MultipleUploadFooterView.h
//  Depo
//
//  Created by Mahir on 10/1/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckButton.h"

@protocol MultipleUploadFooterDelegate <NSObject>
- (void) multipleUploadFooterDidTriggerSelectAll;
- (void) multipleUploadFooterDidTriggerDeselectAll;
- (void) multipleUploadFooterDidTriggerUpload;
@end

@interface MultipleUploadFooterView : UIView {
    CheckButton *checkButton;
}

@property (nonatomic, strong) id<MultipleUploadFooterDelegate> delegate;

@end
