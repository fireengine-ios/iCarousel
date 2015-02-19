//
//  ContactUtil.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "ContactUtil.h"
#import "SyncSettings.h"
#import <AddressBook/AddressBook.h>

@interface ContactUtil ()

@property ABAddressBookRef addressBook;

@end

@implementation ContactUtil

+ (SYNC_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

/**
 * This method must be called first in order to hold a reference to address book.
 * If user does not grant access permission to address book, other commands won't be available
 * to use
 */
-(void)checkAddressbookAccess:(void(^)(BOOL))callback{
    CFErrorRef error = nil;
    
    // Request authorization to Address Book
    _addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                callback(YES);
            } else {
                _addressBook = nil;
                callback(NO);
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        callback(YES);
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
        _addressBook = nil;
        callback(NO);
    }
}
- (Contact*)findDuplicate:(Contact*)contact cache:(NSMutableArray*)localContacts
{
    NSUInteger size = [localContacts count];
    for ( int i = 0; i < size; i++ )
    {
        Contact *c = [localContacts objectAtIndex:i];
        if ([c preEqualCheck:contact]){
            //pre check passed, continue further investigation
            [self fetchNumbers:c];
            [self fetchEmails:c];
            if ([c isEqual:contact]){
                return c;
            }
        }
    }
//    CFRelease(allPeople);
    return nil;
}
- (BOOL)deleteContact:(NSNumber*)objectId
{
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(_addressBook, [objectId intValue]);
    if (record == NULL){
        //it does not exist
        SYNC_Log(@"Record already does not exist : %@", objectId);
        return YES;
    }
    CFErrorRef error;
    BOOL result = ABAddressBookRemoveRecord (_addressBook,record,&error); //remove it
    if(result) { //if successful removal
        result = ABAddressBookSave(_addressBook, &error); //save address book state
        if(!result) {
            SYNC_Log(@"Couldn't save after delete : %@ %@", objectId, error);
        }
    } else {
        SYNC_Log(@"Couldn't delete : %@ %@", objectId, error);
    }
    
    return result;
}
- (void)deleteContact:(NSNumber*)contactId devices:(NSArray*)devices
{
    if (SYNC_NUMBER_IS_NULL_OR_ZERO(contactId)){
        SYNC_Log(@"Invalid record id : %@", contactId);
        return;
    }
    if (SYNC_ARRAY_IS_NULL_OR_EMPTY(devices)){
        SYNC_Log(@"Nothing to delete : %@", devices);
        return;
    }
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(_addressBook, [contactId intValue]);
    if (record == nil){
        SYNC_Log(@"!!! CONTACT ID NOT FOUND IN ADDRESS BOOK %@",contactId);
        return;
    }
    
    NSMutableSet *phoneIdSet = [NSMutableSet new];
    NSMutableSet *emailIdSet = [NSMutableSet new];
    for (ContactDevice *device in devices){
        NSString *key = [NSString stringWithFormat:@"%@-%@",device.value, [device deviceTypeLabel]];
        if ([device isKindOfClass:[ContactPhone class]]){
            [phoneIdSet addObject:key];
        } else {
            [emailIdSet addObject:key];
        }
    }
    
    ABMutableMultiValueRef phoneNumbers = ABMultiValueCreateMutableCopy(ABRecordCopyValue(record, kABPersonPhoneProperty));
    ABMutableMultiValueRef emails = ABMultiValueCreateMutableCopy(ABRecordCopyValue(record, kABPersonEmailProperty));
    
    for(CFIndex i=0;i<ABMultiValueGetCount(phoneNumbers);i++) {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        CFStringRef phoneTypeRef = ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
        
        NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
        NSString *type = (__bridge NSString *) phoneTypeRef;
        
        NSString *key = [NSString stringWithFormat:@"%@-%@",phoneNumber, type];
        
        CFRelease(phoneNumberRef);
        CFRelease(phoneTypeRef);
        
        if ([phoneIdSet containsObject:key])
            ABMultiValueRemoveValueAndLabelAtIndex(phoneNumbers, i);
    }
    for(CFIndex i=0;i<ABMultiValueGetCount(emails);i++) {
        CFStringRef emailAddressRef = ABMultiValueCopyValueAtIndex(emails, i);
        CFStringRef emailTypeRef = ABMultiValueCopyLabelAtIndex(emails, i);
        
        NSString *address = (__bridge NSString *) emailAddressRef;
        NSString *type = (__bridge NSString *) emailTypeRef;
        
        NSString *key = [NSString stringWithFormat:@"%@-%@",address, type];
        
        CFRelease(emailAddressRef);
        CFRelease(emailTypeRef);
        
        if ([emailIdSet containsObject:key])
            ABMultiValueRemoveValueAndLabelAtIndex(emails, i);
    }
    
    CFRelease(phoneNumbers);
    CFRelease(emails);
    
    CFErrorRef error;
    BOOL success = ABAddressBookSave(_addressBook, &error);
    if (!success){
        SYNC_Log(@"En error occurred while deleting contact devices : %@",error);
    }
}
- (void)save:(Contact*)contact
{
    ABRecordRef record=nil;
    BOOL isNew = NO;
    if (contact.recordRef){
        record = contact.recordRef;
    } if (SYNC_NUMBER_IS_NULL_OR_ZERO(contact.objectId)){
        record = ABPersonCreate();
        isNew = YES;
    } else {
        record = ABAddressBookGetPersonWithRecordID(_addressBook, [contact.objectId intValue]);
        if (record == nil){
            SYNC_Log(@"!!! CONTACT HAS ID BUT NOT FOUND IN ADDRESS BOOK %@ %@ %@",contact.objectId, contact.firstName, contact.lastName);
            record = ABPersonCreate();
            isNew = YES;
        }
    }
    
    ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFStringRef)contact.firstName, nil);
    ABRecordSetValue(record, kABPersonMiddleNameProperty, (__bridge CFStringRef)contact.middleName, nil);
    ABRecordSetValue(record, kABPersonLastNameProperty, (__bridge CFStringRef)contact.lastName, nil);
    
    ABMutableMultiValueRef phoneNumbers = nil;
    ABMutableMultiValueRef emails = nil;
    if (isNew){
        phoneNumbers = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        emails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    } else {
        phoneNumbers = ABMultiValueCreateMutableCopy(ABRecordCopyValue(contact.recordRef, kABPersonPhoneProperty));
        emails = ABMultiValueCreateMutableCopy(ABRecordCopyValue(contact.recordRef, kABPersonEmailProperty));
    }
    
    if (!SYNC_ARRAY_IS_NULL_OR_EMPTY(contact.devices)){
        for (ContactDevice *device in contact.devices){
            if ([device isKindOfClass:[ContactEmail class]]){
                ABMultiValueAddValueAndLabel(emails, (__bridge CFStringRef)device.value, [device deviceTypeLabel], NULL);
            } else {
                ABMultiValueAddValueAndLabel(phoneNumbers, (__bridge CFStringRef)device.value, [device deviceTypeLabel], NULL);
            }
        }
    }
    ABRecordSetValue(record, kABPersonPhoneProperty, phoneNumbers, nil);
    ABRecordSetValue(record, kABPersonEmailProperty, emails, nil);
    
    CFErrorRef error;
    BOOL success = NO;
    if (isNew){
        if (ABAddressBookAddRecord(_addressBook, record, &error)){
            success = ABAddressBookSave(_addressBook, &error);
        }
    } else {
        success = ABAddressBookSave(_addressBook, &error);
    }
    if (!success){
        SYNC_Log(@"En error occurred while saving contact : %@",error);
    } else {
        if (isNew){
            ABRecordID recordId = ABRecordGetRecordID(record);
            contact.objectId = [NSNumber numberWithInt:recordId];
        }
    }
    if (!isNew){
        CFRelease(phoneNumbers);
        CFRelease(emails);
    }
}

