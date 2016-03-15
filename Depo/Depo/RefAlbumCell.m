//
//  RefAlbumCell.m
//  Depo
//
//  Created by Mahir on 10/3/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RefAlbumCell.h"
#import "CustomLabel.h"
#import "Util.h"

@interface RefAlbumCell () {
    UIImageView *imgView;
    CustomLabel *nameLabel;
    CustomLabel *detailLabel;
    UIView *progressSeparator;
    UIImageView *indicatorView;
}
@end

@implementation RefAlbumCell

@synthesize album;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
          withAlbum:(MetaAlbum *) _album {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.album = _album;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 35, 35)];
        imgView.image = [album thumbnailImg];
        [self addSubview:imgView];

        CGRect nameFieldRect = CGRectMake(70, 10, self.frame.size.width - 80, 22);
        CGRect detailFieldRect = CGRectMake(70, 32, self.frame.size.width - 80, 20);
        
        UIFont *nameFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
        UIFont *detailFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:16];
        
        nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[Util UIColorForHexColor:@"363E4F"] withText:self.album.albumName];
        [self addSubview:nameLabel];
        
        detailLabel = [[CustomLabel alloc] initWithFrame:detailFieldRect withFont:detailFont withColor:[Util UIColorForHexColor:@"363E4F"] withText:[NSString stringWithFormat:@"%d", self.album.count]];
        [self addSubview:detailLabel];
        
        progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 59, self.frame.size.width, 1)];
        progressSeparator.backgroundColor = [Util UIColorForHexColor:@"E1E1E1"];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
        
        indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 23, 9, 14)];
        indicatorView.image = [UIImage imageNamed:@"right_grey_icon.png"];
        [self addSubview:indicatorView];
        
    }
    return self;
}

- (void) layoutSubviews {
    CGRect nameFieldRect = CGRectMake(70, self.frame.size.height/2-22, self.frame.size.width - 80, 22);
    CGRect detailFieldRect = CGRectMake(70, self.frame.size.height/2, self.frame.size.width - 80, 20);
    
    imgView.frame = CGRectMake(12, (self.frame.size.height-35)/2, 35, 35);
    nameLabel.frame = nameFieldRect;
    detailLabel.frame = detailFieldRect;
    progressSeparator.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    indicatorView.frame = CGRectMake(self.frame.size.width - 30, (self.frame.size.height-14)/2, 9, 14);
    [super layoutSubviews];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
