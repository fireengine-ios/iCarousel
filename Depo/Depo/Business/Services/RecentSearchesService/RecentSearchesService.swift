//
//  RecentSearchesService.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 12/18/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class RecentSearchesObject: NSObject, NSCoding {
   
    var text: String?
    var type: SuggestionType?
    
    init(withText text: String?, type: SuggestionType?) {
        self.text = text
        self.type = type
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text ?? "", forKey: "text")
        aCoder.encode(type?.rawValue ?? "", forKey: "type")
    }
    
    init?(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObject(forKey: "text") as? String
        if let type = aDecoder.decodeObject(forKey: "type") as? String {
            self.type = SuggestionType(rawValue: type)
        }
    }    
}

final class RecentSearchesService {
    
    private let recentSearchesKey = "kRecentSearches"
    private let recentSearchesObjectsKey = "kRecentSearchesObjects"
    private(set) var searches: [RecentSearchesObject] = []
    
    static let shared = RecentSearchesService()
    
    private init() {
        searches = loadRecentSearches()
    }
    
    private func loadRecentSearches() -> [RecentSearchesObject] {
        convertOldSearches()
        
        var result = [RecentSearchesObject]()
        
        if let data = UserDefaults.standard.object(forKey: recentSearchesObjectsKey) as? Data,
            let recentSearchesObjects = NSKeyedUnarchiver.unarchiveObject(with: data) as? [RecentSearchesObject] {
            result.append(contentsOf: recentSearchesObjects)
        }

        if result.isEmpty {
            let currentYear = Date().getYear()
            result = [RecentSearchesObject(withText: "\(currentYear)", type: .time)]
            save(searches: result)
        }
        return result
    }
    
    func addSearch(_ searchText: String, type: SuggestionType?) {
        guard !searchText.isEmpty else {
            return
        }
        
        if let existingIndex = searches.index(where: {$0.text == searchText}) {
            searches.remove(at: existingIndex)
        } else if searches.count >= NumericConstants.maxRecentSearches {
            searches.removeLast(1)
        }
        let searchObject = RecentSearchesObject(withText: searchText, type: type)
        searches.insert(searchObject, at: 0)
        save(searches: searches)
    }

    
    private func save(searches: [RecentSearchesObject]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: searches)
        UserDefaults.standard.set(data, forKey: recentSearchesObjectsKey)
        UserDefaults.standard.synchronize()
    }
    
    private func convertOldSearches() {
        if let recentSearches = UserDefaults.standard.object(forKey: recentSearchesKey) as? [String] {
            recentSearches.forEach({ search in
                self.addSearch(search, type: nil)
            })
            UserDefaults.standard.set(nil, forKey: recentSearchesKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func clearAll() {
        searches = [RecentSearchesObject]()
        UserDefaults.standard.set(searches, forKey: recentSearchesObjectsKey)
        UserDefaults.standard.set(nil, forKey: recentSearchesKey)
        UserDefaults.standard.synchronize()
    }
}
