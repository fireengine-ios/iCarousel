//
//  AlbumDetailDao.m
//  Depo
//
//  Created by Mahir on 10/13/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumDetailDao.h"
#import "PhotoAlbum.h"

@implementation AlbumDetailDao

- (void) requestDetailOfAlbum:(NSString *) albumUuid forStart:(int) page andSize:(int) size {
    NSString *albumDetailUrl = [NSString stringWithFormat:ALBUM_DETAIL_URL, albumUuid, page, size];
	NSURL *url = [NSURL URLWithString:albumDetailUrl];
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
                [self requestFinished:data];
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

- (void)requestFinished:(NSData *) data {
    NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    PhotoAlbum *result = [[PhotoAlbum alloc] init];
    if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
        NSString *label = [mainDict objectForKey:@"label"];
        NSString *uuid = [mainDict objectForKey:@"uuid"];
        NSNumber *imageCount = [mainDict objectForKey:@"imageCount"];
        NSNumber *videoCount = [mainDict objectForKey:@"videoCount"];
        NSString *lastModifiedDate = [mainDict objectForKey:@"lastModifiedDate"];
        NSNumber *readOnly = [mainDict objectForKey:@"readOnly"];
        
        result.imageCount = [self intByNumber:imageCount];
        result.videoCount = [self intByNumber:videoCount];
        result.label = [self strByRawVal:label];
        result.uuid = [self strByRawVal:uuid];
        result.lastModifiedDate = [self dateByRawVal:lastModifiedDate];
        result.isReadOnly = [self boolByNumber:readOnly];
        
        NSArray *mainArray = [mainDict objectForKey:@"fileList"];
        
        NSMutableArray *content = [[NSMutableArray alloc] init];
        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
            for(NSDictionary *fileDict in mainArray) {
                [content addObject:[self parseFile:fileDict]];
            }
        }
        NSDictionary *coverDict = [mainDict objectForKey:@"coverPhoto"];
        if(coverDict != nil && ![coverDict isKindOfClass:[NSNull class]]) {
            result.cover = [self parseFile:coverDict];
        }
        result.content = content;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shouldReturnSuccessWithObject:result];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
        });
    }
//	NSError *error = [request error];
//	if (!error) {
//		NSString *responseEnc = [request responseString];
////        NSLog(@"Album Detail Response: %@", responseEnc);
//        
//		SBJSON *jsonParser = [SBJSON new];
//	} else {
//	}
}

@end
