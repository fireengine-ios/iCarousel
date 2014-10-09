//
//  MainPhotoAlbumCell.m
//  Depo
//
//  Created by Mahir on 10/9/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MainPhotoAlbumCell.h"
#import "UIImageView+AFNetworking.h"

@implementation MainPhotoAlbumCell

@synthesize album;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withPhotoAlbum:(PhotoAlbum *) _album {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.album = _album;
        
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 160)];
        [bgImgView setImageWithURL:[NSURL URLWithString:self.album.cover.url]];
        [self addSubview:bgImgView];
        
    }
    return self;
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
