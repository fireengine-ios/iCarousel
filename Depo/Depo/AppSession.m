//
//  AppSession.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AppSession.h"
#import "UploadManager.h"

@implementation AppSession

@synthesize user;
@synthesize authToken;
@synthesize baseUrl;
@synthesize uploadManagers;
@synthesize sortType;

- (id) init {
    if(self = [super init]) {
        self.uploadManagers = [[NSMutableArray alloc] init];
        self.sortType = SortTypeAlphaDesc;

        //TODO
        self.user = [[User alloc] init];
        self.user.profileImgUrl = @"http://s.turkcell.com.tr/profile_img/532/225/cjXlJsupflKCNP2jmf23A.jpg?wruN55vtoNoCItHngeSqW9QN4XM1Y9qgZHRnZnp8bGOut1pQZOk1!207944990!1411130039277";
        self.user.fullName = @"Mahir Kemal Tarlan";
        self.user.msisdn = @"5322109094";
        self.user.password = @"5322109094";
        //5322102103 for ios
        //5322109094 for presentation
    }
    return self;
}

- (NSArray *) uploadRefsForFolder:(NSString *) folderUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in self.uploadManagers) {
        if(!manager.hasFinished) {
            if(manager.uploadRef.folderUuid == nil && folderUuid == nil) {
                [result addObject:manager.uploadRef];
            } else if([folderUuid isEqualToString:manager.uploadRef.folderUuid]){
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
}

- (NSArray *) uploadImageRefs {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in self.uploadManagers) {
        if(!manager.hasFinished) {
            if(manager.uploadRef.contentType == ContentTypePhoto || manager.uploadRef.contentType == ContentTypeVideo) {
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
}

- (NSArray *) uploadImageRefsForAlbum:(NSString *) albumUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in self.uploadManagers) {
        if(!manager.hasFinished && [manager.uploadRef.albumUuid isEqualToString:albumUuid]) {
            if(manager.uploadRef.contentType == ContentTypePhoto || manager.uploadRef.contentType == ContentTypeVideo) {
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
}

@end
