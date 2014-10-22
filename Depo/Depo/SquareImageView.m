//
//  SquareImageView.m
//  Depo
//
//  Created by Mahir on 10/8/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SquareImageView.h"
#import "UIImageView+AFNetworking.h"
#import "CustomLabel.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "Util.h"

@implementation SquareImageView

@synthesize delegate;
@synthesize file;
@synthesize uploadRef;

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file {
    self = [super initWithFrame:frame];
    if (self) {
        self.file = _file;

        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [imgView setImageWithURL:[NSURL URLWithString:[self.file.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [self addSubview:imgView];
        
        if(self.file.contentType == ContentTypeVideo) {
            UIImageView *playIconView = [[UIImageView alloc] initWithFrame:CGRectMake(4, self.frame.size.height - 22, 18, 18)];
            playIconView.image = [UIImage imageNamed:@"mini_play_icon.png"];
            [self addSubview:playIconView];
        
            CustomLabel *durationLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(22, self.frame.size.height - 22, self.frame.size.width - 26, 18) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[UIColor whiteColor] withText:self.file.contentLengthDisplay];
            durationLabel.textAlignment = NSTextAlignmentRight;
            [self addSubview:durationLabel];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withUploadRef:(UploadRef *)ref {
    self = [super initWithFrame:frame];
    if (self) {
        self.uploadRef = ref;
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:self.uploadRef.tempUrl]];
        imgView.alpha = 0.5f;
        [self addSubview:imgView];

        for(UploadManager *manager in APPDELEGATE.session.uploadManagers) {
            if(!manager.hasFinished && [manager.uploadRef.fileUuid isEqualToString:self.uploadRef.fileUuid]) {
                manager.delegate = self;
            }
        }
        
        progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-6, 1, 6)];
        progressSeparator.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        progressSeparator.alpha = 0.75f;
        [self addSubview:progressSeparator];

    }
    return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [delegate squareImageWasSelectedForFile:self.file];
}

- (void) uploadManagerDidSendData:(long)sentBytes inTotal:(long)totalBytes {
    int progressWidth = sentBytes*self.frame.size.width/totalBytes;
    [self performSelectorOnMainThread:@selector(updateProgressByWidth:) withObject:[NSNumber numberWithInt:progressWidth] waitUntilDone:NO];
}

- (void) updateProgressByWidth:(NSNumber *) newWidth {
    progressSeparator.frame = CGRectMake(0, self.frame.size.height-6, [newWidth intValue], 6);
}

- (void) uploadManagerDidFailUploadingForAsset:(ALAsset *)assetToUpload {
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerDidFinishUploadingForAsset:(ALAsset *)assetToUpload {
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
    imgView.alpha = 1.0f;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
