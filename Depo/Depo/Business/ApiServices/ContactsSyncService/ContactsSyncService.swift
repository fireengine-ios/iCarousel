//
//  ContactsSyncService.swift
//  Depo
//
//  Created by Aleksandr on 7/7/17.
//  Copyright © 2017 com.igones. All rights reserved.
//


enum ContactsSyncServiceConstant {
//    static let debugURL = "http://contactsync.test.valven.com/ttyapi/"
//    static let prodURL =  "https://adepo.turkcell.com.tr/ttyapi/"
    static let webProdURL =  "https://contactsync.turkcell.com.tr/ttyapi/"
}

typealias ContactsOperation = (ContactsResponse) -> Void

class ContactsSyncService: BaseRequestService {
    
    override init() {
        super.init()
        setup()
    }
    
    typealias Callback = VoidHandler
    typealias ProgressCallback = (_ progress: Int, _ count: Int, _ mode: SyncOperationType) -> Void
    typealias FinishCallback = (_ response: ContactSync.SyncResponse, _ mode: SyncOperationType) -> Void
    typealias AnalyzeFinishCallback = (_ response: [ContactSync.AnalyzedContact]) -> Void
    typealias ErrorCallback = (_ errorType: SyncOperationErrors, _ mode: SyncOperationType) -> Void
    
    private var lastToDeleteContactsValue: Int = 0

    func executeOperation(type: SYNCMode, progress: ProgressCallback?, finishCallback: FinishCallback?, errorCallback: ErrorCallback?) {
        let typeString = type == .backup ? "Backup" : "Restore"
        log.debug("ContactsSyncService executeOperation \(typeString)")
        
        guard !ContactSyncSDK.isRunning() else {
            return
        }
        
        SyncSettings.shared().callback = { [weak self] response in
            self?.checkStatus(with: errorCallback, finishCallback: finishCallback)
        }
        
        SyncSettings.shared().progressCallback = { [weak self] in
            guard let status = self?.getCurrentOperationType() else {
                return
            }
            
            let progressPerecentage = SyncStatus.shared().progress ?? 0
            progress?(Int(truncating: progressPerecentage), 0, status)
        }
        
        SyncSettings.shared().mode = type
        ContactSyncSDK.doSync(type)
    }
    
    func getBackUpStatus(completion: @escaping (ContactSync.SyncResponse) -> Void, fail: @escaping VoidHandler) {
        log.debug("ContactsSyncService getBackUpStatus")
        
        ContactSyncSDK.getBackupStatus { response in
            guard let response = response as? [String: Any],
                  let contactsAmount = response["contacts"] as? Int,
                  let updatedContactsAmount = response["updated"] as? Int,
                  let createdContactsAmount = response["created"] as? Int,
                  let deletedContactsAmount = response["deleted"] as? Int,
                  let time = response["timestamp"] as? TimeInterval else {
                    fail()
                    return
            }
            
            let syncModel = ContactSync.SyncResponse(responseType: .getBackUpStatus,
                                                    totalNumberOfContacts: contactsAmount,
                                                    newContactsNumber: createdContactsAmount,
                                                    duplicatesNumber: updatedContactsAmount,
                                                    deletedNumber: deletedContactsAmount,
                                                    date: Date(timeIntervalSince1970: time / 1000))
            completion(syncModel)
        }
    }
    
    func getCurrentOperationType() -> SyncOperationType {
        switch SyncSettings.shared().mode {
        case .backup:
            return .backup
        case .restore:
            return .restore
        }
    }
    
    func checkStatus(with errorCallback: ErrorCallback?, finishCallback: FinishCallback?) {
        if SyncStatus.shared().status == .RESULT_SUCCESS {
            constractSuccessResponse(finishCallback: finishCallback)
        } else {
            constractErrorCallBack(errorCallback: errorCallback)
        }
    }
    
