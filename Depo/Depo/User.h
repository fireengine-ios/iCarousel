//
//  User.h
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface User : NSObject

@property (nonatomic, strong) NSString *profileImgUrl;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) NSString *mobileUploadFolderUuid;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic) BOOL cropAndSharePresentFlag;
@property (nonatomic) AccountType accountType;
@property (nonatomic, strong) NSString *cellographId;

@end
