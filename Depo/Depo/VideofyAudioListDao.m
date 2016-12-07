//
//  VideofyAudioListDao.m
//  Depo
//
//  Created by Mahir Tarlan on 28/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VideofyAudioListDao.h"
#import "Util.h"

@implementation VideofyAudioListDao

- (void) requestAudioList {
    NSString *urlStr = [NSString stringWithFormat:@"%@?language=%@", VIDEOFY_AUDIO_URL, [Util readLocaleCode]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    IGLog(@"[GET] VideofyAudioListDao requestAudioList called");
    
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
                NSArray *mainArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
                NSMutableArray *result = [[NSMutableArray alloc] init];
                if(mainArr != nil && ![mainArr isKindOfClass:[NSNull class]]) {
                    for(NSDictionary *rowDict in mainArr) {
                        NSNumber *audioId = [rowDict objectForKey:@"id"];
                        NSString *fileName = [rowDict objectForKey:@"fileName"];
                        NSString *path = [rowDict objectForKey:@"path"];
                        NSString *type = [rowDict objectForKey:@"type"];
                        
                        VideofyAudio *audio = [[VideofyAudio alloc] init];
                        audio.audioId = [self longByNumber:audioId];
                        audio.fileName = [self strByRawVal:fileName];
                        audio.path = [self strByRawVal:path];
                        audio.type = [self strByRawVal:type];
                        
                        [result addObject:audio];
                    }
                    IGLog(@"VideofyAudioListDao requestFinished successfully");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:result];
                    });
                }
                else {
                    IGLog(@"VideofyAudioListDao requestFinished with general error");
                    
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
