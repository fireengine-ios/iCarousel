//
//  ContactSync.SyncResponse.swift
//  Depo
//
//  Created by Aleksandr on 7/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct ContactSync {
    struct SyncResponse: Equatable {
        let responseType: SyncOperationType
        var totalNumberOfContacts: Int
        let newContactsNumber: Int
        let duplicatesNumber: Int
        let deletedNumber: Int
        let date: Date?
    }
    
    struct AnalyzedContact {
        let name: String
        let numberOfErrors: Int
    }
}