    func constractErrorCallBack(errorCallback: ErrorCallback?) {

        switch SyncStatus.shared().status {
        case .RESULT_ERROR_PERMISSION_ADDRESS_BOOK:
            errorCallback?(.accessDenied, getCurrentOperationType())
        case .RESULT_ERROR_REMOTE_SERVER:
            errorCallback?(.remoteServerError, getCurrentOperationType())
        case .RESULT_ERROR_NETWORK:
            errorCallback?(.networkError, getCurrentOperationType())
        case .RESULT_ERROR_INTERNAL:
            errorCallback?(.internalError, getCurrentOperationType())
        case .RESULT_FAIL:
            errorCallback?(.failed, getCurrentOperationType())
        default:
            break
        }
    }
    
    func constractSuccessResponse(finishCallback: FinishCallback?) {
        finishCallback?(constractContactSyncInfoModel(), getCurrentOperationType())
    }
    
    func constractContactSyncInfoModel() -> ContactSync.SyncResponse {
        switch  SyncSettings.shared().mode {
        case .backup:
            return ContactSync.SyncResponse(responseType: .backup,
                                           totalNumberOfContacts: SyncStatus.shared().totalContactOnServer as! Int,
                                           newContactsNumber: SyncStatus.shared().createdContactsSent.count,
                                           duplicatesNumber: SyncStatus.shared().updatedContactsSent.count,
                                           deletedNumber: SyncStatus.shared().deletedContactsOnServer.count,
                                           date: Date())
        case .restore:
            return ContactSync.SyncResponse(responseType: .restore,
                                           totalNumberOfContacts: SyncStatus.shared().totalContactOnClient as! Int,
                                           newContactsNumber: SyncStatus.shared().createdContactsReceived.count,
                                           duplicatesNumber: SyncStatus.shared().updatedContactsReceived.count,
                                           deletedNumber: SyncStatus.shared().deletedContactsOnDevice.count,
                                           date: nil)
            
        }
    }
    
    func cancel() {
        ContactSyncSDK.cancelAnalyze()
    }
    
    func analyze(progressCallback: ProgressCallback?, successCallback: AnalyzeFinishCallback?, cancelCallback: Callback?, errorCallback: ErrorCallback?) {
        ContactSyncSDK.doAnalyze(true)
        
        SyncSettings.shared().analyzeNotifyCallback = { contactsToMerge, contactsToDelete in
            progressCallback?(100, contactsToDelete?.count ?? 0, AnalyzeStatus.shared().analyzeStep == .ANALYZE_STEP_CLEAR_DUPLICATES ? .deleteDuplicated : .analyze)
            guard let contactsToMerge = contactsToMerge as? [String: Int],
                  let contactsToDelete = contactsToDelete as? [String] else {
                    errorCallback?(.failed, AnalyzeStatus.shared().analyzeStep == .ANALYZE_STEP_CLEAR_DUPLICATES ? .deleteDuplicated : .analyze)
                return
            }
            
            let parsedContactsToMerge = ContactsSyncService.parseContactsToMerge(contactsToMerge)
            let parsedContactsToDelete = ContactsSyncService.parseContactsToDelete(contactsToDelete)
            
            if parsedContactsToDelete.count > 0 {
                self.lastToDeleteContactsValue = parsedContactsToDelete.count
            }
            
            let response = ContactsSyncService.mergeContacts(parsedContactsToMerge, with: parsedContactsToDelete)
            
            successCallback?(response)
        }
        
        SyncSettings.shared().analyzeProgressCallback = {
            let progressPerecentage = AnalyzeStatus.shared().progress ?? 0
            let countValue = AnalyzeStatus.shared().analyzeStep == .ANALYZE_STEP_CLEAR_DUPLICATES ? self.lastToDeleteContactsValue : 0
            progressCallback?(Int(truncating: progressPerecentage), countValue, AnalyzeStatus.shared().analyzeStep == .ANALYZE_STEP_CLEAR_DUPLICATES ? .deleteDuplicated : .analyze)
        }
        
        SyncSettings.shared().analyzeCompleteCallback = {
            if AnalyzeStatus.shared().status == .CANCELLED &&
                AnalyzeStatus.shared().analyzeStep != .ANALYZE_STEP_CLEAR_DUPLICATES {
                SyncSettings.shared().analyzeNotifyCallback = nil
                SyncSettings.shared().analyzeProgressCallback = nil
                cancelCallback?()
                return
            }
        }
    }
    
