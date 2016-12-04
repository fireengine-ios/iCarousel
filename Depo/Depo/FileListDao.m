//
//  FileListDao.m
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FileListDao.h"
#import "AppUtil.h"
#import "FileDetail.h"

@implementation FileListDao

@synthesize parentFolderUuid;

- (void) requestFileListingForParentForPage:(int) page andSize:(int) size sortBy:(SortType) sortType {
    sortType = [self resetSortType:sortType];

    NSString *parentListingUrl = [NSString stringWithFormat:FILE_LISTING_MAIN_URL, @"", [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC" : @"DESC", page, size];
	NSURL *url = [NSURL URLWithString:parentListingUrl];
	
    IGLog(@"[GET] FileListDao requestFileListingForParentForPage");
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self checkResponseHasError:response]) {
                    [self requestFinished:data withResponse:response];
                }
            });
        }
    }]];
    self.currentTask = task;
    [task resume];
}

- (void) requestFileListingForFolder:(NSString *) folderUuid andForPage:(int) page andSize:(int) size sortBy:(SortType) sortType {
    sortType = [self resetSortType:sortType];
    self.parentFolderUuid = folderUuid;

    NSString *parentListingUrl = [NSString stringWithFormat:FILE_LISTING_MAIN_URL, folderUuid, [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC" : @"DESC", page, size];
	NSURL *url = [NSURL URLWithString:parentListingUrl];
	
    IGLog(@"[GET] FileListDao requestFileListingForFolder");

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self checkResponseHasError:response]) {
                    [self requestFinished:data withResponse:response];
                }
            });
        }
    }]];
    self.currentTask = task;
    [task resume];
}

- (void) requestFolderListingForFolder:(NSString *) folderUuid andForPage:(int) page andSize:(int) size sortBy:(SortType) sortType {
    sortType = [self resetSortType:sortType];
    self.parentFolderUuid = folderUuid;

    NSString *parentListingUrl = [NSString stringWithFormat:FOLDER_LISTING_MAIN_URL, folderUuid==nil ? @"" : folderUuid, [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC" : @"DESC", page, size];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    IGLog(@"[GET] FileListDao requestFolderListingForFolder");

    //    NSLog(@"FOLDER URL: %@", parentListingUrl);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
                IGLog(@"FileListDao requestFinished with general error");
                //TODO Error handling nasil olmali ???
//                [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self checkResponseHasError:response]) {
                    [self requestFinished:data withResponse:response];
                }
            });
        }
    }]];
    self.currentTask = task;
    [task resume];
}

- (void)requestFinished:(NSData *)data withResponse:(NSURLResponse *) response {
    NSError *error;
    NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (!error) {
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSDictionary *mainArray = [mainDict objectForKey:@"fileList"];
            
            NSMutableArray *result = [[NSMutableArray alloc] init];
            
            if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
                for(NSDictionary *fileDict in mainArray) {
                    MetaFile *parsedFile = [self parseFile:fileDict];
                    parsedFile.parentUuid = self.parentFolderUuid;
                    [result addObject:parsedFile];
                }
            }
            IGLog(@"FileListDao requestFinished successfully");
            [self shouldReturnSuccessWithObject:result];
        } else {
            IGLog(@"FileListDao requestFinished with maindict null returning general error");
            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
        }
    }
    else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
}

@end
