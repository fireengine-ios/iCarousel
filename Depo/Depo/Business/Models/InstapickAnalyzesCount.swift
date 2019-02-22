import Foundation
import SwiftyJSON

final class InstapickAnalyzesCount {
    let left: Int
    let total: Int
    let isFree: Bool
    let used: Int
    
    init(left: Int, total: Int, isFree: Bool) {
        self.left = left
        self.total = total
        self.isFree = isFree
        self.used = total - left
    }
    
    init?(json: JSON) {
        ///there is "used" key from server response. it is "total - remaining"
        guard
            let left = json["remaining"].int,
            let total = json["total"].int,
            let isFree = json["isFree"].bool
            else {
                assertionFailure()
                return nil
        }
        
        self.left = left
        self.total = total
        self.isFree = isFree
        self.used = total - left
    }
}
