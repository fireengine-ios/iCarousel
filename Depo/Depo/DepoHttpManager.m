//
//  ;
//  Depo
//
//  Created by Gürhan KODALAK on 18/06/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "DepoHttpManager.h"

@implementation DepoHttpManager

@synthesize urlSession;

+ (DepoHttpManager *) sharedInstance {
    static DepoHttpManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DepoHttpManager alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 10;
        self.urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return self;
}

- (void) URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    NSLog(@"HTTP Manager delegate : Did Become Invalid With Error!");
}

//- (void) URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
//    NSLog(@"HTTP Manager delegate : Did Receive Challenge!");
////    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
//}

- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"HTTP Manager delegate : Did finish event for Background Session!");

}

@end
