//
//  ContactUtil.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "ContactUtil.h"
#import "SyncSettings.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

@interface ContactUtil ()

@property ABAddressBookRef addressBook;

@property (strong) NSMutableArray* records;
@property (strong) NSMutableArray* objectIds;
@property BOOL addressBookCopyInProgress;
 
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
//    CFErrorRef error = nil;
    
    // Request authorization to Address Book
    if (_addressBook) {
        callback(YES);
        return;
    }
    _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
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

-(NSString*)getCards:(PartialInfo*)partialInfo {
    NSMutableArray *contactsArray=[[NSMutableArray alloc] init];
    CNContactStore *store = [[CNContactStore alloc] init];
    NSMutableArray *contacts = [NSMutableArray array];

    NSError *fetchError;

    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[[CNContactVCardSerialization descriptorForRequiredKeys], [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];

    BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
        [contacts addObject:contact];
    }];
    if (!success) {
        SYNC_Log(@"error = %@", fetchError);
    }

    NSUInteger totalCount = [contacts count];
    int ok = 0;
    for (CNContact *contact in contacts) {
        ok++;
        [contactsArray addObject:contact];
        if ([Utils notify:ok size:totalCount]) {
            [[SyncStatus shared] notifyProgress:partialInfo step:SYNC_STEP_VCF progress: (90 * (ok * 100.0 / totalCount) / 100)];
            SYNC_Log(@"VCF: %d", ok);
        }
    }

    NSError *error;
    NSData *vcardString =[CNContactVCardSerialization dataWithContacts:contactsArray error:&error];

    NSString* vcardStr = [[NSString alloc] initWithData:vcardString encoding:NSUTF8StringEncoding];
    return vcardStr;
}

-(void)releaseAddressBookRef {
    if (_addressBookCopyInProgress) {
        SYNC_Log(@"%@", @"Addressbook copy in progress");
        int counter = 0;
        while (counter <= 10) {
            SYNC_Log(@"%@", @"Waiting for release");
            [NSThread sleepForTimeInterval:1.0f];
            if (!_addressBookCopyInProgress) {
                break;
            }
            counter += 1;
        }
    }
    if (_addressBook != nil){
        CFRelease(_addressBook);
        _addressBook = nil;
    }
}

-(void)fetchAddressBookRef{
    SYNC_Log(@"%@", @"Get AddressBookRef");
    CFErrorRef error = nil;
    
    if (_addressBook){
        return;
//        CFRelease(_addressBook);
    }
    SYNC_Log(@"%@", @"Addressbook released");
    // Request authorization to Address Book
    _addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                SYNC_Log(@"%@", @"AddressBookRef granted");
            } else {
                SYNC_Log(@"%@", @"AddressBookRef not granted");
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        SYNC_Log(@"%@", @"AddressBookRef kABAuthorizationStatusAuthorized");
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied){
        SYNC_Log(@"%@", @"AddressBookRef kABAuthorizationStatusDenied");
    }
}

- (void)deleteContacts:(NSMutableArray<Contact*>*) contacts{
    for (Contact *contact in contacts) {
        if (SYNC_NUMBER_IS_NULL_OR_ZERO(contact.objectId)){
            SYNC_Log(@"Invalid record id : %@", contact.objectId);
            continue;
        }

        ABRecordRef record = ABAddressBookGetPersonWithRecordID(_addressBook, [contact.objectId intValue]);
        // do not release. https://stackoverflow.com/a/1809857
        if (record == nil){
            SYNC_Log(@"!!! CONTACT ID NOT FOUND IN ADDRESS BOOK %@",contact.objectId);
            continue;
        }
        
        CFErrorRef  error = NULL;
        BOOL success = ABAddressBookRemoveRecord(_addressBook, record, &error);
        if (!success) {
            SYNC_Log(@"An error occurred while deleting contact with id: %@ with error: %@", contact.objectId, error);
        }
    }
    CFErrorRef  error = NULL;
    BOOL success = ABAddressBookSave(_addressBook, &error);
    if (!success){
        SYNC_Log(@"An error occurred while deleting contacts with error: %@", error);
    }
}

