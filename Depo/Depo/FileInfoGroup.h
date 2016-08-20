//
//  FileInfoGroup.h
//  Depo
//
//  Created by Mahir Tarlan on 25/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface FileInfoGroup : NSObject

@property (nonatomic, strong) NSString *uniqueKey;
@property (nonatomic, strong) NSDate *rangeRefDate;
@property (nonatomic, strong) NSString *rangeStart;
@property (nonatomic, strong) NSString *rangeEnd;
@property (nonatomic, strong) NSString *yearStr;
@property (nonatomic, strong) NSString *monthStr;
@property (nonatomic, strong) NSString *dayStr;
@property (nonatomic, strong) NSString *locationInfo;
@property (nonatomic, strong) NSString *customTitle;
@property (nonatomic, strong) NSMutableArray *fileInfo;
@property (nonatomic) ImageGroupType groupType;

@end
