//
//  FileDetail.h
//  Depo
//
//  Created by Mahir on 9/29/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDetail : NSObject

@property (nonatomic) BOOL favoriteFlag;
@property (nonatomic, strong) NSString *thumbLargeUrl;
@property (nonatomic, strong) NSString *thumbMediumUrl;
@property (nonatomic, strong) NSString *thumbSmallUrl;
@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSString *songTitle;
@property (nonatomic) float duration;

@end
