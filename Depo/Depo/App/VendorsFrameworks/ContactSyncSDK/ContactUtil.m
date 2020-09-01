//
//  ContactUtil.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "ContactUtil.h"
#import "SyncSettings.h"
#import <Contacts/Contacts.h>

@interface ContactUtil ()

@property CNContactStore* store;

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
    if (_store) {
        callback(YES);
        return;
    }
    switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]) {
        case CNAuthorizationStatusAuthorized:
            _store = [[CNContactStore alloc] init];
            callback(YES);
            break;
        default:
            callback(NO);
            break;
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

-(void)releaseCNStore {

}

-(void)fetchCNContact{
    SYNC_Log(@"%@", @"Get Store");
    if (_store) {
        return;
    }
    _store = [[CNContactStore alloc] init];
    SYNC_Log(@"%@", @"Store created");
}

- (void)deleteContacts:(NSMutableArray<Contact*>*) contacts{
    CNSaveRequest* saveRequest = [[CNSaveRequest alloc] init];
    NSArray* cnContacts = [self getCNContacts:contacts keys:@[]];
    
    int counter = 0;
    for (CNContact *cnContact in cnContacts) {
        [saveRequest deleteContact:[cnContact mutableCopy]];
        counter++;
        if (counter % 1000 == 0 || counter == [cnContacts count]){
            NSError * error = nil;
            @try {
                SYNC_Log(@"%@", @"executeSaveRequest for delete")
                [_store executeSaveRequest:saveRequest error:&error];
                if (error != nil) {
                    SYNC_Log(@"ERROR IN DELETING CONTACTS : %@", error.description);
                }
            } @catch (NSException *exception) {
                SYNC_Log(@"EXCEPTION IN DELETING CONTACTS : %@", exception.description);
            }
            saveRequest = [[CNSaveRequest alloc] init];
        }
    }
}

- (CNMutableContact*)save:(Contact*)contact cnContact:(CNMutableContact*)cnContact {
    if (cnContact == nil) {
        cnContact = [[CNMutableContact alloc] init];
    }
    cnContact = [self putValues:contact cnContact:cnContact];
    return cnContact;
}

- (CNMutableContact*)putValues:(Contact*)contact cnContact:(CNMutableContact*)cnContact {
    if(!SYNC_STRING_IS_NULL_OR_EMPTY(contact.firstName)){
        cnContact.givenName = contact.firstName;
    }
    if(!SYNC_STRING_IS_NULL_OR_EMPTY(contact.middleName)){
        cnContact.middleName = contact.middleName;
    }
    if(!SYNC_STRING_IS_NULL_OR_EMPTY(contact.nickName)){
        cnContact.nickname = contact.nickName;
    }
    if(!SYNC_STRING_IS_NULL_OR_EMPTY(contact.lastName)){
        cnContact.familyName = contact.lastName;
    }
    if(!SYNC_STRING_IS_NULL_OR_EMPTY(contact.company)){
        cnContact.organizationName = contact.company;
    }

    NSMutableArray *phones = [NSMutableArray new];
    NSMutableArray *emails = [NSMutableArray new];
    if (!SYNC_ARRAY_IS_NULL_OR_EMPTY(contact.devices)){
        for (ContactDevice *device in contact.devices){
            if ([device isKindOfClass:[ContactEmail class]]){
                [emails addObject:
                 [[CNLabeledValue alloc] initWithLabel:[device deviceTypeLabel] value:device.value]];
            } else {
                CNPhoneNumber *p = [[CNPhoneNumber alloc] initWithStringValue:device.value];
                [phones addObject:
                 [[CNLabeledValue alloc] initWithLabel:[device deviceTypeLabel] value:p]];
            }
        }
    }
    cnContact.phoneNumbers = phones;
    cnContact.emailAddresses = emails;
    
    NSMutableArray *addresses = [NSMutableArray new];
    
    if (!SYNC_ARRAY_IS_NULL_OR_EMPTY(contact.addresses)){
        for (ContactAddress *address in contact.addresses) {
            CNMutablePostalAddress* postalAddress = [[CNMutablePostalAddress alloc] init];
            postalAddress.street = address.street;
            postalAddress.postalCode = address.postalCode;
            postalAddress.state = address.district;
            postalAddress.city = address.city;
            postalAddress.country = address.country;
            
            [addresses addObject:[[CNLabeledValue alloc] initWithLabel:[address addressTypeLabel] value:postalAddress]];
        }
    }
    cnContact.postalAddresses = addresses;
    return cnContact;
}

- (void)saveList:(NSArray<Contact*>*)contacts
{
    NSMutableArray<CNMutableContact*>* finalList = [NSMutableArray new];
    
    NSMutableDictionary* updateContacts = [NSMutableDictionary new];
    for (Contact *c in contacts){
        if (SYNC_STRING_IS_NULL_OR_EMPTY(c.objectIdentifier)) {
            // create
            [finalList addObject:[self save:c cnContact:nil]];
        } else {
            // update
            [updateContacts setObject:c forKey:c.objectIdentifier];
        }
    }
    
    NSArray* updateCNContactList = [self getCNContacts:[updateContacts allValues] keys:[self getCNContactKeys]];
    for (CNContact *cn in updateCNContactList) {
        Contact* c = [updateContacts objectForKey:cn.identifier];
        [finalList addObject:[self save:c cnContact:[cn mutableCopy]]];
    }
  
    int counter = 0;
    CNSaveRequest* saveRequest = [[CNSaveRequest alloc] init];
    for (CNMutableContact *cnContact in finalList){
        Contact* c = [updateContacts objectForKey:cnContact.identifier];
        if (SYNC_IS_NULL(c)) {
            [saveRequest addContact:cnContact toContainerWithIdentifier:nil];
        } else {
            [saveRequest updateContact:cnContact];
        }
        counter++;
        if (counter % SYNC_RESTORE_THRESHOLD == 0 || counter == [contacts count]){
            NSError * error = nil;
            @try {
                SYNC_Log(@"%@", @"executeSaveRequest")
                [_store executeSaveRequest:saveRequest error:&error];
                if (error != nil) {
                    SYNC_Log(@"ERROR IN SAVING CONTACTS : %@", error.description);
                }
            } @catch (NSException *exception) {
                SYNC_Log(@"EXCEPTION IN SAVING CONTACTS : %@", exception.description);
            }
            saveRequest = [[CNSaveRequest alloc] init];
        }
    }
}

- (NSMutableArray*)fetchLocalContacts
{
    NSMutableArray *contacts = [self fetchContacts:ONLY_LOCAL];
    NSMutableArray *localContacts = [NSMutableArray new];
    for (Contact *c in contacts) {
        if (c.defaultAccount) {
            [localContacts addObject:c];
        }
    }
    return localContacts;
}

- (NSMutableArray*)fetchContacts:(CNContactFetchType)fetchType{
    return [self fetchContacts:-1 offset:-1 fetchType:fetchType];
}

- (NSMutableArray*)fetchContacts:(NSInteger)bulkCount offset:(NSInteger)offset fetchType:(CNContactFetchType)fetchType
{
    // not using offset for local contacts
    [self fetchCNContact];
    NSMutableArray *ret = [NSMutableArray new];
    if (!_store) {
        return ret;
    }
    NSError *error;
    NSMutableArray* unified = [NSMutableArray new];

    NSArray *containers = [_store containersMatchingPredicate:nil error:&error];
    [unified addObjectsFromArray:[self getCNContacts:containers fetchType:fetchType]];
    
    if (error) {
        SYNC_Log(@"ERROR IN FETCHING CONTACTS :: %@", error.description);
    } else {
        NSUInteger nPeople = [unified count];
        NSInteger index = (offset != -1 ? offset: 0);
        SYNC_Log(@"bulkCount %zd offset %zd index %zd npeople %zd", bulkCount, offset, index, nPeople)
        
        for ( ; index < nPeople; index++ )
        {
            if (offset > -1 && bulkCount > 0 && index == (bulkCount + offset)){
                break;
            }
            if (!_store) {
                break;
            }
            @try
            {
                CNContactUnified* u = [unified objectAtIndex:index];
                CNContact *cnContact = u.cnContact;
                
                Contact *contact = [[Contact alloc] initWithCNContact:cnContact];
                [contact setDefaultAccount:u.isDefault];
                
                NSString *displayName = contact.generateDisplayName;
                if(!SYNC_STRING_IS_NULL_OR_EMPTY(displayName) && displayName.length > 1000){
                    continue;
                }
                
                if (!SYNC_STRING_IS_NULL_OR_EMPTY(contact.firstName) || !SYNC_STRING_IS_NULL_OR_EMPTY(contact.middleName) || !SYNC_STRING_IS_NULL_OR_EMPTY(contact.lastName) || !SYNC_STRING_IS_NULL_OR_EMPTY(contact.nickName)){
                    contact.hasName = YES;
                } else {
                    contact.hasName = NO;
                }

                [self fetchNumbers:contact cnContact:cnContact];
                [self fetchEmails:contact cnContact:cnContact];
                [self fetchAddresses:contact cnContact:cnContact];
                [ret addObject:contact];
            }
            @catch (NSException *exception)
            {
                NSLog(@"EXCEPTION IN CONTACTS :: %@", exception.description);
            }
        }
    }
    return ret;
}

- (NSInteger)getContactCount
{
    __block NSUInteger contactsCount = 0;
    NSError *error;
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[]];
    BOOL success = [_store enumerateContactsWithFetchRequest:request error:&error
                                                 usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        contactsCount += 1;
    }];
    if (!success || error) {
        SYNC_Log(@"error counting all contacts, error - %@", error.localizedDescription);
    }
    return contactsCount;
}