- (Contact*)findContactById:(NSNumber*)objectId
{
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(_addressBook, [objectId intValue]);
    if (record == NULL){
        return nil;
    }
    Contact *contact = [[Contact alloc] initWithRecordRef:record];
    return contact;
}

- (NSNumber*)localUpdateDate:(NSNumber*)objectId
{
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(_addressBook, [objectId intValue]);
    if (record == NULL){
        return nil;
    }
    NSDate *lastModif=(__bridge NSDate *)(ABRecordCopyValue(record,kABPersonModificationDateProperty));
    
    return SYNC_DATE_AS_NUMBER(lastModif);
}

- (NSMutableArray*)fetchContacts
{
    NSMutableArray *ret = [NSMutableArray new];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( _addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( _addressBook );
    
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        Contact *contact = [[Contact alloc] initWithRecordRef:ref];
        //we must have either firstname or lastname, otherwise contact cannot be saved on server
        if (!SYNC_STRING_IS_NULL_OR_EMPTY(contact.firstName) || !SYNC_STRING_IS_NULL_OR_EMPTY(contact.lastName)){
            [ret addObject:contact];
        }
    }
    CFRelease(allPeople);
    return ret;
}

- (void)fetchNumbers:(Contact*)contact
{
    ABMultiValueRef multiPhones = ABRecordCopyValue(contact.recordRef, kABPersonPhoneProperty);
    for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
        CFStringRef phoneTypeRef = ABMultiValueCopyLabelAtIndex(multiPhones, i);
        
        NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
        NSString *type = (__bridge NSString *) phoneTypeRef;
        
        CFRelease(phoneNumberRef);
        CFRelease(phoneTypeRef);

        SYNC_Log(@"%@ %@ phone :%@ %@", contact.firstName, contact.lastName, phoneNumber, type);
        
        [contact.devices addObject:[[ContactPhone alloc] initWithValue:phoneNumber andType:type]];
        
    }
    CFRelease(multiPhones);
}
- (void)fetchEmails:(Contact*)contact
{
    ABMultiValueRef multiEmails = ABRecordCopyValue(contact.recordRef, kABPersonEmailProperty);
    
    for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
        CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
        CFStringRef emailTypeRef = ABMultiValueCopyLabelAtIndex(multiEmails, i);
        
        NSString *mailAddress = (__bridge NSString *) emailRef;
        NSString *type = (__bridge NSString *) emailTypeRef;
        
        CFRelease(emailRef);
        CFRelease(emailTypeRef);
        
        SYNC_Log(@"%@ %@ email :%@ %@", contact.firstName, contact.lastName, mailAddress, type);
        
        [contact.devices addObject:[[ContactEmail alloc] initWithValue:mailAddress andType:type]];
    }
    CFRelease(multiEmails);
}

+ (NSString*)clearMsisdn:(NSString*)input
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[ ()-]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *str = regex == nil ? input : [regex stringByReplacingMatchesInString:input options:0 range:NSMakeRange(0, [input length]) withTemplate:@""];
    if ([str hasPrefix:@"+"]){
        return str;
    } else if ([str hasPrefix:@"00"]){
        return [NSString stringWithFormat:@"+%@", [str substringFromIndex:2]];
    } else if ([str hasPrefix:@"0"]){
        return [NSString stringWithFormat:@"+9%@", str];
    } else {
        return [NSString stringWithFormat:@"+90%@", str];
    }
}

@end
