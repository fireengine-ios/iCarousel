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

@end
