//
//  RenameAlbumDao.m
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RenameAlbumDao.h"
#import "PhotoAlbum.h"

@implementation RenameAlbumDao

@synthesize nameRef;

- (void) requestRenameAlbum:(NSString *) albumUuid withNewName:(NSString *) newName {
    self.nameRef = newName;
    
    NSString *urlStr = [NSString stringWithFormat:RENAME_ALBUM_URL, albumUuid, newName];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSLog(@"RENAME ALBUM URL: %@", urlStr);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendPutRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseEnc = [request responseString];
        NSLog(@"RENAME ALBUM Response: %@", responseEnc);
        
        PhotoAlbum *finalAlbum = [[PhotoAlbum alloc] init];
        finalAlbum.label = self.nameRef;
        finalAlbum.lastModifiedDate = [NSDate date];
        [self shouldReturnSuccessWithObject:finalAlbum];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
