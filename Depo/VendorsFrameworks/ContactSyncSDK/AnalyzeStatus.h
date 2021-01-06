//
//  AnalyzeStatus.h
//  ContactSyncExample
//
//  Created by Batuhan Yıldız on 02/10/2017.
//  Copyright © 2017 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"
#import "Contact.h"

typedef NS_ENUM(NSUInteger, AnalyzeResultType) {
    INITIAL,
    ANALYZE,
    CANCELLED,
    SUCCESS,
    INTERNAL_ERROR,
    ANALYZE_RESULT_ERROR_PERMISSION_ADDRESS_BOOK,
    ANALYZE_RESULT_ERROR_NETWORK
};

typedef NS_ENUM(NSUInteger, AnalyzeStateType) {
    MERGE_CONTACTS,
    DELETE_CONTACTS
};

typedef NS_ENUM(NSUInteger, AnalyzeStep) {
    ANALYZE_STEP_INITAL,
    ANALYZE_STEP_FIND_DUPLICATES,
    ANALYZE_STEP_PROCESS_DUPLICATES,
    ANALYZE_STEP_CLEAR_DUPLICATES
};

@interface AnalyzeInfo : NSObject

@property AnalyzeStateType state;
@property (strong) NSString *name;
@property (strong) NSString *localId;

- (instancetype)initWithContact:(Contact*)contact andState:(AnalyzeStateType)state;

@end

@interface AnalyzeStatus : NSObject

@property AnalyzeStep analyzeStep;
@property AnalyzeResultType status;
@property (strong) NSError *lastError;

@property NSNumber *progress;

@property (strong) NSMutableArray *mergeContacts;
@property (strong) NSMutableArray *deleteContacts;

+ (ANALYZE_INSTANCETYPE) shared;
+ (void)handleNSError:(NSError*)error;
- (void)reset;

- (NSString*)resultTypeToString:(AnalyzeResultType) type;
@end
