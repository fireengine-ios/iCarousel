//
//  MetaAlbum.h
//  Depo
//
//  Created by Mahir on 10/3/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetaAlbum : NSObject

@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) UIImage *thumbnailImg;
@property (nonatomic) int count;

@end
