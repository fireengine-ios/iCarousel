//
//  ProfilePhotoUploadDao.m
//  Depo
//
//  Created by Mahir Tarlan on 27/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "ProfilePhotoUploadDao.h"

@implementation ProfilePhotoUploadDao

- (void) requestUploadForImage:(UIImage *) imageFile {
    NSString *urlStr = PROFILE_IMG_URL;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSData *imageData = UIImagePNGRepresentation(imageFile);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setPostBody:[imageData mutableCopy]];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    [self sendPutRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseEnc = [request responseString];
        NSLog(@"Profile Image Upload Response: %@", responseEnc);
        [self shouldReturnSuccess];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
