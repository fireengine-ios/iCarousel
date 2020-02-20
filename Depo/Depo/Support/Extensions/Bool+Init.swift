import Foundation

extension Bool {
    init?(string: String) {
        /// simple realization for api responses
        switch string {
        case "true":
            self.init(true)
        case "false":
            self.init(false)
        default:
            return nil
        }
        /// https://stackoverflow.com/a/28107487/5893286
        //        switch self.lowercased() {
        //        case "true", "t", "yes", "y", "1":
        //            return true
        //        case "false", "f", "no", "n", "0":
        //            return false
        //        default:
        //            return nil
        //        }
    }
    
    var reversed: Bool {
        return !self
    }
}

extension Optional where Wrapped == Bool {
    var reversed: Bool {
        return !(self ?? false)
    }
}
