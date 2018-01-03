//
//  RecentSearchesService.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 12/18/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class RecentSearchesService {
    
    static private let recentSearchesKey = "kRecentSearches"
    private(set) var searches: [String]
    
    static let shared = RecentSearchesService()
    
    private init() {
        searches = RecentSearchesService.loadRecentSearches()
    }
    
    static private func loadRecentSearches() -> [String] {
        if let recentSearches = UserDefaults.standard.object(forKey: recentSearchesKey) as? [String] {
            return recentSearches
        } else {
            let currentYear = Date().getYear()
            let recentSearches = ["\(currentYear)"]
            UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
            return recentSearches
        }
    }
    
    func addSearch(_ search: String) {
        guard search.count > 0 else { return }
        
        if let existingIndex = searches.index(of: search) {
            searches.remove(at: existingIndex)
        } else if searches.count >= NumericConstants.maxRecentSearches {
            searches.removeLast(1)
        }
        
        searches.insert(search, at: 0)
        UserDefaults.standard.set(searches, forKey: RecentSearchesService.recentSearchesKey)
    }
    
    func clearAll() {
        searches = [String]()
        UserDefaults.standard.set(searches, forKey: RecentSearchesService.recentSearchesKey)
    }
}
