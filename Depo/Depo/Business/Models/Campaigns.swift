//
//  Campaigns.swift
//  Depo
//
//  Created by Rustam on 12.06.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

// MARK: - Campaign
//struct Campaign: Codable {
//    let id: Int?
//    let imagePath, detailImagePath: String?
//    let conditionImagePath: String?
//    let title, name, description: String?
//    let startDate, endDate: Int?
//    let extraData: ExtraData?
//}
//
//// MARK: - ExtraData
//struct ExtraData: Codable {
//    let buttons: [Button]?
//}
//
//// MARK: - Button
//struct Button: Codable {
//    let text, url, action: String?
//}

struct Campaign: Codable {
    let id: Int
    let imagePath: String
    let detailImagePath: String
    let conditionImagePath: String?
    let title: String
    let name: String
    let description: String
    let startDate: Int
    let endDate: Int
    let extraData: ExtraData?
    
    struct ExtraData: Codable {
        let buttons: Buttons?
        
        struct Buttons: Codable {
            let button: [Button]
            
            struct Button: Codable {
                let id: String
                let text: [String: String]
                let action: String
                let web_view: Bool
                let url: String
                let auth_needed: Bool
                let api_body: String?
            }
        }
    }
}
