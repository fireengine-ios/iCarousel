//
//  RestoreHelper.m
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 15.01.2020.
//  Copyright © 2020 Valven. All rights reserved.
//

#import "RestoreHelper.h"

@implementation RestoreHelper

- (SYNCMode *)getMode {
    return SYNCRestore;
}

- (void)startAnalyze:(NSDictionary *)remoteContacts {
    SYNC_Log(@"Remote contact size: %zd", [remoteContacts count]);
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 0];
          
    NSArray *defaultContacts = [NSArray arrayWithArray:[[self getLocalDefaultContacts] allValues]];
    SYNC_Log(@"Default contact size: %ld", defaultContacts.count);

    NSArray *mergedDefaultContacts = [self deviceAnalyze:[self mergeContacts:defaultContacts] firstCheck:true];
    SYNC_Log(@"Merged default contact size: %ld", mergedDefaultContacts.count);

    NSMutableArray *mergedLocalContacts = [NSMutableArray new];
    for (Contact *c in mergedDefaultContacts) {
      if (c.dirty) {
          [mergedLocalContacts addObject:c];
      }
    }
    [self save:mergedLocalContacts];
    SYNC_Log(@"Merged contacts: %ld", mergedLocalContacts.count);

    NSDictionary *map = [self compareContacts:remoteContacts];
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 60];

    NSMutableArray *newContacts = [map objectForKey:@"create"];
    SYNC_Log(@"New contacts: %ld", newContacts.count);
    [self save:newContacts];
    SYNC_Log(@"Contacts saved");
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 80];
    
    NSMutableArray *updateContacts = [map objectForKey:@"update"];
    SYNC_Log(@"Update contacts: %ld", updateContacts.count);
    [self save:updateContacts];
    SYNC_Log(@"Contacts updated");
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 90];

    NSMutableArray *deleteContacts = [self getDeletedContacts:defaultContacts mergedDefaultContacts:mergedDefaultContacts];
    SYNC_Log(@"Delete default contacts: %ld", deleteContacts.count);
    [[ContactUtil shared] deleteContacts:deleteContacts];
    SYNC_Log(@"Contacts removed");
    
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 100];
}

- (NSDictionary*)compareContacts:(NSDictionary*)remoteContacts {
    NSMutableDictionary *map = [NSMutableDictionary new];

    NSMutableArray *newContacts = [NSMutableArray new];
    NSMutableArray *updateContacts = [NSMutableArray new];

    NSDictionary *localContacts = [self getLocalContacts];
    for (id key in remoteContacts) {
        NSArray* remoteCs = [remoteContacts objectForKey:key];
        SYNC_Log(@"Checking remoteContacts %@", [[remoteCs valueForKey:@"description"] componentsJoinedByString:@"-"]);
        
        NSArray *localCs = [localContacts objectForKey:key];
        if (localCs == nil) {
            for (Contact *c in remoteCs) {
                SYNC_Log(@"Contact create %@", [c objectId]);
                [[SyncStatus shared] addContact:c state:SYNC_INFO_NEW_CONTACT_ON_DEVICE];
            }
            [newContacts addObjectsFromArray:remoteCs];
        } else {
            for (Contact *remoteContact in remoteCs) {
                // 0 - no action
                // 1 - create
                // 2 - update
                int status = 1;

                for (Contact *localContact in localCs) {
                    if ([remoteContact containsSameDevice:localContact]) {
                        [self mergeDetail:localContact contact:remoteContact];
                        [self setDeviceAndAddress:localContact];
                        if (localContact.dirty) {
                            [[SyncStatus shared] addContact:remoteContact state:SYNC_INFO_UPDATED_ON_DEVICE];
                            SYNC_Log(@"Contact update %@", [localContact objectId]);
                            status = 2;
                            [updateContacts addObject:localContact];
                        } else {
                            SYNC_Log(@"Contact no action %@", [localContact objectId]);
                            status = 0;
                        }
                        break;
                    }
                }
                if (status == 1) {
                    SYNC_Log(@"Contact create %@", [remoteContact objectId]);
                    [[SyncStatus shared] addContact:remoteContact state:SYNC_INFO_NEW_CONTACT_ON_DEVICE];
                    [newContacts addObject:remoteContact];
                }
            }
        }
    }

    [map setObject:newContacts forKey:@"create"];
    [map setObject:updateContacts forKey:@"update"];
    return map;
}

-(NSMutableArray*)getDeletedContacts:(NSArray*)defaultContacts mergedDefaultContacts:(NSArray*)mergedDefaultContacts {
    NSMutableArray *deletedContacts = [NSMutableArray new];
    NSArray *mergedContactIds = [[ContactUtil shared] getContactIds:mergedDefaultContacts];
    
    for(Contact *c in defaultContacts) {
        if (![mergedContactIds containsObject:c.objectId]) {
            SYNC_Log(@"Contact delete %@", [c objectId]);
            [deletedContacts addObject:c];
            [[SyncStatus shared] addContact:c state:SYNC_INFO_DELETED_ON_DEVICE];
        }
    }
    
    return deletedContacts;
}

-(NSMutableDictionary*)getLocalDefaultContacts {
    NSMutableDictionary *contactMap = [NSMutableDictionary new];
    for (Contact *c in [[ContactUtil shared] fetchLocalContacts]) {
        [contactMap setObject:c forKey:c.objectId];
    }

    return contactMap;
}

-(NSDictionary*)getLocalContacts {
    NSMutableDictionary *resultMap = [NSMutableDictionary new];
    NSMutableArray *contacts = [[ContactUtil shared] fetchContacts];
    if ([contacts count] > 0) {
        for(Contact *c in contacts) {
            [[ContactUtil shared] fetchNumbers:c];
            [[ContactUtil shared] fetchEmails:c];
            [[ContactUtil shared] fetchAddresses:c];
            
            if (!SYNC_STRING_IS_NULL_OR_EMPTY(c.generateDisplayName)) {
                NSMutableArray *cs = [resultMap objectForKey:c.nameForCompare];
                if (cs != nil) {
                    if (c.defaultAccount) {
                        SYNC_Log(@"Default account contact %@", c.objectId);
                        [cs insertObject:c atIndex:0];
                    } else {
                        SYNC_Log(@"Differect account contact %@", c.objectId);
                        [cs addObject:c];
                    }
                } else {
                    cs = [NSMutableArray new];
                    [cs addObject:c];
                    
                    [resultMap setObject:cs forKey:c.nameForCompare];
                }
            } else {
                SYNC_Log(@"Contact has no name %@", c.objectId);
            }
        }
    }

    return resultMap;
}

-(void)save:(NSMutableArray*)contacts {
    [[ContactUtil shared] saveList:contacts];
}

@end
