//
//  GroupedCell.m
//  Depo
//
//  Created by Mahir Tarlan on 20/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "GroupedCell.h"
#import "CustomLabel.h"
#import "Util.h"
#import "UIImageView+AFNetworking.h"
#import "CustomButton.h"

@interface GroupedCell() {
    CustomLabel *titleLabel;
    CustomLabel *locLabel;
}
@end

@implementation GroupedCell

@synthesize delegate;
@synthesize group;
@synthesize isSelectible;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withGroup:(FileInfoGroup *) _group isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withImageCountPerRow:(int) imageCountPerRow {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.group = _group;
        self.isSelectible = selectFlag;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *titleVal = self.group.customTitle;
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, (self.frame.size.width-40)/2, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"555555"] withText:titleVal];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];

        locLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 10, (self.frame.size.width-40)/2, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"888888"] withText:self.group.locationInfo withAlignment:NSTextAlignmentRight];
        [self addSubview:locLabel];

        int counter = 0;
        for(id row in self.group.fileInfo) {
            if([row isKindOfClass:[UploadRef class]]) {
                UploadRef *castedRow = (UploadRef *) row;
                SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageCountPerRow)*imageWidth, 40 + floorf(counter/imageCountPerRow)*imageWidth, imageWidth, imageWidth) withUploadRef:castedRow];
                rowImgView.delegate = self;
                [self addSubview:rowImgView];
                counter++;
            } else if([row isKindOfClass:[MetaFile class]]) {
                MetaFile *castedRow = (MetaFile *) row;
                SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageCountPerRow)*imageWidth, 40 + floorf(counter/imageCountPerRow)*imageWidth, imageWidth, imageWidth) withFile:castedRow withSelectibleStatus:selectFlag shouldCache:YES];
                rowImgView.delegate = self;
                [self addSubview:rowImgView];
                counter++;
            }
        }
    }
    return self;
}

- (void) layoutSubviews {
    titleLabel.frame = CGRectMake(20, 10, (self.frame.size.width-40)/2, 20);
    locLabel.frame = CGRectMake(self.frame.size.width/2, 10, (self.frame.size.width-40)/2, 20);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected {
    [delegate groupedCellImageWasSelectedForFile:fileSelected forGroupWithKey:self.group.customTitle];
}

- (void) squareImageWasMarkedForFile:(MetaFile *) fileSelected {
    [delegate groupedCellImageWasMarkedForFile:fileSelected];
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    [delegate groupedCellImageWasUnmarkedForFile:fileSelected];
}

- (void) squareImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
    [delegate groupedCellImageUploadFinishedForFile:fileSelectedUuid];
}

- (void) squareImageWasLongPressedForFile:(MetaFile *) fileSelected {
    for(UIView *innerView in [self subviews]) {
        if([innerView isKindOfClass:[SquareImageView class]]) {
            SquareImageView *sqView = (SquareImageView *) innerView;
            [sqView setNewStatus:YES];
        }
    }
    [delegate groupedCellImageWasLongPressedForFile:fileSelected];
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [delegate groupedCellImageUploadQuotaError:fileSelected];
}

- (void) squareImageUploadLoginError:(MetaFile *) fileSelected {
    [delegate groupedCellImageUploadLoginError:fileSelected];
}

- (void) squareImageWasSelectedForView:(SquareImageView *) ref {
    [delegate groupedCellImageWasSelectedForView:ref];
}

/*
- (void) prepareForReuse {
    [super prepareForReuse];
    NSLog(@"At prepareForReuse");
}
*/

@end
