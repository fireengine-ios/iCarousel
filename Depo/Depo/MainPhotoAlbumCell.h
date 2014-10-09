//
//  MainPhotoAlbumCell.h
//  Depo
//
//  Created by Mahir on 10/9/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoAlbum.h"

@interface MainPhotoAlbumCell : UITableViewCell

@property (nonatomic, strong) PhotoAlbum *album;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withPhotoAlbum:(PhotoAlbum *) _album;

@end
