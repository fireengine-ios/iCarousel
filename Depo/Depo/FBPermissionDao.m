//
//  FBPermissionDao.m
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FBPermissionDao.h"

@implementation FBPermissionDao

- (void) requestFbPermissionTypes {
    NSURL *url = [NSURL URLWithString:FB_PERMISSIONS_URL];
    
    IGLog(@"[GET] FBPermissionDao requestFbPermissionTypes called");
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"FBPermissionDao requestFbPermissionTypes Response: %@", responseStr);

        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && [mainDict isKindOfClass:[NSDictionary class]]) {
            NSArray *permissionsArr = [mainDict objectForKey:@"permissions"];
            if(permissionsArr != nil && ![permissionsArr isKindOfClass:[NSNull class]]) {
                IGLog(@"FBPermissionDao request finished successfully");
                [self shouldReturnSuccessWithObject:permissionsArr];
                return;
            }
        } else if(mainDict != nil && [mainDict isKindOfClass:[NSArray class]]) {
            //dict beklerken array gelme durumu oldugundan bu sekilde gelistirme eklendi
            NSArray *mainArr = (NSArray *) mainDict;
            IGLog(@"FBPermissionDao request finished successfully");
            [self shouldReturnSuccessWithObject:mainArr];
            return;
        }
    }
    IGLog(@"FBPermissionDao request failed with general error message");
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
