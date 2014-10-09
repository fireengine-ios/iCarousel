//
//  FileListDao.m
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FileListDao.h"
#import "AppUtil.h"
#import "FileDetail.h"

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

@end