- (void)fetchNumbers:(Contact*)contact cnContact:(CNContact*)cnContact
{
    contact.hasPhoneNumber = NO;
    
    for (CNLabeledValue *number in cnContact.phoneNumbers)
    {
        NSString *phoneNumber = [number.value stringValue];
        NSString *type = number.label;
        
        ContactPhone *phone = (ContactPhone *)[[ContactPhone alloc] initWithValue:phoneNumber andType:type contactIdentifier:contact.objectIdentifier];
        if (![self isAdded:contact value:phone] && !SYNC_STRING_IS_NULL_OR_EMPTY(phoneNumber) && phoneNumber.length <= 255) {
            SYNC_Log(@"phone : %@", type);
            contact.hasPhoneNumber = YES;
            [contact.devices addObject:phone];
        }
        
    }
}

- (void)fetchEmails:(Contact*)contact cnContact:(CNContact* )cnContact
{
    for (CNLabeledValue *email in cnContact.emailAddresses)
    {
        NSString *mailAddress = email.value;
        NSString *type = email.label;
        
        ContactEmail *newMail = [[ContactEmail alloc] initWithValue:mailAddress andType:type contactIdentifier:contact.objectIdentifier];
        if (![self isAdded:contact value:newMail] && !SYNC_STRING_IS_NULL_OR_EMPTY(mailAddress) && mailAddress.length <= 255) {
            SYNC_Log(@"email : %@", type);
            [contact.devices addObject:newMail];
        }
    }
}

