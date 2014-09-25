//
//  FileListDao.m
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FileListDao.h"
#import "AppUtil.h"

@implementation FileListDao

- (void) requestFileListingForParentForOffset:(int) offset andSize:(int) size {
    NSString *parentListingUrl = [NSString stringWithFormat:FILE_LISTING_MAIN_URL, @"parent", @"", @"name", offset, size];
	NSURL *url = [NSURL URLWithString:parentListingUrl];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void) requestFileListingForFolder:(NSString *) folder andForOffset:(int) offset andSize:(int) size {
    NSString *parentListingUrl = [NSString stringWithFormat:FILE_LISTING_MAIN_URL, @"parent", [self enrichFileFolderName:folder], @"name", offset, size];
	NSURL *url = [NSURL URLWithString:parentListingUrl];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void) requestPhotosForOffset:(int) offset andSize:(int) size {
    NSString *parentListingUrl = [NSString stringWithFormat:IMG_LISTING_MAIN_URL, @"content_type", @"image", @"last_modified", offset, size];
	NSURL *url = [NSURL URLWithString:parentListingUrl];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	if (!error) {
		NSString *responseEnc = [request responseString];
		
        NSLog(@"File Listing Response: %@", responseEnc);
        
		SBJSON *jsonParser = [SBJSON new];
		NSArray *mainArray = [jsonParser objectWithString:responseEnc];
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
            for(NSDictionary *fileDict in mainArray) {
                [result addObject:[self parseFile:fileDict]];
            }
        }
        
        [self shouldReturnSuccessWithObject:result];
		
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

- (MetaFile *) parseFile:(NSDictionary *) dict {
    NSString *hash = [dict objectForKey:@"hash"];
    NSString *subdir = [dict objectForKey:@"subdir"];
    NSString *parent = [dict objectForKey:@"parent"];
    NSString *name = [dict objectForKey:@"name"];
    NSNumber *bytes = [dict objectForKey:@"bytes"];
    NSNumber *folder = [dict objectForKey:@"folder"];
    NSNumber *hidden = [dict objectForKey:@"hidden"];
    NSString *path = [dict objectForKey:@"path"];
    NSString *url = [dict objectForKey:@"url"];
    NSString *tempDownloadURL = [dict objectForKey:@"tempDownloadURL"];
    NSString *last_modified = [dict objectForKey:@"last_modified"];
    NSString *content_type = [dict objectForKey:@"content_type"];
    
    MetaFile *file = [[MetaFile alloc] init];
    file.hash = [self strByRawVal:hash];
    file.subDir = [self strByRawVal:subdir];
    file.parent = [self strByRawVal:parent];
    file.name = [self strByRawVal:name];
    file.bytes = [self longByNumber:bytes];
    file.folder = [self boolByNumber:folder];
    file.hidden = [self boolByNumber:hidden];
    file.path = [self strByRawVal:path];
    file.url = [self strByRawVal:url];
    file.tempDownloadUrl = [self strByRawVal:tempDownloadURL];
    file.lastModified = [self dateByRawVal:last_modified];
    file.rawContentType = [self strByRawVal:content_type];
    file.contentType = [self contentTypeByRawValue:file];
    file.visibleName = [AppUtil nakedFileFolderName:file.name];
    return file;
}

@end
