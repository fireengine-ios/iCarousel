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
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                User *user = [[User alloc] init];
                if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                    NSString *name = [mainDict objectForKey:@"name"];
                    NSString *surname = [mainDict objectForKey:@"surname"];
                    NSString *mobileUploadsSpecialFolderUuid = [mainDict objectForKey:@"mobileUploadsSpecialFolderUuid"];
                    NSString *url = [mainDict objectForKey:@"url"];
                    NSString *accountType = [mainDict objectForKey:@"accountType"];
                    NSNumber *isCropAndShareTagAvailable = [mainDict objectForKey:@"isCropyTagAvailable"];
                    NSNumber *isFavouriteTagAvailable = [mainDict objectForKey:@"isFavouriteTagAvailable"];
                    NSString *username = [mainDict objectForKey:@"username"];
                    NSString *email = [mainDict objectForKey:@"email"];
                    NSString *phoneNumber = [mainDict objectForKey:@"phoneNumber"];
                    NSString *countryCode = [mainDict objectForKey:@"countryCode"];
                    NSString *cellografId = [mainDict objectForKey:@"cellografId"];
                    
                    user.fullName = [NSString stringWithFormat:@"%@ %@", [self strByRawVal:name], [self strByRawVal:surname]];
                    //            user.fullName = [NSString stringWithFormat:@"%@", [self strByRawVal:name]];
                    user.name = [self strByRawVal:name];
                    user.surname = [self strByRawVal:surname];
                    user.profileImgUrl = [self strByRawVal:url];
                    user.username = [self strByRawVal:username];
                    user.email = [self strByRawVal:email];
                    user.phoneNumber = [self strByRawVal:phoneNumber];
                    user.countryCode = [self strByRawVal:countryCode];
                    user.cellographId = [self strByRawVal:cellografId];
                    
                    if(mobileUploadsSpecialFolderUuid != nil && ![mobileUploadsSpecialFolderUuid isKindOfClass:[NSNull class]]) {
                        user.mobileUploadFolderUuid = mobileUploadsSpecialFolderUuid;
                    }
                    if(isCropAndShareTagAvailable && ![isCropAndShareTagAvailable isKindOfClass:[NSNull class]]) {
                        user.cropAndSharePresentFlag = [isCropAndShareTagAvailable boolValue];
                    }
                    if(isFavouriteTagAvailable && ![isFavouriteTagAvailable isKindOfClass:[NSNull class]]) {
                        user.favouriteTagPresentFlag = [isFavouriteTagAvailable boolValue];
                    }
                    if(accountType && ![accountType isKindOfClass:[NSNull class]]) {
                        user.accountType = [accountType isEqualToString:@"TURKCELL"] ? AccountTypeTurkcell : AccountTypeOther;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:user];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