    func deleteDuplicates() {
        log.debug("ContactsSyncService deleteDuplicates")
        
        if AnalyzeStatus.shared().analyzeStep == AnalyzeStep.ANALYZE_STEP_PROCESS_DUPLICATES {
            ContactSyncSDK.continueAnalyze()
        }
    }
    
    func searchRemoteContacts(with query: String, page: Int, success: ContactsOperation?, fail: FailResponse?) {
        log.debug("ContactsSyncService searchRemoteContacts")
        
        let handler = BaseResponseHandler<ContactsResponse, ObjectRequestResponse>(success: { response  in
            guard let response = response as? ContactsResponse else {
                return
            }
            success?(response)
        }, fail: fail)
        executeGetRequest(param: SearchContacts(query: query, page: page), handler: handler)
    }
    
    func deleteRemoteContacts(_ contacts: [RemoteContact], success: SuccessResponse?, fail: FailResponse?) {
        log.debug("ContactsSyncService deleteRemoteContacts")
        
        let param = DeleteContacts(contactIDs: contacts.compactMap{ $0.id })
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeDeleteRequest(param: param, handler: handler)
    }
    
    func getContacts(with page: Int, success: ContactsOperation?, fail: FailResponse?) {
        log.debug("ContactsSyncService getContacts")
        
        let handler = BaseResponseHandler<ContactsResponse, ObjectRequestResponse>(success: { response  in
            guard let response = response as? ContactsResponse else {
                return
            }
            success?(response)
        },
            fail: fail)
        executeGetRequest(param: GetContacts(page: page), handler: handler)
    }
    
    static private func parseContactsToMerge(_ contactsToMerge: [String: Int]) -> [ContactSync.AnalyzedContact] {
        var parsedContacts = [ContactSync.AnalyzedContact]()
        for (name, numberOfErrors) in contactsToMerge {
            let contact = ContactSync.AnalyzedContact(name: name, numberOfErrors: numberOfErrors)
            parsedContacts.append(contact)
        }
        
        return parsedContacts
    }
    
    static private func parseContactsToDelete(_ contactsToMerge: [String]) -> [ContactSync.AnalyzedContact] {
        var parsedContacts = [ContactSync.AnalyzedContact]()
        var contactsToParse = contactsToMerge
        
        while contactsToParse.count > 0 {
            let name = contactsToParse.first!
            let numberOfErrors = contactsToParse.filter({ $0 == name }).count
            
            contactsToParse = contactsToParse.filter({ $0 != name })
            
            let contact = ContactSync.AnalyzedContact(name: name, numberOfErrors: numberOfErrors)
            parsedContacts.append(contact)
        }
        
        return parsedContacts
    }
    
    static private func mergeContacts(_ firstContacts: [ContactSync.AnalyzedContact],
                                      with secondContacts: [ContactSync.AnalyzedContact]) -> [ContactSync.AnalyzedContact] {
        var finalContacts = [ContactSync.AnalyzedContact]()
        for contact in firstContacts {
            let name = contact.name
            var numberOfErrors = contact.numberOfErrors
            if let index = secondContacts.index(where: { $0.name == name }) {
                numberOfErrors += secondContacts[index].numberOfErrors
            }
            let finalContact = ContactSync.AnalyzedContact(name: name, numberOfErrors: numberOfErrors)
            finalContacts.append(finalContact)
        }
        
        for contact in secondContacts {
            if !firstContacts.contains(where: { $0.name == contact.name }) {
                finalContacts.append(contact)
            }
        }
        
        return finalContacts
    }
    
    private func setup() {
        let tokenStorage: TokenStorage = factory.resolve()
        SyncSettings.shared().token = tokenStorage.accessToken
        SyncSettings.shared().url = ContactsSyncServiceConstant.webProdURL
        SyncSettings.shared().environment = .productionEnvironment//.developmentEnvironment
    }
    
}
