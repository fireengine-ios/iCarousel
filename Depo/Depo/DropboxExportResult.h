//
//  DropboxExportResult.h
//  Depo
//
//  Created by Mahir Tarlan on 19/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface DropboxExportResult : NSObject

@property (nonatomic) BOOL connected;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) long progress;
@property (nonatomic) long failedSize;
@property (nonatomic) long successSize;
@property (nonatomic) long failedCount;
@property (nonatomic) long successCount;
@property (nonatomic) long skippedCount;
@property (nonatomic) long totalSize;
@property (nonatomic) DropboxExportStatus status;

@end
