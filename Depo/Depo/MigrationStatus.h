//
//  MigrationStatus.h
//  Depo
//
//  Created by Mahir on 03/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MigrationStatus : NSObject

@property (nonatomic) float progress;
@property (nonatomic, strong) NSString *status;

@end
