//
//  MainPhotoAlbumCell.m
//  Depo
//
//  Created by Mahir on 10/9/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MainPhotoAlbumCell.h"
#import "UIImageView+AFNetworking.h"
#import "CustomLabel.h"

@implementation MainPhotoAlbumCell

@synthesize album;
@synthesize isSelectible;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withPhotoAlbum:(PhotoAlbum *) _album {
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier withPhotoAlbum:_album isSelectible:NO];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withPhotoAlbum:(PhotoAlbum *) _album isSelectible:(BOOL) selectibleFlag {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.album = _album;
        self.isSelectible = selectibleFlag;
        
        if(self.album.cover.tempDownloadUrl) {
            UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 160)];
            [bgImgView setImageWithURL:[NSURL URLWithString:self.album.cover.tempDownloadUrl]];
            [self addSubview:bgImgView];
            
            UIImageView *maskImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 160)];
            maskImgView.image = [UIImage imageNamed:@"album_mask.png"];
            [self addSubview:maskImgView];
        } else {
            UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 160)];
            bgImgView.image = [UIImage imageNamed:@"empty_album_header_bg.png"];
            [self addSubview:bgImgView];
        }

        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 100, self.frame.size.width - 40, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[UIColor whiteColor] withText:self.album.label];
        [self addSubview:titleLabel];
        
        NSString *subTitleVal = @"";
        if(self.album.imageCount > 0 && self.album.videoCount > 0) {
            subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitle", @""), self.album.imageCount, self.album.videoCount];
        } else if(self.album.imageCount > 0) {
            subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitlePhotosOnly", @""), self.album.imageCount];
        } else if(self.album.videoCount > 0) {
            subTitleVal = [NSString stringWithFormat: NSLocalizedString(@"AlbumCellSubtitleVideosOnly", @""), self.album.videoCount];
        }
        CustomLabel *subTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 124, self.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[UIColor whiteColor] withText:subTitleVal];
        [self addSubview:subTitleLabel];
        
        maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 160)];
        maskView.image = [UIImage imageNamed:@"album_selected_mask.png"];
        maskView.hidden = YES;
        [self addSubview:maskView];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(isSelectible) {
        if(selected) {
            maskView.hidden = NO;
        } else {
            maskView.hidden = YES;
        }
    }
}

@end
