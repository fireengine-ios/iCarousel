//
//  VideofyCreateDao.m
//  Depo
//
//  Created by Mahir Tarlan on 28/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VideofyCreateDao.h"

@implementation VideofyCreateDao

- (void) requestVideofyCreateForStory:(Story *) story {
    NSURL *url = [NSURL URLWithString:VIDEOFY_CREATE_URL];
    
    NSMutableArray *uuidList = [[NSMutableArray alloc] init];
    for(MetaFile *file in story.fileList) {
        [uuidList addObject:file.uuid];
    }
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:uuidList forKey:@"imageUUIDs"];
    [info setObject:story.title forKey:@"name"];
    if(story.musicFileUuid != nil) {
        [info setObject:story.musicFileUuid forKey:@"audioUUID"];
    } else if(story.musicFileId != nil) {
        [info setObject:story.musicFileId forKey:@"audioID"];
    }
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:postData];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        
        NSLog(@"VideofyCreateDao response: %@", responseStr);
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *status = [mainDict objectForKey:@"status"];
            if([status isEqualToString:@"OK"]) {
                [self shouldReturnSuccess];
                return;
            }
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    return;
}

@end
