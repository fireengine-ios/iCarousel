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
@property (nonatomic, strong) NSString *geoAdminLevel1;
@property (nonatomic, strong) NSString *geoAdminLevel2;
@property (nonatomic, strong) NSString *geoAdminLevel3;
@property (nonatomic, strong) NSString *geoAdminLevel4;
@property (nonatomic, strong) NSString *geoAdminLevel5;
@property (nonatomic, strong) NSString *geoAdminLevel6;
@property (nonatomic, strong) NSDate *fileDate;

@end