- (void)fetchAddresses:(Contact*)contact cnContact:(CNContact* )cnContact
{
    for (CNLabeledValue<CNPostalAddress*> *label in cnContact.postalAddresses) {
        NSString *type = label.label;
        CNPostalAddress *postalAddress = label.value;
        ContactAddress *newAddress = [[ContactAddress alloc] initWithCNPostalAddress:postalAddress type:type contactIdentifier:contact.objectIdentifier];
        if (![self isAddedAddress:contact value:newAddress]) {
            SYNC_Log(@"address : %@", type);
            [contact.addresses addObject:newAddress];
        }
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
        if ([c.objectIdentifier isEqualToString:masterContact.objectIdentifier]){
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
        [ids addObject:contact.objectIdentifier];
    }
    return ids;
}

-(NSArray *)getCNContactKeys {
    return @[CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactNicknameKey, CNContactOrganizationNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey];
}

-(CNContact*) getCNContact:(NSString*)identifier{
    SYNC_Log(@"getCNContact: %@", identifier);
    NSPredicate *predicate = [CNContact predicateForContactsWithIdentifiers:@[identifier]];
    NSError *error;
    NSArray *cnContacts = [_store unifiedContactsMatchingPredicate:predicate keysToFetch:[self getCNContactKeys] error:&error];
    if (error) {
        SYNC_Log(@"ERROR IN FETCHING CONTACT :: %@", error.description);
    } else {
        if ([cnContacts count] > 0) {
            return [cnContacts objectAtIndex:0];
        }
    }
    SYNC_Log(@"getCNContact contact not found %@", identifier);
    return nil;
}

-(NSArray*) getCNContacts:(NSArray*)contacts keys:(NSArray*)keys{
    if (contacts.count <= 0) {
        return @[];
    }
    NSMutableArray* identifiers = [NSMutableArray new];
    for (Contact* c in contacts) {
        [identifiers addObject:c.objectIdentifier];
    }
    SYNC_Log(@"getCNContacts: %lu", (unsigned long)[identifiers count]);
    NSPredicate *predicate = [CNContact predicateForContactsWithIdentifiers:identifiers];
    NSError *error;
    NSArray *cnContacts = [_store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
    if (error) {
        SYNC_Log(@"ERROR IN FETCHING CONTACT :: %@", error.description);
    }
    return cnContacts;
}

-(NSArray*) getCNContacts:(NSArray*)containers fetchType:(CNContactFetchType)fetchType{
    SYNC_Log(@"getCNContacts: %@", @(fetchType));
    NSError* error = nil;
    NSMutableArray* cnContacts = [NSMutableArray new];
    
    if (fetchType == ALL) {
        CNContactFetchRequest* request = [[CNContactFetchRequest alloc] initWithKeysToFetch:[self getCNContactKeys]];
        [_store enumerateContactsWithFetchRequest:request error:&error usingBlock: ^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            [cnContacts addObject:[[CNContactUnified alloc] initWithCNContact:contact local:false]];
        }];
    } else {
        for (CNContainer* container in containers) {
            SYNC_Log(@"Container found: %@ %@ %@", container.name, @(container.type), container.identifier)
            BOOL local = container.type == CNContainerTypeCardDAV || container.type == CNContainerTypeLocal;
            
            if (fetchType == ONLY_LOCAL && !local) {
                SYNC_Log(@"container skipped")
                continue;
            }
            
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:container.identifier];
            NSArray *containerContacts = [_store unifiedContactsMatchingPredicate:predicate keysToFetch:[self getCNContactKeys] error:&error];
            if (!SYNC_IS_NULL(error)) {
                SYNC_Log(@"ERROR WHILE FETCHING CONTACTS");
            }
            
            SYNC_Log(@"%lu contacts found in container", (unsigned long)[containerContacts count])
            for (CNContact* cnContact in containerContacts) {
                [cnContacts addObject:[[CNContactUnified alloc] initWithCNContact:cnContact local:local]];
            }
        }
    }
    return cnContacts;
}

@end
