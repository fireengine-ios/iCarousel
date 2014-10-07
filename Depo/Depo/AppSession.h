//
//  AppSession.h
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface AppSession : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSMutableArray *uploadManagers;

- (NSArray *) uploadRefsForFolder:(NSString *) folderName;

@end
