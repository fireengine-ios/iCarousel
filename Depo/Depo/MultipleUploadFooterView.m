//
//  MultipleUploadFooterView.m
//  Depo
//
//  Created by Mahir on 10/1/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MultipleUploadFooterView.h"
#import "Util.h"
#import "CustomLabel.h"
#import "CustomButton.h"

@implementation MultipleUploadFooterView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame selectAllEnabled:YES];
}

- (id)initWithFrame:(CGRect)frame selectAllEnabled:(BOOL) selectAllFlag {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        UIFont *font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
        
        if(selectAllFlag) {
            checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - 20)/2, 21, 20) isInitiallyChecked:NO];
            [checkButton addTarget:self action:@selector(triggerCheckAll) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:checkButton];
            
            CustomLabel *checkTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(50, (self.frame.size.height - 20)/2, 100, 20) withFont:font withColor:[UIColor whiteColor] withText:NSLocalizedString(@"SelectAllCheckTitle", @"")];
            [self addSubview:checkTitle];
        }
        
        CustomButton *uploadButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, (self.frame.size.height - 20)/2, 80, 20) withImageName:nil withTitle:NSLocalizedString(@"UploadButtonTitle", @"") withFont:font withColor:[UIColor whiteColor]];
        [uploadButton addTarget:self action:@selector(triggerUpload) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:uploadButton];
    }
    return self;
}

- (void) triggerCheckAll {
    [checkButton toggle];
    if(checkButton.isChecked) {
        [delegate multipleUploadFooterDidTriggerSelectAll];
    } else {
        [delegate multipleUploadFooterDidTriggerDeselectAll];
    }
}

- (void) triggerUpload {
    [delegate multipleUploadFooterDidTriggerUpload];
}

@end
