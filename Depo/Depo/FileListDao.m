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

@synthesize parentFolderUuid;

- (void) requestFileListingForParentForPage:(int) page andSize:(int) size sortBy:(SortType) sortType {
    sortType = [self resetSortType:sortType];

    NSString *parentListingUrl = [NSString stringWithFormat:FILE_LISTING_MAIN_URL, @"", [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC" : @"DESC", page, size];
	NSURL *url = [NSURL URLWithString:parentListingUrl];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void) requestFileListingForFolder:(NSString *) folderUuid andForPage:(int) page andSize:(int) size sortBy:(SortType) sortType {
    sortType = [self resetSortType:sortType];
    self.parentFolderUuid = folderUuid;

    NSString *parentListingUrl = [NSString stringWithFormat:FILE_LISTING_MAIN_URL, folderUuid, [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC" : @"DESC", page, size];
	NSURL *url = [NSURL URLWithString:parentListingUrl];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void) requestFolderListingForFolder:(NSString *) folderUuid andForPage:(int) page andSize:(int) size sortBy:(SortType) sortType {
    sortType = [self resetSortType:sortType];
    self.parentFolderUuid = folderUuid;

    NSString *parentListingUrl = [NSString stringWithFormat:FOLDER_LISTING_MAIN_URL, folderUuid==nil ? @"" : folderUuid, [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC" : @"DESC", page, size];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
//    NSLog(@"FOLDER URL: %@", parentListingUrl);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	if (!error) {
		NSString *responseEnc = [request responseString];
		
//        NSLog(@"File Listing Response: %@", responseEnc);
        
		SBJSON *jsonParser = [SBJSON new];
		NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];

        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSDictionary *mainArray = [mainDict objectForKey:@"fileList"];
            
            NSMutableArray *result = [[NSMutableArray alloc] init];
            
            if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
                for(NSDictionary *fileDict in mainArray) {
                    MetaFile *parsedFile = [self parseFile:fileDict];
                    parsedFile.parentUuid = self.parentFolderUuid;
                    [result addObject:parsedFile];
                }
            }
            [self shouldReturnSuccessWithObject:result];
        } else {
            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
        }
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

@end
