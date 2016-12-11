//
//  AlbumListDao.m
//  Depo
//
//  Created by Mahir on 10/9/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumListDao.h"
#import "PhotoAlbum.h"
#import "AppUtil.h"

@implementation AlbumListDao

- (void) requestAlbumListForStart:(int) start andSize:(int) size {
    NSString *albumListUrl = [NSString stringWithFormat:ALBUM_LIST_URL, start, size];
	NSURL *url = [NSURL URLWithString:albumListUrl];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    request.tag = REQ_TAG_FOR_ALBUM;
    
    request = [self sendGetRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                [self requestFinished:data];
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    [task resume];
    self.currentTask = task;
}

- (void) requestAlbumListForStart:(int) start andSize:(int) size andSortType:(SortType) sortType {
    sortType = [self resetSortType:sortType];

    NSString *sort = @"label";
    if(sortType == SortTypeDateAsc || sortType == SortTypeDateDesc) {
        sort = @"createdDate";
    }
    NSString *albumListUrl = [NSString stringWithFormat:ALBUM_LIST_W_SORT_URL, start, size, sort, [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC"];
    NSURL *url = [NSURL URLWithString:albumListUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    //TODO: request taglari ne icin kullaniliyor???
    //[request setDelegate:self];
    //request.tag = REQ_TAG_FOR_ALBUM;
    
    request = [self sendGetRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                [self requestFinished:data];
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    [task resume];
    self.currentTask = task;
}

- (void)requestFinished:(NSData *) data {
//	NSError *error = [request error];
    NSArray *mainArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
        for(NSDictionary *albumDict in mainArray) {
            if(albumDict != nil && ![albumDict isKindOfClass:[NSNull class]]) {
                NSNumber *albumId = [albumDict objectForKey:@"id"];
                NSString *label = [albumDict objectForKey:@"label"];
                NSString *uuid = [albumDict objectForKey:@"uuid"];
                NSNumber *imageCount = [albumDict objectForKey:@"imageCount"];
                NSNumber *videoCount = [albumDict objectForKey:@"videoCount"];
                NSNumber *readOnly = [albumDict objectForKey:@"readOnly"];
                
                PhotoAlbum *album = [[PhotoAlbum alloc] init];
                album.albumId = [self longByNumber:albumId];
                album.imageCount = [self intByNumber:imageCount];
                album.videoCount = [self intByNumber:videoCount];
                album.label = [self strByRawVal:label];
                album.uuid = [self strByRawVal:uuid];
                album.isReadOnly = [self boolByNumber:readOnly];
                
                NSDictionary *coverDict = [albumDict objectForKey:@"coverPhoto"];
                if(coverDict != nil && ![coverDict isKindOfClass:[NSNull class]]) {
                    album.cover = [self parseFile:coverDict];
                }
                [result addObject:album];
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shouldReturnSuccessWithObject:result];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
        });
    }
}

@end
