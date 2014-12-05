//
//  ActivityUtil.m
//  Depo
//
//  Created by Mahir on 3.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "ActivityUtil.h"
#import "MetaFile.h"

@implementation ActivityUtil

+ (void) enrichTitleForActivity:(Activity *) activity {
    activity.title = activity.name;
    
    @try {
        NSMutableString *keyVal = [[NSMutableString alloc] init];
        [keyVal appendString:@"RecentActivity"];
        
        if([activity.rawFileType isEqualToString:@"IMAGE"]) {
            if([activity.actionItemList count] > 1) {
                [keyVal appendString:@"MultipleImages"];
            } else {
                [keyVal appendString:@"SingleImage"];
            }
        } else if([activity.rawFileType isEqualToString:@"OTHER"]) {
            if([activity.actionItemList count] > 0) {
                MetaFile *file = [activity.actionItemList objectAtIndex:0];
                if(file.folder) {
                    if([activity.actionItemList count] > 1) {
                        [keyVal appendString:@"MultipleFolders"];
                    } else {
                        [keyVal appendString:@"SingleFolder"];
                    }
                } else {
                    if([activity.actionItemList count] > 1) {
                        [keyVal appendString:@"MultipleFiles"];
                    } else {
                        [keyVal appendString:@"SingleFile"];
                    }
                }
            }
        } else if([activity.rawFileType isEqualToString:@"AUDIO"]) {
            if([activity.actionItemList count] > 1) {
                [keyVal appendString:@"MultipleMusics"];
            } else {
                [keyVal appendString:@"SingleMusic"];
            }
        } else {
            if([activity.actionItemList count] > 1) {
                [keyVal appendString:@"MultipleFiles"];
            } else {
                [keyVal appendString:@"SingleFile"];
            }
        }
        
        if([activity.rawActivityType isEqualToString:@"FAVOURITE"]) {
            [keyVal appendString:@"Favorited"];
        } else if([activity.rawActivityType isEqualToString:@"DELETED"]) {
            [keyVal appendString:@"Deleted"];
        } else if([activity.rawActivityType isEqualToString:@"MOVED"]) {
            [keyVal appendString:@"Moved"];
        } else if([activity.rawActivityType isEqualToString:@"RENAMED"]) {
            [keyVal appendString:@"Renamed"];
        } else if([activity.rawActivityType isEqualToString:@"ADDED"]) {
            [keyVal appendString:@"Added"];
        }
        
        activity.title = [NSString stringWithFormat:NSLocalizedString(keyVal, @""), [activity.actionItemList count] == 0 ? 1 : [activity.actionItemList count]];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

+ (NSMutableArray *) mergedActivityList:(NSMutableArray *) currentList withAdditionalList:(NSArray *) newList {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm"];

    for(Activity *row in newList) {
        BOOL innerAddedInside = NO;
        for(Activity *innerRow in currentList) {
            if([innerRow.rawActivityType isEqualToString:row.rawActivityType]
               && [innerRow.rawFileType isEqualToString:innerRow.rawFileType]
               && [[dateFormat stringFromDate:innerRow.date] isEqualToString:[dateFormat stringFromDate:row.date]]) {
                innerAddedInside = YES;
                if([row.actionItemList count] > 0) {
                    [innerRow.actionItemList addObjectsFromArray:row.actionItemList];
                }
                break;
            }
        }
        if(!innerAddedInside){
            [currentList addObject:row];
        }
    }
    return currentList;
}

@end
