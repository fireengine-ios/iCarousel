//
//  ContactSyncResponse.swift
//  Depo_LifeTech
//
//  Created by Raman on 1/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class RemoteContactDevice: ObjectRequestResponse {
    enum DeviceCategory: String {
        case phone = "PHONE"
        case email = "EMAIL"
    }
    
    private struct JsonKey {
        static let id = "id"
        static let value = "value"
        static let deleted = "deleted"
        static let category = "category"
    }
    
    var id = 0
    var value = ""
    var isDeleted = false
    var category: DeviceCategory?
    
    override func mapping() {
        id = json?[JsonKey.id].int ?? 0
        value = json?[JsonKey.value].string ?? ""
        isDeleted = json?[JsonKey.value].bool ?? false
        
        if let categoryString = json?[JsonKey.category].string {
            category = DeviceCategory(rawValue: categoryString)
        }
    }
}

final class RemoteContactAddress: ObjectRequestResponse {
    private struct JsonKey {
        static let id = "id"
        static let street = "street"
        static let city = "city"
        static let country = "country"
        static let district = "district"
        static let postalCode = "postalCode"
    }
    
    var id = 0
    var street = ""
    var city = ""
    var country = ""
    var district = ""
    var postalCode = ""
    
    var displayAddress: String {
        let address = "\(postalCode) \(street) \(city) \(district) \(country)"
        return address.trimmingCharacters(in: .whitespaces)
    }
    
    override func mapping() {
        id = json?[JsonKey.id].int ?? 0
        street = json?[JsonKey.street].string ?? ""
        city = json?[JsonKey.city].string ?? ""
        country = json?[JsonKey.country].string ?? ""
        district = json?[JsonKey.district].string ?? ""
        postalCode = json?[JsonKey.postalCode].string ?? ""
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
        static let addresses = "addresses"
        static let notes = "notes"
        static let company = "company"
    }
    
    var id = -1
    var name = ""
    var firstname = ""
    var lastname = ""
    var devices = [RemoteContactDevice]()
    var birthDate = ""
    var addresses = [RemoteContactAddress]()
    var notes = ""
    var company = ""
    
    var phone: String {
        devices.first(where: { !$0.isDeleted && $0.category == .phone })?.value ?? ""
    }
    
    var initials: String {
        let letters = [firstname, lastname].compactMap { $0.first?.uppercased() }
        return letters.joined()
    }
    
    var phones: [String] {
        devices.filter { $0.category == .phone && !$0.value.isEmpty }.map { $0.value }
    }
    
    var emails: [String] {
        devices.filter { $0.category == .email && !$0.value.isEmpty }.map { $0.value }
    }
    
    override func mapping() {
        id = json?[JsonKey.id].int ?? -1
        name = json?[JsonKey.name].string ?? ""
        firstname = json?[JsonKey.firstname].string ?? ""
        lastname = json?[JsonKey.lastname].string ?? ""
        birthDate = json?[JsonKey.birthDate].string ?? ""
        notes = json?[JsonKey.notes].string ?? ""
        company = json?[JsonKey.company].string ?? ""

        if let devicesJson = json?[JsonKey.devices].array {
            devices = devicesJson.compactMap { RemoteContactDevice(withJSON: $0) }
        }
        
        if let addressesJson = json?[JsonKey.addresses].array {
            addresses = addressesJson.compactMap { RemoteContactAddress(withJSON: $0) }
        }
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
