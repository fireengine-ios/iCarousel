//
//  PhotopickCampaignResponse.swift
//  Depo
//
//  Created by Hady on 7/1/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

/// Endpoint: `campaign/photopick/v2`
typealias PhotopickCampaignResponse = APIResponse<PhotopickCampaign>

// MARK: - PhotopickCampaign
struct PhotopickCampaign: Codable {
    let detailsURL: String
    let imageURL: String
    let content: Content
    let usage: Usage
    let dates: Dates
    let text: Text

    enum CodingKeys: String, CodingKey {
        case detailsURL = "detailsUrl"
        case imageURL = "imageUrl"
        case content, usage, dates, text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        detailsURL = try container.decode(String.self, forKey: .detailsURL)
        imageURL = try container.decode(String.self, forKey: .imageURL)

        content = try container.decode(Content.self, forKey: .content)
        usage = try container.decodeIfPresent(Usage.self, forKey: .usage) ?? Usage()
        dates = try container.decode(Dates.self, forKey: .dates)
        text = try container.decodeIfPresent(Text.self, forKey: .text) ?? Text()

        // Below logic moved from FE-2366
        // for messageType == .client usage fields are required
        if content.messageType == .client && usage.allNils {
            let message = "Usage fields are required when content.messageType == .client"
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.usage, in: container, debugDescription: message)
        }
    }
}

// MARK: - Subtypes
extension PhotopickCampaign {
    // MARK: Content
    struct Content: Codable {
        let messageType: MessageType
        let title: String?
        let message: String?
        let detailsText: String?
    }

    enum MessageType: String, Codable {
        case backend = "BACKEND"
        case client = "CLIENT"
        case unknown

        init(from decoder: Decoder) throws {
            let rawValue = try decoder.singleValueContainer().decode(String.self)
            self = Self(rawValue: rawValue) ?? .unknown
        }
    }

    // MARK: Usage
    struct Usage: Codable {
        private let _totalUsed, _maxDailyLimit, _dailyUsed, _dailyRemaining: Int?

        var totalUsed: Int { _totalUsed ?? 0 }
        var maxDailyLimit: Int { _maxDailyLimit ?? 0 }
        var dailyUsed: Int { _dailyUsed ?? 0 }
        var dailyRemaining: Int { _dailyRemaining ?? 0 }

        var allNils: Bool {
            _totalUsed == nil && _maxDailyLimit == nil &&
            _dailyUsed == nil && _dailyRemaining == nil
        }

        enum CodingKeys: String, CodingKey {
            case _totalUsed = "totalUsed"
            case _maxDailyLimit = "maxDailyLimit"
            case _dailyUsed = "dailyUsed"
            case _dailyRemaining = "dailyRemaining"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _totalUsed = try container.decodeIfPresent(Int.self, forKey: ._totalUsed) ?? 0
            _maxDailyLimit = try container.decodeIfPresent(Int.self, forKey: ._maxDailyLimit) ?? 0
            _dailyUsed = try container.decodeIfPresent(Int.self, forKey: ._dailyUsed) ?? 0
            _dailyRemaining = try container.decodeIfPresent(Int.self, forKey: ._dailyRemaining) ?? 0
        }

        fileprivate init() {
            _totalUsed = nil
            _maxDailyLimit = nil
            _dailyUsed = nil
            _dailyRemaining = nil
        }
    }

    // MARK: Dates
    struct Dates: Codable {
        let startDate, endDate, launchDate: Date
    }

    // MARK: Text
    struct Text: Codable {
        let description: String?
        let steps: [String]
        let inform: String?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            steps = try container.decodeIfPresent([String].self, forKey: .steps) ?? []
            inform = try container.decodeIfPresent(String.self, forKey: .inform)
        }

        fileprivate init() {
            description = nil
            steps = []
            inform = nil
        }
    }
}
