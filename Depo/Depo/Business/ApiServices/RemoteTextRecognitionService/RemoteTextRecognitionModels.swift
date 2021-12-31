//
//  RemoteTextRecognitionModels.swift
//  Depo
//
//  Created by Hady on 12/27/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

/// Endpoint: `ocr/process`
typealias RemoteTextRecognitionResponse = APIResponse<[RemoteTextRecognitionModel]>

// MARK: - RemoteTextRecognitionModel
struct RemoteTextRecognitionModel: Codable {
    let width: CGFloat
    let height: CGFloat
    let words: [RemoteRecognizedWord]

    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let optikResponse = try root.nestedContainer(keyedBy: CodingKeys.self, forKey: .optikResponse)
        let shape = try optikResponse.nestedContainer(keyedBy: CodingKeys.self, forKey: .shape)
        var textWithPositions = try optikResponse.nestedUnkeyedContainer(forKey: .textWithPositions)
        let wordList = try? textWithPositions.nestedContainer(keyedBy: CodingKeys.self)

        width = try shape.decode(Double.self, forKey: .width)
        height = try shape.decode(Double.self, forKey: .height)
        words = (try wordList?.decode([RemoteRecognizedWord].self, forKey: .wordList)) ?? []
    }

    func encode(to encoder: Encoder) throws {
        // no-op
    }
}

// MARK: - RemoteRecognizedWord
struct RemoteRecognizedWord: Codable {
    let x1, x2, y1, y2: Int
    let x3, y3, x4, y4: Int
    let text: String
}


private enum CodingKeys: String, CodingKey {
    case optikResponse = "optik_response"
    case shape
    case textWithPositions = "text_with_positions"
    case wordList = "optik_response_position_item_list"

    case width
    case height
}
