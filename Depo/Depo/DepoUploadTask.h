//
//  DepoUploadTask.h
//  Depo
//
//  Created by Mahir on 10/6/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DepoUploadTaskDelegate <NSObject>
- (void) uploadTaskDidSendData:(long) dataSent ofTotalData:(long) totalData;
- (void) uploadTaskDidFinish;
@end

@interface DepoUploadTask : NSURLSessionUploadTask

@property (nonatomic, strong) id<DepoUploadTaskDelegate> uploadDelegate;

- (void) didFinishSendingData:(long) dataSent ofTotalData:(long) totalData;
- (void) didComplete;

@end
