//
//  UploadDao.m
//  Depo
//
//  Created by Mahir on 10/1/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "UploadDao.h"
#import "AppDelegate.h"
#import "AppSession.h"

@implementation UploadDao

- (void) requestUploadForFile:(ALAsset *) asset {
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    NSString *fileName = [rep filename];

    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, fileName];
	NSURL *url = [NSURL URLWithString:urlStr];
//    NSLog(@"UPLOAD URL: %@", urlStr);

    Byte *buffer = (Byte*)malloc(rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
    NSData *sourceData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendPutRequest:request];
    [request setHTTPBody:[sourceData copy]];
    [request addValue:@"false" forHTTPHeaderField:@"X-Object-Meta-Favourite"];
    [request addValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self checkResponseHasError:response]) {
                    [self shouldReturnSuccess];
                }
                else {
                    [self requestFailed:response];
                }
            });
        }
    }]];
    self.currentTask = task;
    [task resume];
    
}
//
//- (void)requestFinished:(NSData *) data withResponse:(NSURLResponse *) response {
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//    //TODO URL response'unda ne yapilmali??
//    [self shouldReturnSuccess];
//}

@end
