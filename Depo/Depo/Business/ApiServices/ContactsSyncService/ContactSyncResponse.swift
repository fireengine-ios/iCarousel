//
//  ContactSyncResponse.swift
//  Depo_LifeTech
//
//  Created by Raman on 1/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class RemoteContactDevice: ObjectRequestResponse {
    private struct JsonKey {
        static let id = "id"
        static let value = "value"
        static let deleted = "deleted"
    }
    
    var id = 0
    var phone = ""
    var isDeleted = false
    
    override func mapping() {
        id = json?[JsonKey.id].int ?? 0
        phone = json?[JsonKey.value].string ?? ""
        isDeleted = json?[JsonKey.value].bool ?? false
    }
}

final class RemoteContact: ObjectRequestResponse {
    private struct JsonKey {
        static let id = "id"
        static let name = "displayname"
        static let lastname = "lastname"
        static let firstname = "firstname"
        static let devices = "devices"
        static let birthDate = "birthDate"
    }
    
    var id = -1
    var name = ""
    var firstname = ""
    var lastname = ""
    var devices = [RemoteContactDevice]()
    var birthDate = ""
    
    var phone: String {
        devices.first(where: { !$0.isDeleted })?.phone ?? ""
    }
    
    var initials: String {
        let letters = [firstname, lastname].compactMap { $0.first?.uppercased() }
        return letters.joined()
    }
    
    override func mapping() {
        id = json?[JsonKey.id].int ?? -1
        name = json?[JsonKey.name].string ?? ""
        firstname = json?[JsonKey.firstname].string ?? ""
        lastname = json?[JsonKey.lastname].string ?? ""
        birthDate = json?[JsonKey.birthDate].string ?? ""

        guard let devicesJson = json?[JsonKey.devices].array else {
            return
        }
        devices = devicesJson.compactMap { RemoteContactDevice(withJSON: $0) }
    }
}

final class ContactsResponse: ObjectRequestResponse, Map {
    private struct JsonKey {
        static let currentPage = "currentPage"
        static let numberOfPages = "numOfPages"
        static let items = "items"
        static let data = "data"
    }
    
    var contacts = [RemoteContact]()
    var currentPage = 0
    var numberOfPages = 0
    
    override func mapping() {
        json = json?[JsonKey.data]
        currentPage = json?[JsonKey.currentPage].int ?? 0
        numberOfPages = json?[JsonKey.numberOfPages].int ?? 0
        
        guard let list = json?[JsonKey.items].array else {
            return
        }
        contacts = list.compactMap { RemoteContact(withJSON: $0) }
    }
}
