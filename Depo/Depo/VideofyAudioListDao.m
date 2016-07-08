//
//  VideofyAudioListDao.m
//  Depo
//
//  Created by Mahir Tarlan on 28/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VideofyAudioListDao.h"

@implementation VideofyAudioListDao

- (void) requestAudioList {
    NSURL *url = [NSURL URLWithString:VIDEOFY_AUDIO_URL];
    
    IGLog(@"VideofyAudioListDao requestAudioList called");
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"VideofyAudioListDao Response: %@", responseStr);
        
        IGLog(@"VideofyAudioListDao requestFinished");
        
        SBJSON *jsonParser = [SBJSON new];
        NSArray *mainArr = [jsonParser objectWithString:responseStr];

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
            [self shouldReturnSuccessWithObject:result];
            return;
        }
    }
    IGLog(@"VideofyAudioListDao requestFinished with error");
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
