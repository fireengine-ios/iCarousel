//
//  ContactsSyncService.swift
//  Depo
//
//  Created by Aleksandr on 7/7/17.
//  Copyright © 2017 com.igones. All rights reserved.
//


struct ContactsSyncServiceConstant {
    
    static let debugURL = "http://contactsync.test.valven.com/ttyapi/"
    
    static let prodURL =  "https://adepo.turkcell.com.tr/ttyapi/"
    static let webProdURL =  "https://contactsync.turkcell.com.tr/ttyapi/"
}

class ContactsSyncService {
    
    init() {
        setup()
    }
    
    typealias ProgressCallback = (_ progress: Int, _ mode: SyncOperationType) -> Void
    typealias FinishCallback = (_ finished: ContactSync.SyncResponse, _ mode: SyncOperationType) -> Void
    typealias AnalyzeFinishCallback = (_ finished: ContactSync.AnalyzeResponse) -> Void
    typealias ErrorCallback = (_ errorType: SyncOperationErrors, _ mode: SyncOperationType) -> Void

    func executeOperation(type: SYNCMode, progress: ProgressCallback?, finishCallback: FinishCallback?, errorCallback: ErrorCallback?) {
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
            progress?(Int(truncating: progressPerecentage), status)
        }
        
        SyncSettings.shared().mode  = type
        ContactSyncSDK.doSync(type)
    }
    
    func getBackUpStatus(completion: @escaping (ContactSync.SyncResponse) -> Void, fail: @escaping () -> Void) {
        ContactSyncSDK.getBackupStatus { (response) in
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
    
    func cancellCurrentOperation() {
        //TODO: Pestryakov find out how to close
//        SyncStatus.shared().reset()
//        AnalyzeStatus.shared().reset()
        ContactSyncSDK.cancelAnalyze()
    }
    
    func analyze(progressCallback: ProgressCallback?, finishCallback: AnalyzeFinishCallback?, errorCallback: ErrorCallback?) {
        ContactSyncSDK.doAnalyze(true)
        
        SyncSettings.shared().analyzeNotifyCallback = { (_ contactsToMerge, _ contactsToDelete) in
            progressCallback?(100, .analyze)
            guard let contactsToMerge = contactsToMerge as? [String: Int],
                  let contactsToDelete = contactsToDelete as? [String] else {
                    errorCallback?(.failed, .analyze)
                return
            }
            
            let parsedContactsToMerge = ContactsSyncService.parseContactsToMerge(contactsToMerge)
            let parsedContactsToDelete = ContactsSyncService.parseContactsToDelete(contactsToDelete)
            
            let response = ContactSync.AnalyzeResponse(contactsToMerge: parsedContactsToMerge,
                                                      contactsToDelete: parsedContactsToDelete)
            
            finishCallback?(response)
        }
        
        SyncSettings.shared().analyzeProgressCallback = {
            let progressPerecentage = AnalyzeStatus.shared().progress ?? 0
            progressCallback?(Int(truncating: progressPerecentage), .analyze)
        }
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
    
    private func setup() {
        SyncSettings.shared().token = ApplicationSession.sharedSession.session.authToken
        SyncSettings.shared().url =  ContactsSyncServiceConstant.webProdURL
        SyncSettings.shared().environment = .productionEnvironment//.developmentEnvironment
    }
    
}