// not in use
- (void)deleteContactDevices:(NSNumber*)contactId devices:(NSArray*)devices
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
    
    if (phoneNumbers!=nil)
        CFRelease(phoneNumbers);
    if (emails!=nil)
        CFRelease(emails);
    if (record != NULL) {
        CFRelease(record);
    }
    
    CFErrorRef error;
    BOOL success = ABAddressBookSave(_addressBook, &error);
    if (!success){
        SYNC_Log(@"An error occurred while deleting contact devices : %@",error);
    }
}

// not in use
- (void)deleteContactAddresses:(NSNumber*)contactId addresses:(NSArray*)addresses
{
    if (SYNC_NUMBER_IS_NULL_OR_ZERO(contactId)){
        SYNC_Log(@"Invalid record id : %@", contactId);
        return;
    }
    if (SYNC_ARRAY_IS_NULL_OR_EMPTY(addresses)){
        SYNC_Log(@"Nothing to delete : %@", addresses);
        return;
    }
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(_addressBook, [contactId intValue]);
    if (record == nil){
        SYNC_Log(@"!!! CONTACT ID NOT FOUND IN ADDRESS BOOK %@",contactId);
        return;
    }
    
    NSMutableSet *addressSet = [NSMutableSet new];
    for (ContactAddress *address in addresses){
        NSString *key = [NSString stringWithFormat:@"%@-%@",address.addressKey, [address addressTypeLabel]];
        [addressSet addObject:key];
    }
    
    ABMutableMultiValueRef addresValues = ABMultiValueCreateMutableCopy(ABRecordCopyValue(record, kABPersonEmailProperty));
    
    for(CFIndex i=0;i<ABMultiValueGetCount(addresValues);i++) {
        CFStringRef addressRef = ABMultiValueCopyValueAtIndex(addresValues, i);
        CFStringRef addressTypeRef = ABMultiValueCopyLabelAtIndex(addresValues, i);
        
        NSDictionary *addressDict = (__bridge NSDictionary *) addressRef;
        NSString *type = (__bridge NSString *) addressTypeRef;
        
        ContactAddress *address = [[ContactAddress alloc] initWithRef:addressDict type:type contactId:contactId];
        NSString *key = [NSString stringWithFormat:@"%@-%@",address.addressKey, type];
    
        if(addressRef != nil)
            CFRelease(addressRef);
        if(addressTypeRef != nil)
            CFRelease(addressTypeRef);
        
        if ([addressSet containsObject:key])
            ABMultiValueRemoveValueAndLabelAtIndex(addresValues, i);
    }
    
    if (addresValues!=nil)
        CFRelease(addresValues);

    if (record != NULL) {
        CFRelease(record);
    }
    CFErrorRef error;
    BOOL success = ABAddressBookSave(_addressBook, &error);
    if (!success){
        SYNC_Log(@"An error occurred while deleting contact addresses : %@",error);
    }
}

