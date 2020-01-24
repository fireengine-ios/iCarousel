//
//  AbstractHelper.m
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 14.01.2020.
//  Copyright © 2020 Valven. All rights reserved.
//

#import "AbstractHelper.h"

@implementation AbstractHelper

- (SYNCMode *)getMode {
    return nil;
}

- (NSMutableDictionary *)mergeContacts:(NSArray *)contactList{
    SYNC_Log(@"mergeContacts");
    int counter = 0;
    NSMutableDictionary *nameMap = [NSMutableDictionary new];
    for (id contact in contactList) {
        if (contact != nil && SYNC_STRING_IS_NULL_OR_EMPTY([contact displayName])) {
            SYNC_Log(@"Contact %@", [contact objectId]);

            NSString *name = [contact nameForCompare];
            if ([nameMap objectForKey:name] != nil) {
                SYNC_Log(@"Found name duplicate for : %@ %@", [[nameMap objectForKey:name][0] objectId], [contact objectId]);
                [[nameMap objectForKey:name] addObject:contact];
            } else {
                NSMutableArray *arr = [NSMutableArray new];
                [arr addObject:contact];
                [nameMap setObject:arr forKey:name];
            }

            counter++;
            if ([Utils notify:counter size:[contactList count]]) {
                if ([self getMode] == SYNCBackup) {
                    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 50 * (counter * 100 / [contactList count]) / 100];
                } else {
                    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 25 * (counter * 100 / [contactList count]) / 100];
                }
            }
        } else {
            SYNC_Log(@"Contact is null or empty");
        }
    }
    return nameMap;
}

- (NSArray *)deviceAnalyze:(NSDictionary *)nameMap firstCheck:(BOOL)firstCheck {
    NSMutableArray *finalList = [NSMutableArray new];
    NSMutableDictionary *secondMap = [NSMutableDictionary new];
    int counter = 0;
    for (id key in nameMap) {
        NSArray *contacts = [nameMap objectForKey:key];

        if ([contacts count] > 1) {
            Contact *masterContact = [self getMasterContact:contacts];
            for (Contact *contact in contacts) {
                if ([masterContact.objectId isEqualToNumber:contact.objectId]) {
                    continue;
                }
                if ([contact containsSameDevice:masterContact]) {
                    SYNC_Log(@"Name and devices are equals. Contact: %@ Master: %@", contact.objectId, masterContact.objectId);
                    [self mergeDetail:masterContact contact:contact];
                } else if ([secondMap objectForKey:contact.nameForCompare] != nil) {
                    SYNC_Log(@"Name and devices are not equals. Adding to second check. Contact: %@ Master: %@", contact.objectId, masterContact.objectId);
                    [[secondMap objectForKey:contact.nameForCompare] addObject:contact];
                } else {
                    SYNC_Log(@"Name and devices are not equals. Creating second check. Contact: %@ Master: %@", contact.objectId, masterContact.objectId);
                    NSMutableArray *arr = [NSMutableArray new];
                    [arr addObject:contact];
                    [secondMap setObject:arr forKey: [contact nameForCompare]];
                }
            }
            [self addContact:finalList contact:masterContact];
        } else if ([contacts count] == 1) {
            SYNC_Log(@"There is no duplicate for this contact. Contact: %@", [contacts[0] objectId]);
            [self addContact:finalList contact:contacts[0]];
        } else {
            SYNC_Log(@"Contact list is null");
        }

        counter++;
        if (firstCheck && [Utils notify:counter size:[nameMap count]]) {
            if ([self getMode] == SYNCBackup) {
                [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 50 + (50 * (counter * 100 / [nameMap count]) / 100)];
            } else {
                [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 25 + (25 * (counter * 100 / [nameMap count]) / 100)];
            }
        }
    }
    if ([secondMap count] > 0) {
        [finalList addObjectsFromArray:[self deviceAnalyze:secondMap firstCheck:false]];
    }
    return finalList;
}

- (void)addContact:(NSMutableArray*) finalMap contact:(Contact*)contact {
    [self setDeviceAndAddress:contact];
    [finalMap addObject:contact];
}

- (void)setDeviceAndAddress:(Contact *)contact {
    contact.devices = [self collectDifferentDevice:contact];
    contact.addresses = [self collectDifferentAddress:contact];
}

- (void)mergeDetail:(Contact*)masterContact contact:(Contact*)contact {
    [masterContact.devices addObjectsFromArray:contact.devices];
    [masterContact.addresses addObjectsFromArray:contact.addresses];
    
    if (SYNC_STRING_IS_NULL_OR_EMPTY(masterContact.company) && !SYNC_STRING_IS_NULL_OR_EMPTY(contact.company)) {
        masterContact.dirty = true;
        masterContact.company = contact.company;
    }
}

- (Contact*)getMasterContact:(NSArray*)contacts {
    Contact *masterContact = nil;
    NSInteger masterContactDeviceCount = 0;
    for (id contact in contacts) {
        if ([contacts count] == 1) {
            masterContact = [contacts objectAtIndex:0];
        } else if ([[contact devices] count] > masterContactDeviceCount && [contact defaultAccount]) {
            masterContact = contact;
            masterContactDeviceCount = [[contact devices] count];
        }
    }

    if (masterContact == nil && [contacts count] > 0) {
        masterContact = [contacts objectAtIndex:0];
    }
    return masterContact;
}

- (NSMutableArray*)collectDifferentDevice:(Contact*)masterContact {
    NSMutableArray *allDevices = [NSMutableArray new];
    [allDevices addObjectsFromArray:masterContact.devices];
    
    NSMutableArray<ContactDevice *> *devices = [NSMutableArray new];
    for (id device in allDevices) {
        BOOL add = true;
        
        if ([devices containsObject:device]) {
            add = false;
        } else {
            for (id cd in devices) {
                if (!SYNC_STRING_IS_NULL_OR_EMPTY([cd valueForCompare]) && !SYNC_STRING_IS_NULL_OR_EMPTY([device valueForCompare]) && [[cd valueForCompare] isEqualToString:[device valueForCompare]]) {
                    add = false;
                    break;
                }
            }
        }

        if (add) {
            ContactDevice *d = [device copy];
            if ([device contactId] == nil || ![masterContact.objectId isEqualToNumber:[device contactId]]) {
                masterContact.dirty = true;
                d.contactId = masterContact.objectId;
            }
            [devices addObject:d];
        }
    }
    return devices;
}

- (NSMutableArray*)collectDifferentAddress:(Contact*)masterContact {
    NSMutableArray *allAddresses = [NSMutableArray new];
    [allAddresses addObjectsFromArray:masterContact.addresses];
    
    NSMutableArray<ContactAddress *> *addresses = [NSMutableArray new];
    for (id address in allAddresses) {
        BOOL add = true;
        
        if ([addresses containsObject:address]) {
            add = false;
        } else {
            for (id cd in addresses) {
                if (!SYNC_STRING_IS_NULL_OR_EMPTY([cd valueForCompare]) && !SYNC_STRING_IS_NULL_OR_EMPTY([address valueForCompare]) && [[cd valueForCompare] isEqualToString:[address valueForCompare]]) {
                    add = false;
                    break;
                }
            }
        }

        if (add) {
            ContactAddress *d = [address copy];
            if ([address contactId] == nil || ![masterContact.objectId isEqualToNumber:[address contactId]]) {
                masterContact.dirty = true;
                d.contactId = masterContact.objectId;
            }
            [addresses addObject:d];
        }
    }
    return addresses;
}

@end
