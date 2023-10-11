//
//  AdressResponse.swift
//  Depo
//
//  Created by Ozan Salman on 18.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

struct AddressResponse: Codable {
    let id: Int
    let name, recipientName, msisdn, apartmentNumber: String
    let buildingNumber, neighbourhood, street: String
    let addressDistrict, addressCity: Address
    let postalCode: Int
    let saveStatus: Bool
    let createdDate: Int
    let addressResponseDefault: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, recipientName, msisdn, apartmentNumber, buildingNumber, neighbourhood, street, addressDistrict, addressCity, postalCode, saveStatus, createdDate
        case addressResponseDefault = "default"
    }
}

// MARK: - Address
struct Address: Codable {
    let id: Int
    let name: String
}