- (NSMutableArray *)applyContacts:(NSInteger)syncRound{
    CFErrorRef error;
    bool success = false;
    success = ABAddressBookSave(_addressBook, &error);
    if (!success){
        SYNC_Log(@"An error occurred while saving contacts : %@",error);
    }
    else{
        if(SYNC_ARRAY_IS_NULL_OR_EMPTY(_objectIds)){
            _objectIds = [NSMutableArray new];
        }
        NSUInteger recordCount = [_records count];
        NSUInteger startIndex = syncRound * SYNC_RESTORE_THRESHOLD;
        for (NSUInteger i=startIndex; i<recordCount; i++){
            NSNumber *contactObjectId = [_records objectAtIndex:i];
            NSString *recordIdString = [NSString stringWithFormat:@"%d", [contactObjectId intValue]];
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
        // do not release. https://stackoverflow.com/a/1809857
        if (record == nil){
            SYNC_Log(@"!!! CONTACT HAS ID BUT NOT FOUND IN ADDRESS BOOK %@",contact.objectId);
            record = ABPersonCreate();
            isNew = YES;
        }
    }
    
    if(!SYNC_STRING_IS_NULL_OR_EMPTY(contact.firstName)){
        ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFStringRef)contact.firstName, nil);
    }
    if(!SYNC_STRING_IS_NULL_OR_EMPTY(contact.middleName)){
        ABRecordSetValue(record, kABPersonMiddleNameProperty, (__bridge CFStringRef)contact.middleName, nil);
    }
    if(!SYNC_STRING_IS_NULL_OR_EMPTY(contact.nickName)){
        ABRecordSetValue(record, kABPersonNicknameProperty, (__bridge CFStringRef)contact.nickName, nil);
    }
    if(!SYNC_STRING_IS_NULL_OR_EMPTY(contact.lastName)){
        ABRecordSetValue(record, kABPersonLastNameProperty, (__bridge CFStringRef)contact.lastName, nil);
    }
    if(!SYNC_STRING_IS_NULL_OR_EMPTY(contact.company)){
        ABRecordSetValue(record, kABPersonOrganizationProperty, (__bridge CFStringRef)contact.company, nil);
    }
    
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
    if(phoneNumbers != nil){
        ABRecordSetValue(record, kABPersonPhoneProperty, phoneNumbers, nil);
    }
    
    if(emails != nil){
        ABRecordSetValue(record, kABPersonEmailProperty, emails, nil);
    }
    
    ABMutableMultiValueRef addresses = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    if (!SYNC_ARRAY_IS_NULL_OR_EMPTY(contact.addresses)){
        for (ContactAddress *address in contact.addresses){
            NSMutableDictionary *dict = [NSMutableDictionary new];
            SYNC_SET_DICT_IF_NOT_NIL(dict, address.street, (__bridge NSString *)kABPersonAddressStreetKey);
            SYNC_SET_DICT_IF_NOT_NIL(dict, address.postalCode, (__bridge NSString *)kABPersonAddressZIPKey);
            SYNC_SET_DICT_IF_NOT_NIL(dict, address.district, (__bridge NSString *)kABPersonAddressStateKey);
            SYNC_SET_DICT_IF_NOT_NIL(dict, address.city, (__bridge NSString *)kABPersonAddressCityKey);
            SYNC_SET_DICT_IF_NOT_NIL(dict, address.country, (__bridge NSString *)kABPersonAddressCountryKey);
            ABMultiValueAddValueAndLabel(addresses, (__bridge CFTypeRef)(dict), [address addressTypeLabel], NULL);
        }
    }
    if(addresses != nil){
        ABRecordSetValue(record, kABPersonAddressProperty, addresses, nil);
    }
    
    NSNumber *contactObjectId = nil;
    if (isNew){
        CFErrorRef error;
        BOOL success = NO;
        success = ABAddressBookAddRecord(_addressBook, record, &error);
        if (!success){
            SYNC_Log(@"An error occurred while adding contact : %@",error);
        } else {
            ABRecordID recordId = ABRecordGetRecordID(record);
            //SYNC_Log(@"Record Id: %d", recordId);
            contact.objectId = [NSNumber numberWithInt:recordId];
            contactObjectId = [NSNumber numberWithInt:recordId];
        }
        
    } else {
        ABRecordID recordId = ABRecordGetRecordID(record);
        contactObjectId = [NSNumber numberWithInt:recordId];
    }
    
    if (contactObjectId != nil) {
        [_records addObject:contactObjectId];
    }

    if(phoneNumbers != nil)
        CFRelease(phoneNumbers);
    if(emails != nil)
        CFRelease(emails);
    if(addresses != nil)
        CFRelease(addresses);
}

- (void)saveList:(NSArray<Contact*>*)contacts
{
    int counter = 0;
    for (Contact *c in contacts){
        [self save:c];
        counter++;
        if (counter % SYNC_RESTORE_THRESHOLD == 0 || counter == [contacts count]){
            CFErrorRef error;
            bool success = false;
            success = ABAddressBookSave(_addressBook, &error);
            if (!success){
                SYNC_Log(@"An error occurred while saving contacts : %@",error);
            }
        }
    }
}

