//
//  ContactSync.SyncResponse.swift
//  Depo
//
//  Created by Aleksandr on 7/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct ContactSync {
    struct SyncResponse {
        let responseType: SyncOperationType
        let totalNumberOfContacts: Int
        let newContactsNumber: Int
        let duplicatesNumber: Int
        let deletedNumber: Int
        let date: Date?
    }
    
    struct AnalyzeResponse {
        let contactsToMerge: [AnalyzedContact]
        let contactsToDelete: [AnalyzedContact]
    }
    
    struct AnalyzedContact {
        let name: String
        let numberOfErrors: Int
    }
}
