//
//  RefAlbumCell.h
//  Depo
//
//  Created by Mahir on 10/3/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaAlbum.h"

@interface RefAlbumCell : UITableViewCell

@property (nonatomic, strong) MetaAlbum *album;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
          withAlbum:(MetaAlbum *) _album;

@end