- (NSDictionary*)getContactData:(NSArray*)ids{
    NSMutableDictionary *contacts = [NSMutableDictionary new];
    for(NSNumber *contactId in ids){
        Contact *c = [self findContactById:contactId];
        [contacts setObject:c forKey:contactId];
    }
    return contacts;
}

- (Contact*)findContactById:(NSNumber*)objectId
{
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(_addressBook, [objectId intValue]);
    // do not release. https://stackoverflow.com/a/1809857
    if (record == NULL){
        return nil;
    }
    Contact *contact = [[Contact alloc] initWithRecordRef:record];
    [self fetchNumbers:contact ref:record];
    [self fetchEmails:contact ref:record];
    [self fetchAddresses:contact ref:record];
    return contact;
}

- (NSNumber*)localUpdateDate:(NSNumber*)objectId
{
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(_addressBook, [objectId intValue]);
    // do not release. https://stackoverflow.com/a/1809857
    if (record == NULL){
        return nil;
    }
    NSDate *lastModif=(__bridge NSDate *)(ABRecordCopyValue(record,kABPersonModificationDateProperty));
    return SYNC_DATE_AS_NUMBER(lastModif);
}

// not in use
- (void) printDefaultSource {
    CFTypeRef defaultSourceRef = ABAddressBookCopyDefaultSource(_addressBook);
    CFTypeRef defaultSourceNameRef = ABRecordCopyValue(defaultSourceRef, kABSourceNameProperty);
    CFTypeRef defaultSourceTypeRef = ABRecordCopyValue(defaultSourceRef, kABSourceTypeProperty);
    
    NSString *defaultSourceName = (__bridge NSString *) defaultSourceNameRef;
    NSNumber *defaultSourceType = (__bridge NSNumber *) defaultSourceTypeRef;
    
    SYNC_Log(@"Default - Source name: %@ Source type: %@", defaultSourceName, defaultSourceType);
    
    if (defaultSourceNameRef != NULL) {
        CFRelease(defaultSourceNameRef);
    }
    if (defaultSourceTypeRef != NULL) {
        CFRelease(defaultSourceTypeRef);
    }
    if (defaultSourceRef != NULL) {
        CFRelease(defaultSourceRef);
    }
}

// not in use
- (NSMutableArray*)getDefaultSources
{
    [self fetchAddressBookRef];
    [self printDefaultSource];
    
    NSMutableArray *resp = [NSMutableArray new];
    
    CFTypeRef sourcesRef = ABAddressBookCopyArrayOfAllSources(_addressBook);
    NSArray *sources = (__bridge NSArray *)(sourcesRef);
    
    for (id source in sources) {
        ABRecordRef sourceRef = (__bridge ABRecordRef)(source);
        
        CFTypeRef sourceNameRef = ABRecordCopyValue(sourceRef, kABSourceNameProperty);
        CFTypeRef sourceTypeRef = ABRecordCopyValue(sourceRef, kABSourceTypeProperty);
        
        NSString *sourceName = (__bridge NSString *) sourceNameRef;
        NSNumber *sourceType = (__bridge NSNumber *) sourceTypeRef;
        
        int sourceTypeValue = [sourceType intValue];
        if (sourceTypeValue == kABSourceTypeLocal || sourceTypeValue == kABSourceTypeCardDAV) {
            SYNC_Log(@"Add - Source name: %@ Source type: %@ ", sourceName, sourceType);
            [resp addObject:source];
        }else{
            SYNC_Log(@"Ignore - Source name: %@ Source type: %@ ", sourceName, sourceType);
        }
        
        if (sourceNameRef != NULL) {
            CFRelease(sourceNameRef);
        }
        if (sourceTypeRef != NULL) {
            CFRelease(sourceTypeRef);
        }
    }
    
//    if (sourcesRef != nil) {
//        CFRelease(sourcesRef);
//    }
    return resp;
}

