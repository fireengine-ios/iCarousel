//
//  SyncLogger.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "SyncLogger.h"
#import "SyncConstants.h"
#import "SyncAdapter.h"
#import "SyncSettings.h"

@interface SyncLogger ()
@property (strong) NSURL *fileURL;
@property (strong) NSFileHandle *fileHandle;
@property (strong) NSString *uniqueString;
@end

@implementation SyncLogger

- (void)startLogging:(NSString*)prefix
{
    if (!SYNC_IS_NULL(self.fileURL)){
        [self stopLogging];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    self.uniqueString = NSUUID.UUID.UUIDString;
    
    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@.txt", prefix, [dateFormatter stringFromDate:[NSDate date]], _uniqueString];
    self.fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:self.fileURL.path contents:[@"" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    NSError *error = nil;
    self.fileHandle = [NSFileHandle fileHandleForWritingToURL:self.fileURL error:&error];
    NSLog(@"file handle open %@",error);
}

- (void)log:(NSString*)msg
{
    if (!SYNC_IS_NULL(self.fileURL)){
        
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
//        NSError *error = nil;
//        [data writeToURL:self.fileURL options:NSDataWritingAtomic error:&error];
        [self.fileHandle seekToEndOfFile];
        [self.fileHandle writeData:data];
        [self.fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)stopLogging
{
    if (!SYNC_IS_NULL(self.fileURL)){
        NSError *error = nil;
        NSString* content = [NSString stringWithContentsOfFile:self.fileURL.path
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
//        NSLog(content);
        [SyncAdapter sendLog:[content dataUsingEncoding:NSUTF8StringEncoding] file:[NSString stringWithFormat:@"%@-%@",[SyncSettings shared].msisdn,[[self.fileURL absoluteString] lastPathComponent]]];
        
        [[NSFileManager defaultManager] removeItemAtURL:self.fileURL error:&error];
        self.fileURL = nil;
        self.fileHandle = nil;
    }
}

+ (id) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        SyncLogger *obj = [self new];
        instance = obj;
    });
    
    return instance;
}

@end
