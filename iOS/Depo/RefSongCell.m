//
//  RefSongCell.m
//  Depo
//
//  Created by Mahir on 10/4/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RefSongCell.h"
#import "CustomLabel.h"
#import "Util.h"

@implementation RefSongCell

@synthesize item;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withMedia:(MPMediaItem *) _item {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.item = _item;

        NSString *titleVal = [item valueForProperty:MPMediaItemPropertyTitle];
        NSString *albumVal = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSString *artistVal = [item valueForProperty:MPMediaItemPropertyArtist];
        
        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"363E4F"] withText:titleVal];
        [self addSubview:nameLabel];

        CustomLabel *detailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 30, self.frame.size.width - 40, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"707a8f"] withText:[NSString stringWithFormat:@"%@ • %@", artistVal, albumVal]];
        [self addSubview:detailLabel];
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
