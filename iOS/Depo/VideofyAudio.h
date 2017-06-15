//
//  VideofyAudio.h
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideofyAudio : NSObject

@property (nonatomic) long audioId;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *type;

@end