- (NSMutableArray*)fetchLocalContacts
{
    NSMutableArray *contacts = [self fetchContacts];
    NSMutableArray *localContacts = [NSMutableArray new];
    for (Contact *c in contacts) {
        if (c.defaultAccount) {
            [localContacts addObject:c];
        }
    }
    return localContacts;
    
    // do not remove for now
//    NSMutableArray *ret = [NSMutableArray new];
//    for(id source in [self getDefaultSources]){
//        CFTypeRef sourceRef = (__bridge CFTypeRef) source;
//        if (sourceRef == NULL) {
//            SYNC_Log(@"Source reference is not found!!!");
//            continue;
//        }
//        CFArrayRef sourceContacts = ABAddressBookCopyArrayOfAllPeopleInSource(_addressBook, sourceRef);
//        CFTypeRef sourceNameRef = ABRecordCopyValue(sourceRef, kABSourceNameProperty);
//
//        NSString *sourceName = (__bridge NSString *) sourceNameRef;
//        CFIndex contactLength = CFArrayGetCount(sourceContacts);
//
//        SYNC_Log(@"Source name: %@ Count: %ld ", sourceName, (long)contactLength);
//        for ( int i = 0; i < contactLength; i++ ) {
//            ABRecordRef ref = CFArrayGetValueAtIndex(sourceContacts, i);
//            Contact *contact = [[Contact alloc] initWithRecordRef:ref];
////            CFRetain(ref);
//
//            NSString *displayName = contact.generateDisplayName;
//            if(!SYNC_STRING_IS_NULL_OR_EMPTY(displayName) && displayName.length > 1000){
//                continue;
//            }
//
//            if (!SYNC_STRING_IS_NULL_OR_EMPTY(contact.firstName) || !SYNC_STRING_IS_NULL_OR_EMPTY(contact.middleName) || !SYNC_STRING_IS_NULL_OR_EMPTY(contact.lastName) || !SYNC_STRING_IS_NULL_OR_EMPTY(contact.nickName)){
//                contact.hasName = YES;
//            } else {
//                contact.hasName = NO;
//            }
//
//            [self fetchNumbers:contact];
//            [self fetchEmails:contact];
//            [self fetchAddresses:contact];
//
//            [ret addObject:contact];
//
////            if (ref != NULL) {
////                CFRelease(ref);
////            }
//        }
//
//        if (sourceNameRef != NULL) {
//            CFRelease(sourceNameRef);
//        }
//        if (sourceContacts != NULL) {
//            CFRelease(sourceContacts);
//        }
//        if (sourceRef != NULL) {
//            CFRelease(sourceRef);
//        }
//    }
//    return ret;
}

// not in use
- (NSMutableArray*)fetchContactIds
{
    [self fetchAddressBookRef];
    NSMutableArray *ret = [NSMutableArray new];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( _addressBook );
    CFIndex nPeople = CFArrayGetCount(allPeople);

    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i);
        NSNumber *cid = [NSNumber numberWithInt:ABRecordGetRecordID(ref)];
        [ret addObject:cid];
    }
    if (allPeople!=nil)
        CFRelease(allPeople);
    return ret;
}

- (NSMutableArray*)fetchContacts{
    return [self fetchContacts:-1 offset:-1];
}

- (NSMutableArray*)fetchContacts:(NSInteger)bulkCount offset:(NSInteger)offset
{
    [self fetchAddressBookRef];
    NSMutableArray *ret = [NSMutableArray new];
    if (!_addressBook) {
        return ret;
    }
    _addressBookCopyInProgress = true;
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( _addressBook );
    _addressBookCopyInProgress = false;
    CFIndex nPeople = CFArrayGetCount(allPeople);

    NSInteger index = (offset != -1 ? offset: 0);

    SYNC_Log(@"bulkCount %zd offset %zd index %zd npeople %zd", bulkCount, offset, index, nPeople)
    for ( ; index < nPeople; index++ )
    {
        if (offset > -1 && bulkCount > 0 && index == (bulkCount + offset)){
            break;
        }
        if (!_addressBook) {
            break;
        }
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, index );
        // do not release. https://stackoverflow.com/a/43715622
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
        [self fetchNumbers:contact ref:ref];
        [self fetchEmails:contact ref:ref];
        [self fetchAddresses:contact ref:ref];
        [ret addObject:contact];
    }
    if (allPeople!=nil)
        CFRelease(allPeople);
    return ret;
}

