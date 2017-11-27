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

@property (strong) NSMutableArray* records;
@property (strong) NSMutableArray* objectIds;
 
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

- (void) reset {
    self.records = [NSMutableArray new];
    self.objectIds = [NSMutableArray new];
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
        
        
        if(phoneNumberRef != nil)
            CFRelease(phoneNumberRef);
        if(phoneTypeRef != nil)
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
        
        if(emailAddressRef != nil)
            CFRelease(emailAddressRef);
        if(emailTypeRef != nil)
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

- (NSMutableArray *)applyContacts{
    CFErrorRef error;
    bool success = false;
    success = ABAddressBookSave(_addressBook, &error);
    if (!success){
        SYNC_Log(@"En error occurred while saving contacts : %@",error);
    }
    else{
        _objectIds = [NSMutableArray new];
        NSUInteger recordCount = [_records count];
        for (NSUInteger i=0; i<recordCount; i++){
            ABRecordRef record = (__bridge  ABRecordRef)[_records objectAtIndex:i];
            ABRecordID recordId = ABRecordGetRecordID(record);
            NSString *recordIdString = [NSString stringWithFormat:@"%d",recordId];
            
            [_objectIds addObject:recordIdString];
        }
    
    }

    return _objectIds;  // If not success then it will return nil. Check it to understand errors.
}

- (void)save:(Contact*)contact
{
    if(SYNC_IS_NULL(_records)){
        _records = [NSMutableArray new];
    }
    
    ABRecordRef record=nil;
    BOOL isNew = NO;
    if (contact.recordRef){
        record = contact.recordRef;
    }
    if (SYNC_NUMBER_IS_NULL_OR_ZERO(contact.objectId)){
        record = ABPersonCreate();
        isNew = YES;
    } else {
        record = ABAddressBookGetPersonWithRecordID(_addressBook, [contact.objectId intValue]);
        if (record == nil){
            SYNC_Log(@"!!! CONTACT HAS ID BUT NOT FOUND IN ADDRESS BOOK %@",contact.objectId);
            record = ABPersonCreate();
            isNew = YES;
        }
    }
    
    ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFStringRef)contact.firstName, nil);
    ABRecordSetValue(record, kABPersonMiddleNameProperty, (__bridge CFStringRef)contact.middleName, nil);
    ABRecordSetValue(record, kABPersonNicknameProperty, (__bridge CFStringRef)contact.nickName, nil);
    ABRecordSetValue(record, kABPersonLastNameProperty, (__bridge CFStringRef)contact.lastName, nil);
    
    ABMutableMultiValueRef phoneNumbers = nil;
    ABMutableMultiValueRef emails = nil;
    phoneNumbers = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    emails = ABMultiValueCreateMutable(kABMultiStringPropertyType);

    
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
    
    if (isNew){
        CFErrorRef error;
        BOOL success = NO;
        success = ABAddressBookAddRecord(_addressBook, record, &error);
        if (!success){
            SYNC_Log(@"En error occurred while adding contact : %@",error);
        } else {
            ABRecordID recordId = ABRecordGetRecordID(record);
            //SYNC_Log(@"Record Id: %d", recordId);
            contact.objectId = [NSNumber numberWithInt:recordId];
        }
        
    }
    
    [_records addObject:(__bridge id)record];
    
    if(phoneNumbers != nil)
        CFRelease(phoneNumbers);
    if(emails != nil)
        CFRelease(emails);
    if(record != nil)
        CFRelease(record);
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

        NSString *displayName = contact.generateDisplayName;
        if(!SYNC_STRING_IS_NULL_OR_EMPTY(displayName) && displayName.length > 1000){
            continue;
        }
        
        if (!SYNC_STRING_IS_NULL_OR_EMPTY(contact.firstName) || !SYNC_STRING_IS_NULL_OR_EMPTY(contact.middleName) || !SYNC_STRING_IS_NULL_OR_EMPTY(contact.lastName) || !SYNC_STRING_IS_NULL_OR_EMPTY(contact.nickName)){
            contact.hasName = YES;
        } else {
            contact.hasName = NO;
        }
        [ret addObject:contact];
    }
    CFRelease(allPeople);
    return ret;
}

