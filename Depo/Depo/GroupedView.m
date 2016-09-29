//
//  GroupedView.m
//  Depo
//
//  Created by Mahir Tarlan on 10/09/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "GroupedView.h"
#import "CustomLabel.h"
#import "Util.h"
#import "UIImageView+AFNetworking.h"
#import "CustomButton.h"

@interface GroupedView() {
    CustomLabel *titleLabel;
    CustomLabel *locLabel;
    int counter;
    int imageCountPerRowRef;
    float imageWidthRef;
}
@end

@implementation GroupedView

@synthesize delegate;
@synthesize group;
@synthesize isSelectible;

- (id) initWithFrame:(CGRect)frame withGroup:(FileInfoGroup *) _group isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withImageCountPerRow:(int) imageCountPerRow {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.group = _group;
        self.isSelectible = selectFlag;
        imageCountPerRowRef = imageCountPerRow;
        imageWidthRef = imageWidth;
        
        NSString *titleVal = self.group.customTitle;
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, (self.frame.size.width-40)/2, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"555555"] withText:titleVal];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];
        
        locLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 10, (self.frame.size.width-40)/2, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"888888"] withText:self.group.locationInfo withAlignment:NSTextAlignmentRight];
        [self addSubview:locLabel];
        
        counter = 0;
        for(id row in self.group.fileInfo) {
            if([row isKindOfClass:[UploadRef class]]) {
                UploadRef *castedRow = (UploadRef *) row;
                SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageCountPerRow)*imageWidth, 40 + floorf(counter/imageCountPerRow)*imageWidth, imageWidth, imageWidth) withUploadRef:castedRow];
                rowImgView.delegate = self;
                [self addSubview:rowImgView];
                counter++;
            } else if([row isKindOfClass:[MetaFile class]]) {
                MetaFile *castedRow = (MetaFile *) row;
                SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageCountPerRow)*imageWidth, 40 + floorf(counter/imageCountPerRow)*imageWidth, imageWidth, imageWidth) withFile:castedRow withSelectibleStatus:selectFlag];
                rowImgView.delegate = self;
                [self addSubview:rowImgView];
                counter++;
            }
        }
    }
    return self;
}

- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected {
    [delegate groupedViewImageWasSelectedForFile:fileSelected forGroupWithKey:self.group.customTitle];
}

- (void) squareImageWasMarkedForFile:(MetaFile *) fileSelected {
    [delegate groupedViewImageWasMarkedForFile:fileSelected];
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    [delegate groupedViewImageWasUnmarkedForFile:fileSelected];
}

- (void) squareImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
    [delegate groupedViewImageUploadFinishedForFile:fileSelectedUuid];
}

- (void) squareImageWasLongPressedForFile:(MetaFile *) fileSelected {
    for(UIView *innerView in [self subviews]) {
        if([innerView isKindOfClass:[SquareImageView class]]) {
            SquareImageView *sqView = (SquareImageView *) innerView;
            [sqView setNewStatus:YES];
        }
    }
    [delegate groupedViewImageWasLongPressedForFile:fileSelected];
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [delegate groupedViewImageUploadQuotaError:fileSelected];
}

- (void) squareImageUploadLoginError:(MetaFile *) fileSelected {
    [delegate groupedViewImageUploadLoginError:fileSelected];
}

- (void) squareImageWasSelectedForView:(SquareImageView *) ref {
    [delegate groupedViewImageWasSelectedForView:ref];
}

- (void) loadMoreImages:(NSArray *) moreImages {
    for(id row in moreImages) {
        if([row isKindOfClass:[UploadRef class]]) {
            UploadRef *castedRow = (UploadRef *) row;
            SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageCountPerRowRef)*imageWidthRef, 40 + floorf(counter/imageCountPerRowRef)*imageWidthRef, imageWidthRef, imageWidthRef) withUploadRef:castedRow];
            rowImgView.delegate = self;
            [self addSubview:rowImgView];
            counter++;
        } else if([row isKindOfClass:[MetaFile class]]) {
            MetaFile *castedRow = (MetaFile *) row;
            SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageCountPerRowRef)*imageWidthRef, 40 + floorf(counter/imageCountPerRowRef)*imageWidthRef, imageWidthRef, imageWidthRef) withFile:castedRow withSelectibleStatus:isSelectible];
            rowImgView.delegate = self;
            [self addSubview:rowImgView];
            counter++;
        }
    }
    [self.group.fileInfo addObjectsFromArray:moreImages];
}

- (void) setToSelectible {
    for(id row in self.subviews) {
        if([row isKindOfClass:[SquareImageView class]]) {
            SquareImageView *castedView = (SquareImageView *) row;
            if(castedView.file) {
                [castedView setNewStatus:YES];
            }
        }
    }
}

- (void) setToUnselectible {
    for(id row in self.subviews) {
        if([row isKindOfClass:[SquareImageView class]]) {
            SquareImageView *castedView = (SquareImageView *) row;
            if(castedView.file) {
                [castedView setNewStatus:NO];
            }
        }
    }
}

@end
