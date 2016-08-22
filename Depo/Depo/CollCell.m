//
//  CollCell.m
//  Depo
//
//  Created by Mahir Tarlan on 19/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "CollCell.h"
#import "CustomLabel.h"
#import "Util.h"
#import "UIImageView+AFNetworking.h"
#import "CustomButton.h"

@interface CollCell() {
    CustomLabel *titleLabel;
    CustomLabel *locLabel;
    CustomButton *moreIconView;
}
@end

@implementation CollCell

@synthesize delegate;
@synthesize group;
@synthesize isSelectible;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withGroup:(FileInfoGroup *) _group withLevel:(ImageGroupLevel) level isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withImageCountPerRow:(int) imageCountPerRow {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.group = _group;
        self.isSelectible = selectFlag;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *titleVal = @"";
        if(self.group.groupType == ImageGroupTypeInProgress) {
            titleVal = NSLocalizedString(@"ImageGroupTypeInProgress", @"");
        } else {
            if(level == ImageGroupLevelYear) {
                titleVal = group.yearStr;
            } else if(level == ImageGroupLevelMonth) {
                NSDateFormatter *titleDateFormat = [[NSDateFormatter alloc] init];
                [titleDateFormat setDateFormat:@"MMMM, yy"];
                titleVal = [titleDateFormat stringFromDate:self.group.rangeRefDate];
            } else {
                NSDateFormatter *titleDateFormat = [[NSDateFormatter alloc] init];
                [titleDateFormat setDateFormat:@"dd MMM, yy"];
                titleVal = [titleDateFormat stringFromDate:self.group.rangeRefDate];
            }
        }
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, (self.frame.size.width-40)/2, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"555555"] withText:titleVal];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];
        
        locLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 10, (self.frame.size.width-40)/2, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"888888"] withText:self.group.locationInfo withAlignment:NSTextAlignmentRight];
        [self addSubview:locLabel];
        
        int counter = 0;
        if(self.group.groupType == ImageGroupTypeInProgress) {
            for(UploadRef *row in self.group.fileInfo) {
                SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageCountPerRow)*imageWidth, 40 + floorf(counter/imageCountPerRow)*imageWidth, imageWidth, imageWidth) withUploadRef:row];
                rowImgView.delegate = self;
                [self addSubview:rowImgView];
                counter++;
            }
        } else {
            for(MetaFile *row in self.group.fileInfo) {
                if(level == ImageGroupLevelDay) {
                    SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageCountPerRow)*imageWidth, 40 + floorf(counter/imageCountPerRow)*imageWidth, imageWidth, imageWidth) withFile:row withSelectibleStatus:selectFlag];
                    rowImgView.delegate = self;
                    [self addSubview:rowImgView];
                    counter++;
                } else {
                    if(counter < 7) {
                        SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageCountPerRow)*imageWidth, 40 + floorf(counter/imageCountPerRow)*imageWidth, imageWidth, imageWidth) withFile:row withSelectibleStatus:selectFlag];
                        rowImgView.delegate = self;
                        [self addSubview:rowImgView];
                        counter++;
                    }
                }
            }
            if(level != ImageGroupLevelDay) {
                if(counter >= 7) {
                    moreIconView = [[CustomButton alloc] initWithFrame:CGRectMake((imageCountPerRow-1)*imageWidth, 40 + imageWidth,imageWidth, imageWidth) withCenteredImageName:@"icon_more.png"];
                    [moreIconView addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:moreIconView];
                }
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

- (void) moreClicked {
    if(!isSelectible) {
        [delegate collCellMoreSelectedForDate:self.group.rangeStart];
    }
}

- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected {
    if(!isSelectible) {
        [delegate collCellImageWasSelectedForFile:fileSelected forGroupWithKey:self.group.uniqueKey];
    }
}

- (void) squareImageWasMarkedForFile:(MetaFile *) fileSelected {
    [delegate collCellImageWasMarkedForFile:fileSelected];
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    [delegate collCellImageWasUnmarkedForFile:fileSelected];
}

- (void) squareImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
    [delegate collCellImageUploadFinishedForFile:fileSelectedUuid];
}

- (void) squareImageWasLongPressedForFile:(MetaFile *) fileSelected {
    moreIconView.enabled = NO;
    for(UIView *innerView in [self subviews]) {
        if([innerView isKindOfClass:[SquareImageView class]]) {
            SquareImageView *sqView = (SquareImageView *) innerView;
            [sqView setNewStatus:YES];
        }
    }
    [delegate collCellImageWasLongPressedForFile:fileSelected];
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [delegate collCellImageUploadQuotaError:fileSelected];
}

- (void) squareImageUploadLoginError:(MetaFile *) fileSelected {
    [delegate collCellImageUploadLoginError:fileSelected];
}

- (void) squareImageWasSelectedForView:(SquareImageView *) ref {
    [delegate collCellImageWasSelectedForView:ref];
}

@end
