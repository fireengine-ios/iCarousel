//
//  DepoUploadTask.m
//  Depo
//
//  Created by Mahir on 10/6/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "DepoUploadTask.h"

@implementation DepoUploadTask

@synthesize uploadDelegate;
@synthesize notifyDao;
@synthesize uploadRef;
@synthesize initializationDate;
@synthesize taskType;

- (void) didFinishSendingData:(long) dataSent ofTotalData:(long) totalData {
    [uploadDelegate uploadTaskDidSendData:dataSent ofTotalData:totalData];
}

- (void) didComplete {
    [uploadDelegate uploadTaskDidFinish];
}

@end
