//
//  AlbumRemovePhotosDao.m
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumRemovePhotosDao.h"
#import "PhotoAlbum.h"

@implementation AlbumRemovePhotosDao

- (void) requestRemovePhotos:(NSArray *) uuidList fromAlbum:(NSString *) albumUuid {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:ALBUM_REMOVE_PHOTOS_URL, albumUuid]];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:uuidList options:NSJSONWritingPrettyPrinted error:nil];
    
//    NSLog(@"Album Remove Photos Payload: %@", jsonStr);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
    [request addValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[postData mutableCopy]];
    
    request = [self sendPutRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                PhotoAlbum *album = [[PhotoAlbum alloc] init];
                
                if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                    NSString *label = [mainDict objectForKey:@"label"];
                    NSString *uuid = [mainDict objectForKey:@"uuid"];
                    NSNumber *imageCount = [mainDict objectForKey:@"imageCount"];
                    NSNumber *videoCount = [mainDict objectForKey:@"videoCount"];
                    
                    album.imageCount = [self intByNumber:imageCount];
                    album.videoCount = [self intByNumber:videoCount];
                    album.label = [self strByRawVal:label];
                    album.uuid = [self strByRawVal:uuid];
                    
                    NSDictionary *coverDict = [mainDict objectForKey:@"coverPhoto"];
                    if(coverDict != nil && ![coverDict isKindOfClass:[NSNull class]]) {
                        album.cover = [self parseFile:coverDict];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:album];
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
    [task resume];
    self.currentTask = task;
}
//
//- (void)requestFinished:(ASIHTTPRequest *)request {
//    NSError *error = [request error];
//    
//    if (!error) {
//        NSString *responseEnc = [request responseString];
//        
////        NSLog(@"Album Remove Photos Response: %@", responseEnc);
//        
//        SBJSON *jsonParser = [SBJSON new];
//        NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];
//        
//        PhotoAlbum *album = [[PhotoAlbum alloc] init];
//
//        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
//            NSString *label = [mainDict objectForKey:@"label"];
//            NSString *uuid = [mainDict objectForKey:@"uuid"];
//            NSNumber *imageCount = [mainDict objectForKey:@"imageCount"];
//            NSNumber *videoCount = [mainDict objectForKey:@"videoCount"];
//            
//            album.imageCount = [self intByNumber:imageCount];
//            album.videoCount = [self intByNumber:videoCount];
//            album.label = [self strByRawVal:label];
//            album.uuid = [self strByRawVal:uuid];
//            
//            NSDictionary *coverDict = [mainDict objectForKey:@"coverPhoto"];
//            if(coverDict != nil && ![coverDict isKindOfClass:[NSNull class]]) {
//                album.cover = [self parseFile:coverDict];
//            }
//        }
//
//        [self shouldReturnSuccessWithObject:album];
//    } else {
//        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
//    }
//    
//}

@end
