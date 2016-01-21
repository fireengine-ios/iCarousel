//
//  AccountInfoDao.m
//  Depo
//
//  Created by Mahir on 25/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "AccountInfoDao.h"
#import "User.h"
#import "AppDelegate.h"
#import "AppSession.h"

@implementation AccountInfoDao

- (void) requestAccountInfo {
    NSURL *url = [NSURL URLWithString:ACCOUNT_INFO_URL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];
        
        NSDictionary *headerParams = [request responseHeaders];
        NSString *accountWarning = [headerParams objectForKey:@"X-Account-Warning"];
        
        User *user = [[User alloc] init];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *name = [mainDict objectForKey:@"name"];
            NSString *surname = [mainDict objectForKey:@"surname"];
            NSString *mobileUploadsSpecialFolderUuid = [mainDict objectForKey:@"mobileUploadsSpecialFolderUuid"];
            NSString *url = [mainDict objectForKey:@"url"];
            NSString *accountType = [mainDict objectForKey:@"accountType"];
            NSNumber *isCropAndShareTagAvailable = [mainDict objectForKey:@"isCropyTagAvailable"];
            
            user.fullName = [NSString stringWithFormat:@"%@ %@", [self strByRawVal:name], [self strByRawVal:surname]];
            //            user.fullName = [NSString stringWithFormat:@"%@", [self strByRawVal:name]];
            user.name = [self strByRawVal:name];
            user.surname = [self strByRawVal:surname];
            user.profileImgUrl = [self strByRawVal:url];
            if(mobileUploadsSpecialFolderUuid != nil && ![mobileUploadsSpecialFolderUuid isKindOfClass:[NSNull class]]) {
                user.mobileUploadFolderUuid = mobileUploadsSpecialFolderUuid;
            }
            if(isCropAndShareTagAvailable && ![isCropAndShareTagAvailable isKindOfClass:[NSNull class]]) {
                user.cropAndSharePresentFlag = [isCropAndShareTagAvailable boolValue];
            }
            if(accountType && ![accountType isKindOfClass:[NSNull class]]) {
                user.accountType = [accountType isEqualToString:@"TURKCELL"] ? AccountTypeTurkcell : AccountTypeOther;
            }
            
            if(accountWarning != nil && ![accountWarning isKindOfClass:[NSNull class]]) {
                if([accountWarning isEqualToString:@"EMPTY_MSISDN"]) {
                    user.emailEmpty = YES;
                }
                if([accountWarning isEqualToString:@"EMPTY_EMAIL"]) {
                    user.msisdnEmpty = YES;
                }
                if([accountWarning isEqualToString:@"EMAIL_NOT_VERIFIED"]) {
                    user.emailNotVerified = YES;
                }
            }
            
        }
        [self shouldReturnSuccessWithObject:user];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
