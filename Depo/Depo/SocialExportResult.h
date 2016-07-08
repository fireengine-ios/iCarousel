//
//  SocialExportResult.h
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface SocialExportResult : NSObject

@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL syncEnabled;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic) SocialExportStatus status;

@end
