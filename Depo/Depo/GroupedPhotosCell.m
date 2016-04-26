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
#import "UIImageView+AFNetworking.h"

@interface GroupedPhotosCell() {
    CustomLabel *titleLabel;
    CustomLabel *locLabel;
    UIView *imageContainer;
}
@end

@implementation GroupedPhotosCell

@synthesize group;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withGroup:(FileInfoGroup *) _group {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.group = _group;
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width-40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"555555"] withText:self.group.rangeStart];
        [self addSubview:titleLabel];
        
        locLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width-40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"888888"] withText:self.group.locationInfo withAlignment:NSTextAlignmentRight];
        [self addSubview:locLabel];
        
        float imageItemSize = (self.frame.size.width - 40)/10;
        int imageForRow = 10;
        
        imageContainer = [[UIView alloc] initWithFrame:CGRectMake(20, 40, self.frame.size.width - 40, 40)];
        [self addSubview:imageContainer];
        
        int counter = 0;
        for(MetaFile *row in self.group.fileInfo) {
            UIImageView *rowImgView = [[UIImageView alloc] initWithFrame:CGRectMake((counter%imageForRow)*imageItemSize, floorf(counter/imageForRow)*imageItemSize, imageItemSize, imageItemSize)];
            [rowImgView setNoCachedImageWithURL:[NSURL URLWithString:row.detail.thumbSmallUrl]];
            [imageContainer addSubview:rowImgView];
            counter++;
        }
    }
    return self;
}

- (void) layoutSubviews {
    titleLabel.frame = CGRectMake(20, 10, self.frame.size.width-40, 20);
    locLabel.frame = CGRectMake(20, 10, self.frame.size.width-40, 20);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
