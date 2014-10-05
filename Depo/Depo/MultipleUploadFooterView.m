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
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(20, (self.frame.size.height - 20)/2, 21, 20) isInitiallyChecked:NO];
        [self addSubview:checkButton];
        
        UIFont *font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
        
        CustomLabel *checkTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(50, (self.frame.size.height - 20)/2, 100, 20) withFont:font withColor:[UIColor whiteColor] withText:NSLocalizedString(@"SelectAllCheckTitle", @"")];
        [self addSubview:checkTitle];
        
        CustomButton *uploadButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, (self.frame.size.height - 20)/2, 80, 20) withImageName:nil withTitle:NSLocalizedString(@"UploadButtonTitle", @"") withFont:font withColor:[UIColor whiteColor]];
        [uploadButton addTarget:self action:@selector(triggerUpload) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:uploadButton];
    }
    return self;
}

- (void) triggerUpload {
    [delegate multipleUploadFooterDidTriggerUpload];
}

@end
