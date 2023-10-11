//
//  CreateOrderResponse.swift
//  Depo
//
//  Created by Ozan Salman on 22.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

struct CreateOrderResponse: Codable {
    let requestID, recipientName, recipientMsisdn, recipientAddress: String
    let itemQuantity: Int
    let status: String
    let createdDate: Int

    enum CodingKeys: String, CodingKey {
        case requestID = "requestId"
        case recipientName, recipientMsisdn, recipientAddress, itemQuantity, status, createdDate
    }
}
