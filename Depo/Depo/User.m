//
//  User.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize profileImgUrl;
@synthesize fullName;
@synthesize mobileUploadFolderUuid;
@synthesize email;
@synthesize name;
@synthesize surname;
@synthesize cropAndSharePresentFlag;
@synthesize accountType;
@synthesize username;
@synthesize phoneNumber;
@synthesize countryCode;
@synthesize cellographId;

- (id) init {
    if(self = [super init]) {
    }
    return self;
}

@end
