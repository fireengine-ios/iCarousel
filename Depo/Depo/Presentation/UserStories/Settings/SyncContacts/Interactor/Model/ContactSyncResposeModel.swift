//
//  ContactSyncResposeModel.swift
//  Depo
//
//  Created by Aleksandr on 7/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct ContactSyncResposeModel {
    let responseType: SyncOperationType
    let totalNumberOfContacts: Int
    let newContactsNumber: Int
    let duplicatesNumber: Int
    let deletedNumber: Int
    let date: Date?
}
