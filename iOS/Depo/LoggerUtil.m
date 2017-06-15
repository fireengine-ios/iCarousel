//
//  LoggerUtil.m
//  Depo
//
//  Created by Mahir Tarlan on 11/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "LoggerUtil.h"

@implementation LoggerUtil

+ (void) logString:(NSString *)text {
    @synchronized(self) {
        text = [NSString stringWithFormat:@"%@ %@\n", [LoggerUtil getLogTimestamp], text];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"iglogs.log"];
        if([[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:logPath error:nil] fileSize];
            if(fileSize < 1024*50) {
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
            } else {
                NSString* fileContents = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
                NSArray *lineArray = [fileContents componentsSeparatedByString:@"\n"];
                
                double lineCountToDelete = floor(lineArray.count/2);
                double remainingLength = lineArray.count - lineCountToDelete;
                
                NSArray *finalArray = [lineArray subarrayWithRange:NSMakeRange(lineCountToDelete, remainingLength)];
                
                NSString *finalLogs = [finalArray componentsJoinedByString:@"\n"];
                finalLogs = [NSString stringWithFormat:@"%@\n%@\n", finalLogs, text];
                [finalLogs writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        } else {
            [text writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}

+ (NSString *) getLogTimestamp {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    return [dateFormat stringFromDate:[NSDate date]];
}

@end
