//
//  DepoUploadTask.h
//  Depo
//
//  Created by Mahir on 10/6/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadNotifyDao.h"
#import "MetaFile.h"
#import "UploadRef.h"
#import "AppConstants.h"

@protocol DepoUploadTaskDelegate <NSObject>
- (void) uploadTaskDidSendData:(long) dataSent ofTotalData:(long) totalData;
- (void) uploadTaskDidFinish;
@end

@interface DepoUploadTask : NSURLSessionUploadTask

@property (nonatomic, strong) id<DepoUploadTaskDelegate> uploadDelegate;
@property (nonatomic, strong) UploadNotifyDao *notifyDao;
@property (nonatomic, strong) UploadRef *uploadRef;
@property (nonatomic, strong) NSDate *initializationDate;
@property (nonatomic) UploadTaskType taskType;

- (void) didFinishSendingData:(long) dataSent ofTotalData:(long) totalData;
- (void) didComplete;

@end
