//
//  AudioMenuFooterView.h
//  Depo
//
//  Created by Mahir on 27.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaFile.h"
#import "CustomLabel.h"
#import "CustomButton.h"

@interface AudioMenuFooterView : UIView

@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) CustomLabel *titleLabel;
@property (nonatomic, strong) CustomLabel *detailLabel;
@property (nonatomic, strong) UIImageView *albumImgView;
@property (nonatomic, strong) CustomButton *playButton;
@property (nonatomic, strong) CustomButton *pauseButton;

- (id) initWithFrame:(CGRect)frame withFile:(MetaFile *) _file;

@end
