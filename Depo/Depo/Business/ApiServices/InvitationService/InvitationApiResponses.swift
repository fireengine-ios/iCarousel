//
//  InvitationApiResponses.swift
//  Depo
//
//  Created by Alper Kırdök on 10.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

struct InvitationLink: Codable {
    let status: String
    let value: String
}

struct InvitationCampaignResponse: Codable {
    let status: String
    let value: InvitationCampaign
}

struct InvitationCampaign: Codable {
    let locale: String
    let title: String
    let content: String
    let image: String
}

struct InvitationRegisteredResponse: Codable {
    let hasMore: Bool
    let totalAccount: Int
    let accounts: [InvitationRegisteredAccount]
}

struct InvitationRegisteredAccount: Codable {
    let name: String?
    let email: String
}
