//
//  GroupedPhotosCell.m
//  Depo
//
//  Created by Mahir Tarlan on 26/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "GroupedPhotosCell.h"
#import "CustomLabel.h"
#import "Util.h"
#import "MetaFile.h"
#import "UIImageView+WebCache.h"
#import "UploadRef.h"
#import "SquareImageView.h"

@interface GroupedPhotosCell() {
    CustomLabel *titleLabel;
    CustomLabel *locLabel;
    UIView *imageContainer;
}
@end

@implementation GroupedPhotosCell

@synthesize delegate;
@synthesize group;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withGroup:(FileInfoGroup *) _group withLevel:(ImageGroupLevel) level isSelectible:(BOOL) selectFlag {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.group = _group;
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
        
        int imageForRow = level == ImageGroupLevelYear ? 10 : level == ImageGroupLevelMonth ? 8 : 4;

        float imageItemSize = self.frame.size.width/imageForRow;
        
        float imageContainerHeight = (floorf(self.group.fileInfo.count/imageForRow)+1)*imageItemSize;
        
        imageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, imageContainerHeight)];
        [self addSubview:imageContainer];
        
        int counter = 0;
        if(self.group.groupType == ImageGroupTypeInProgress) {
            for(UploadRef *row in self.group.fileInfo) {
                SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageForRow)*imageItemSize, floorf(counter/imageForRow)*imageItemSize, imageItemSize, imageItemSize) withUploadRef:row];
                rowImgView.delegate = self;
                [imageContainer addSubview:rowImgView];
                counter++;
            }
        } else {
            for(MetaFile *row in self.group.fileInfo) {
                if(level == ImageGroupLevelDay) {
                    SquareImageView *rowImgView = [[SquareImageView alloc] initWithFrame:CGRectMake((counter%imageForRow)*imageItemSize, floorf(counter/imageForRow)*imageItemSize, imageItemSize, imageItemSize) withFile:row withSelectibleStatus:selectFlag];
                    rowImgView.delegate = self;
                    [imageContainer addSubview:rowImgView];
                    counter++;
                } else {
                    UIImageView *rowImgView = [[UIImageView alloc] initWithFrame:CGRectMake((counter%imageForRow)*imageItemSize, floorf(counter/imageForRow)*imageItemSize, imageItemSize, imageItemSize)];
                    [rowImgView sd_setImageWithURL:[NSURL URLWithString:row.detail.thumbMediumUrl]];
                    [imageContainer addSubview:rowImgView];
                    counter++;
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

- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected {
    [delegate groupedPhotoCellImageWasSelectedForFile:fileSelected forGroupWithKey:self.group.uniqueKey];
}

- (void) squareImageWasMarkedForFile:(MetaFile *) fileSelected {
    [delegate groupedPhotoCellImageWasMarkedForFile:fileSelected];
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    [delegate groupedPhotoCellImageWasUnmarkedForFile:fileSelected];
}

- (void) squareImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
    [delegate groupedPhotoCellImageUploadFinishedForFile:fileSelectedUuid];
}

- (void) squareImageWasLongPressedForFile:(MetaFile *) fileSelected {
    [delegate groupedPhotoCellImageWasLongPressedForFile:fileSelected];
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [delegate groupedPhotoCellImageUploadQuotaError:fileSelected];
}

- (void) squareImageUploadLoginError:(MetaFile *) fileSelected {
    [delegate groupedPhotoCellImageUploadLoginError:fileSelected];
}

- (void) squareImageWasSelectedForView:(SquareImageView *) ref {
    [delegate groupedPhotoCellImageWasSelectedForView:ref];
}

@end