- (NSInteger)getContactCount
{
    // do not use fetchAddressBookRef
//    [self fetchAddressBookRef];
    CFIndex nPeople = ABAddressBookGetPersonCount( _addressBook );
    return nPeople;
}

- (void)printContacts
{
    [self fetchAddressBookRef];
    if (!SYNC_Log_Enabled) {
        return;
    }
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( _addressBook );
    CFIndex nPeople = CFArrayGetCount(allPeople);

    for ( int i = 0; i < nPeople; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        // do not release https://stackoverflow.com/a/43715622
        
        NSNumber *objectId = [NSNumber numberWithInt:ABRecordGetRecordID(ref)];
        
        NSDate *lastModif=(__bridge NSDate *)(ABRecordCopyValue(ref,kABPersonModificationDateProperty));

        SYNC_Log(@"%@ => %@ / %@", objectId, lastModif, SYNC_DATE_AS_NUMBER(lastModif));
    }
    if (allPeople!=nil)
        CFRelease(allPeople);
}

- (void)fetchNumbers:(Contact*)contact ref:(ABRecordRef )ref
{
    contact.hasPhoneNumber = NO;
    
    ABMultiValueRef multiPhones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
    CFIndex cfCount = ABMultiValueGetCount(multiPhones);
    for(CFIndex i=0;i<cfCount;i++) {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
        CFStringRef phoneTypeRef = ABMultiValueCopyLabelAtIndex(multiPhones, i);
        
        NSString *phoneNumber = (NSString *) CFBridgingRelease(phoneNumberRef);
        NSString *type = (NSString *) CFBridgingRelease(phoneTypeRef);
        
        if (phoneTypeRef==NULL || type==nil){
            type = (__bridge NSString *)kABOtherLabel;
        }
        
        ContactPhone *phone = (ContactPhone *)[[ContactPhone alloc] initWithValue:phoneNumber andType:type contactId:contact.objectId];
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

- (void)fetchNumbers:(Contact*)contact
{
    contact.hasPhoneNumber = NO;
    
    ABMultiValueRef multiPhones = ABRecordCopyValue(contact.recordRef, kABPersonPhoneProperty);
    CFIndex cfCount = ABMultiValueGetCount(multiPhones);
    for(CFIndex i=0;i<cfCount;i++) {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
        CFStringRef phoneTypeRef = ABMultiValueCopyLabelAtIndex(multiPhones, i);
        
        NSString *phoneNumber = (NSString *) CFBridgingRelease(phoneNumberRef);
        NSString *type = (NSString *) CFBridgingRelease(phoneTypeRef);
        
        if (phoneTypeRef==NULL || type==nil){
            type = (__bridge NSString *)kABOtherLabel;
        }
        
        ContactPhone *phone = (ContactPhone *)[[ContactPhone alloc] initWithValue:phoneNumber andType:type contactId:contact.objectId];
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

- (void)fetchEmails:(Contact*)contact ref:(ABRecordRef )ref
{
    ABMultiValueRef multiEmails = ABRecordCopyValue(ref, kABPersonEmailProperty);
    CFIndex cfCount = ABMultiValueGetCount(multiEmails);
    for (CFIndex i=0; i<cfCount; i++) {
        CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
        CFStringRef emailTypeRef = ABMultiValueCopyLabelAtIndex(multiEmails, i);
        
        NSString *mailAddress = (NSString *) CFBridgingRelease(emailRef);
        NSString *type = (NSString *) CFBridgingRelease(emailTypeRef);
        
        if (emailTypeRef==NULL || type==nil){
            type = (__bridge NSString *)kABOtherLabel;
        }
        
        ContactEmail *newMail = [[ContactEmail alloc] initWithValue:mailAddress andType:type contactId:contact.objectId];
        if (![self isAdded:contact value:newMail] && !SYNC_STRING_IS_NULL_OR_EMPTY(mailAddress) && mailAddress.length <= 255) {
            SYNC_Log(@"email : %@", type);
            [contact.devices addObject:newMail];
        }
    }
    if (multiEmails!=NULL) {
        CFRelease(multiEmails);
    }
}

- (void)fetchEmails:(Contact*)contact
{
    ABMultiValueRef multiEmails = ABRecordCopyValue(contact.recordRef, kABPersonEmailProperty);
    CFIndex cfCount = ABMultiValueGetCount(multiEmails);
    for (CFIndex i=0; i<cfCount; i++) {
        CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
        CFStringRef emailTypeRef = ABMultiValueCopyLabelAtIndex(multiEmails, i);
        
        NSString *mailAddress = (NSString *) CFBridgingRelease(emailRef);
        NSString *type = (NSString *) CFBridgingRelease(emailTypeRef);
        
        if (emailTypeRef==NULL || type==nil){
            type = (__bridge NSString *)kABOtherLabel;
        }
        
        ContactEmail *newMail = [[ContactEmail alloc] initWithValue:mailAddress andType:type contactId:contact.objectId];
        if (![self isAdded:contact value:newMail] && !SYNC_STRING_IS_NULL_OR_EMPTY(mailAddress) && mailAddress.length <= 255) {
            SYNC_Log(@"email : %@", type);
            [contact.devices addObject:newMail];
        }
    }
    if (multiEmails!=NULL) {
        CFRelease(multiEmails);
    }
}

- (void)fetchAddresses:(Contact*)contact ref:(ABRecordRef )ref
{
    ABMultiValueRef multiAddresses = ABRecordCopyValue(ref, kABPersonAddressProperty);
    CFIndex cfCount = ABMultiValueGetCount(multiAddresses);
    for (CFIndex i=0; i<cfCount; i++) {
        CFDictionaryRef addressRef = ABMultiValueCopyValueAtIndex(multiAddresses, i);
        CFStringRef addressTypeRef = ABMultiValueCopyLabelAtIndex(multiAddresses, i);
        
        NSDictionary *addressDict = (__bridge NSDictionary *) addressRef;
        NSString *type = (__bridge NSString *) addressTypeRef;
        
        if (addressRef!=NULL)
            CFRelease(addressRef);
        if (addressTypeRef==NULL || type==nil){
            type = (__bridge NSString *)kABOtherLabel;
        }
        if (addressTypeRef!=NULL){
            CFRelease(addressTypeRef);
        }

        ContactAddress *newAddress = [[ContactAddress alloc] initWithRef:addressDict type:type contactId:contact.objectId];
        if (![self isAddedAddress:contact value:newAddress]) {
            SYNC_Log(@"address : %@", type);
            [contact.addresses addObject:newAddress];
        }
    }
    if (multiAddresses!=NULL) {
        CFRelease(multiAddresses);
    }
}

- (void)fetchAddresses:(Contact*)contact
{
    ABMultiValueRef multiAddresses = ABRecordCopyValue(contact.recordRef, kABPersonAddressProperty);
    CFIndex cfCount = ABMultiValueGetCount(multiAddresses);
    for (CFIndex i=0; i<cfCount; i++) {
        CFDictionaryRef addressRef = ABMultiValueCopyValueAtIndex(multiAddresses, i);
        CFStringRef addressTypeRef = ABMultiValueCopyLabelAtIndex(multiAddresses, i);
        
        NSDictionary *addressDict = (__bridge NSDictionary *) addressRef;
        NSString *type = (__bridge NSString *) addressTypeRef;
        
        if (addressRef!=NULL)
            CFRelease(addressRef);
        if (addressTypeRef==NULL || type==nil){
            type = (__bridge NSString *)kABOtherLabel;
        }
        if (addressTypeRef!=NULL){
            CFRelease(addressTypeRef);
        }

        ContactAddress *newAddress = [[ContactAddress alloc] initWithRef:addressDict type:type contactId:contact.objectId];
        if (![self isAddedAddress:contact value:newAddress]) {
            SYNC_Log(@"address : %@", type);
            [contact.addresses addObject:newAddress];
        }
    }
    if (multiAddresses!=NULL) {
        CFRelease(multiAddresses);
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
-(BOOL)isAddedAddress:(Contact*)contact value:(ContactAddress*)newValue{
    if (contact.addresses.count==0) {
        return NO;
    }
    
    if ([contact.addresses containsObject:newValue]) {
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

-(NSMutableArray*)collectDevices:(NSMutableArray<Contact *>*)contactList{
    NSMutableArray<ContactDevice *> *devices = [[NSMutableArray alloc]init];
    for (Contact *c in contactList){
        for (ContactDevice *contactDevice in c.devices){
            
            ContactPhone *cp = nil;
            BOOL containsPhone = false;
            if ([contactDevice isKindOfClass:[ContactPhone class]]){
                cp = (ContactPhone*)contactDevice;
                cp.value = [cp getCompareValue:YES];
                
                for(ContactDevice *cd in devices){
                    if ([cd isKindOfClass:[ContactPhone class]]){
                        ContactPhone *cdd = (ContactPhone*) cd;
                        if ([[cdd getCompareValue:NO] isEqualToString:[cp getCompareValue:NO]]){
                            containsPhone = true;
                        }
                    }
                }
            }
            
            if ((cp != nil && !containsPhone)|| (cp == nil && ![devices containsObject:contactDevice])){
                [devices addObject:contactDevice];
            }
        }
    }
    return devices;
}

-(NSMutableArray*)collectAddresses:(NSMutableArray<Contact *>*)contactList{
    NSMutableArray<ContactAddress *> *addresses = [[NSMutableArray alloc]init];
    for (Contact *c in contactList){
        for (ContactAddress *contactAddress in c.addresses){
            if (![addresses containsObject:contactAddress]){
                [addresses addObject:contactAddress];
            }
        }
    }
    return addresses;
}

-(void)collectGeneralInfo:(NSMutableArray<Contact *>*)contacts masterContact:(Contact*)masterContact{
    for (Contact *c in contacts){
        if ([c.objectId isEqualToNumber:masterContact.objectId]){
            continue;
        }
        if (SYNC_STRING_IS_NULL_OR_EMPTY(masterContact.company) && !SYNC_STRING_IS_NULL_OR_EMPTY(c.company)){
            masterContact.company = c.company;
        }
        if (SYNC_STRING_IS_NULL_OR_EMPTY(masterContact.firstName) && !SYNC_STRING_IS_NULL_OR_EMPTY(c.firstName)){
            masterContact.firstName = c.firstName;
        }
        if (SYNC_STRING_IS_NULL_OR_EMPTY(masterContact.middleName) && !SYNC_STRING_IS_NULL_OR_EMPTY(c.middleName)){
            masterContact.middleName = c.middleName;
        }
        if (SYNC_STRING_IS_NULL_OR_EMPTY(masterContact.lastName) && !SYNC_STRING_IS_NULL_OR_EMPTY(c.lastName)){
            masterContact.lastName = c.lastName;
        }
        if (SYNC_STRING_IS_NULL_OR_EMPTY(masterContact.nickName) && !SYNC_STRING_IS_NULL_OR_EMPTY(c.nickName)){
            masterContact.nickName = c.nickName;
        }
    }
}

-(Contact*)mergeContacts:(NSMutableArray<Contact *>*)contacts masterContact:(Contact*)masterContact{
    masterContact.devices = [self collectDevices:contacts];
    masterContact.addresses = [self collectAddresses:contacts];
    [self collectGeneralInfo:contacts masterContact:masterContact];
    
    return masterContact;
}

-(NSArray *)getContactIds:(NSArray*)list{
    NSMutableArray *ids = [NSMutableArray new];
    for (Contact *contact in list){
        [ids addObject:contact.objectId];
    }
    return ids;
}


@end
