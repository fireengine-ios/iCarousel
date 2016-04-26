//
//  FileInfoGroup.h
//  Depo
//
//  Created by Mahir Tarlan on 25/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileInfoGroup : NSObject

@property (nonatomic, strong) NSString *rangeStart;
@property (nonatomic, strong) NSString *rangeEnd;
@property (nonatomic, strong) NSString *locationInfo;
@property (nonatomic, strong) NSArray *fileInfo;

@end