- (NSInteger)getContactCount
{
    CFIndex nPeople = ABAddressBookGetPersonCount( _addressBook );
    return nPeople;
}

- (void)printContacts
{
    if (!SYNC_Log_Enabled) {
        return;
    }
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( _addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( _addressBook );
    
    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        
        NSNumber *objectId = [NSNumber numberWithInt:ABRecordGetRecordID(ref)];
        
        NSDate *lastModif=(__bridge NSDate *)(ABRecordCopyValue(ref,kABPersonModificationDateProperty));

        SYNC_Log(@"%@ => %@ / %@", objectId, lastModif, SYNC_DATE_AS_NUMBER(lastModif));
    }
    CFRelease(allPeople);
}

- (void)fetchNumbers:(Contact*)contact
{
    contact.hasPhoneNumber = NO;
    
    ABMultiValueRef multiPhones = ABRecordCopyValue(contact.recordRef, kABPersonPhoneProperty);
    CFIndex cfCount = ABMultiValueGetCount(multiPhones);
    for(CFIndex i=0;i<cfCount;i++) {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
        CFStringRef phoneTypeRef = ABMultiValueCopyLabelAtIndex(multiPhones, i);
        
        NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
        NSString *type = (__bridge NSString *) phoneTypeRef;
        
        CFRelease(phoneNumberRef);

        if (phoneTypeRef==NULL || type==nil){
            type = (__bridge NSString *)kABOtherLabel;
        } else {
            CFRelease(phoneTypeRef);
        }
        
        
        ContactPhone *phone = (ContactPhone *)[[ContactPhone alloc] initWithValue:phoneNumber andType:type];
        if (![self isAdded:contact value:phone] && !SYNC_STRING_IS_NULL_OR_EMPTY(phoneNumber) && phoneNumber.length <= 255) {
            SYNC_Log(@"phone : %@", type);
            contact.hasPhoneNumber = YES;
            [contact.devices addObject:phone];
        }

    }
    if (multiPhones!=NULL) {
        CFRelease(multiPhones);
    }
}

- (void)fetchEmails:(Contact*)contact
{
    ABMultiValueRef multiEmails = ABRecordCopyValue(contact.recordRef, kABPersonEmailProperty);
    CFIndex cfCount = ABMultiValueGetCount(multiEmails);
    for (CFIndex i=0; i<cfCount; i++) {
        CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
        CFStringRef emailTypeRef = ABMultiValueCopyLabelAtIndex(multiEmails, i);
        
        NSString *mailAddress = (__bridge NSString *) emailRef;
        NSString *type = (__bridge NSString *) emailTypeRef;
        
        CFRelease(emailRef);
        if (emailTypeRef==NULL || type==nil){
            type = (__bridge NSString *)kABOtherLabel;
        } else {
            CFRelease(emailTypeRef);
        }
        
        ContactEmail *newMail = [[ContactEmail alloc] initWithValue:mailAddress andType:type];
        if (![self isAdded:contact value:newMail] && !SYNC_STRING_IS_NULL_OR_EMPTY(mailAddress) && mailAddress.length <= 255) {
            SYNC_Log(@"email : %@", type);
            [contact.devices addObject:newMail];
        }
    }
    if (multiEmails!=NULL) {
        CFRelease(multiEmails);
    }
}
-(BOOL)isAdded:(Contact*)contact value:(ContactDevice*)newValue{
    if (contact.devices.count==0) {
        return NO;
    }
    
    if ([contact.devices containsObject:newValue]) {
        return YES;
    }else{
        return NO;
    }
}
+ (NSString*)clearMsisdn:(NSString*)input
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[ ()-]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *str = regex == nil ? input : [regex stringByReplacingMatchesInString:input options:0 range:NSMakeRange(0, [input length]) withTemplate:@""];
     NSMutableString *ptr=[[NSMutableString alloc ]init];
    for (int i=0; i< [str length]; i++) {
       
        if ([str characterAtIndex:i]<127) {
            [ptr appendFormat:@"%c",[str characterAtIndex:i]];
        }
    }
    str = [ptr copy];
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
