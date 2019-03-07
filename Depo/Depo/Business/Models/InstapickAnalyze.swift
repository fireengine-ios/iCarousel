import Foundation
import SwiftyJSON

final class InstapickAnalyze {
    let requestIdentifier: String
    let rank: Float
    let score: Float
    let hashTags: [String]
    let fileInfo: SearchItemResponse?
    let photoCount: Int?
    let startedDate: Date?
    var isPicked: Bool = false
    
    init(requestIdentifier: String, rank: Float, hashTags: [String], fileInfo: SearchItemResponse?, photoCount: Int?, startedDate: Date?, score: Float) {
        self.requestIdentifier = requestIdentifier
        self.rank = rank
        self.score = score
        self.hashTags = hashTags
        self.fileInfo = fileInfo
        self.photoCount = photoCount
        self.startedDate = startedDate
    }
    
    init?(json: JSON) {
        guard
            let requestIdentifier = json["requestIdentifier"].string,
            let rank = json["rank"].float,
            let score = json["score"].float,
            let hashTags = json["hashTags"].array?.flatMap({ $0.string })
            else {
                assertionFailure()
                return nil
        }
        
        self.requestIdentifier = requestIdentifier
        self.rank = rank
        self.score = score
        self.hashTags = hashTags
        
        let fileInfo = json["fileInfo"]
        self.fileInfo = (fileInfo == JSON.null) ? nil : SearchItemResponse(withJSON: fileInfo)
        
        self.photoCount = json["photoCount"].int
        self.startedDate = json["startedDate"].date
    }
    
    func getSmallImageURL() -> URL? {
        return fileInfo?.metadata?.mediumUrl
    }
    
    func getLargeImageURL() -> URL? {
        return fileInfo?.metadata?.largeUrl
    }
}

extension InstapickAnalyze: Equatable {
    static func == (lhs: InstapickAnalyze, rhs: InstapickAnalyze) -> Bool {
        return lhs.requestIdentifier == rhs.requestIdentifier &&
            lhs.hashTags == rhs.hashTags &&
            lhs.rank == rhs.rank &&
            lhs.isPicked == rhs.isPicked &&
            lhs.fileInfo == rhs.fileInfo
    }
}
