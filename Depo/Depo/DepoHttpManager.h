//
//  DepoHttpManager.h
//  Depo
//
//  Created by Gürhan KODALAK on 18/06/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepoHttpManager : NSObject <NSURLSessionDataDelegate>

@property (nonatomic,strong) NSURLSession *urlSession;

+ (DepoHttpManager *) sharedInstance;

@end
