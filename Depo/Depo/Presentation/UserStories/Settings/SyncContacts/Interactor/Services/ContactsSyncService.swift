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
    
    typealias ProgressClousure = (_ progress: Int, _ mode: SyncOperationType) -> Void
    typealias FinishClousure = (_ finished: ContactSyncResposeModel, _ mode: SyncOperationType) -> Void
    typealias ErrorClousure = (_ errorType: SyncOperationErrors, _ mode: SyncOperationType) -> Void

    func executeOperation(type: SYNCMode, progress: ProgressClousure?, finishCallback: FinishClousure?, errorCallback: ErrorClousure?) {
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
            progress?( Int(truncating: progressPerecentage), status)
        }
        
        SyncSettings.shared().mode  = type
        ContactSyncSDK.doSync(type)
    }
    
    func getBackUpStatus(completion: @escaping (ContactSyncResposeModel) -> Void, fail: @escaping () -> Void) {
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
            
            let syncModel = ContactSyncResposeModel(responseType: .getBackUpStatus,
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
    
    func checkStatus(with errorCallback: ErrorClousure?, finishCallback: FinishClousure?) {

        if SyncStatus.shared().status == .RESULT_SUCCESS {
            constractSuccessResponse(finishCallback: finishCallback)
        } else {
            constractErrorCallBack(errorCallback: errorCallback)
        }
    }
    
    func constractErrorCallBack(errorCallback: ErrorClousure?) {

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
    
    func constractSuccessResponse(finishCallback: FinishClousure?) {
        finishCallback?(constractContactSyncInfoModel(), getCurrentOperationType())
    }
    
    func constractContactSyncInfoModel() -> ContactSyncResposeModel {
        switch  SyncSettings.shared().mode {
        case .backup:
            return ContactSyncResposeModel(responseType: .backup,
                                           totalNumberOfContacts: SyncStatus.shared().totalContactOnServer as! Int,
                                           newContactsNumber: SyncStatus.shared().createdContactsSent.count,
                                           duplicatesNumber: SyncStatus.shared().updatedContactsSent.count,
                                           deletedNumber: SyncStatus.shared().deletedContactsOnServer.count,
                                           date: Date())
        case .restore:
            return ContactSyncResposeModel(responseType: .restore,
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
    }
    
    private func setup() {
        SyncSettings.shared().token = ApplicationSession.sharedSession.session.authToken
        SyncSettings.shared().url =  ContactsSyncServiceConstant.webProdURL
        SyncSettings.shared().environment = .productionEnvironment//.developmentEnvironment
    }
    
}
