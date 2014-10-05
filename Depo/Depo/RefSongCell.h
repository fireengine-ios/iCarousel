//
//  RefSongCell.h
//  Depo
//
//  Created by Mahir on 10/4/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RefSongCell : UITableViewCell

@property (nonatomic, strong) MPMediaItem *item;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withMedia:(MPMediaItem *) _item;

@end
