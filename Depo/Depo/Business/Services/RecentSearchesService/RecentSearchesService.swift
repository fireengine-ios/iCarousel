//
//  RecentSearchesService.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 12/18/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import SwiftyJSON

enum SearchCategory: Int {
    case suggestionHeader = 0
    case suggestion
    case recentHeader
    case recent
    case people
    case things
    
    var searchKey: String {
        switch self {
        case .recent: return "kRecentSearchesObjects"
        case .people: return "kRecentSearchesPeople"
        case .things: return "kRecentSearchesThings"
        default:
            return ""
        }
    }
    
    var maxSearches: Int {
        switch self {
        case .recent: return NumericConstants.maxRecentSearchesObjects
        case .people: return NumericConstants.maxRecentSearchesPeople
        case .things: return NumericConstants.maxRecentSearchesThings
        default:
            return 0
        }
    }
    
    init(withSuggestionType type: SuggestionType?) {
        guard let type = type else {
            self = .recent
            return
        }
        
        switch type {
        case .people: self = .people
        case .thing: self = .things
        default:
            self = .recent
        }
    }
}

final class RecentSearchesService {
    
    private let recentSearchesKey = "kRecentSearches"
    
    private(set) var searches = [SearchCategory: [SuggestionObject]]()
    
    static let shared = RecentSearchesService()
    
    private init() {
        searches = loadRecentSearches()
    }
    
    private func loadRecentSearches() -> [SearchCategory: [SuggestionObject]] {
        convertOldSearches()
        
        var result = [SearchCategory: [SuggestionObject]]()
        
        result[.recent] = loadRecentSearches(forCategory: .recent)
        result[.people] = loadRecentSearches(forCategory: .people)
        result[.things] = loadRecentSearches(forCategory: .things)

        return result
    }
    
    private func loadRecentSearches(forCategory category: SearchCategory) -> [SuggestionObject] {
        var result = [SuggestionObject]()
        
        if let data = UserDefaults.standard.object(forKey: category.searchKey) as? Data,
            let objects = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Any] {
            result = objects.map { SuggestionObject(withJSON: JSON($0)) }
        }
        return result
    }
    
    func addSearch(_ searchText: String) {
        guard !searchText.isEmpty else {
            return
        }
        let searchObject = SuggestionObject()
        searchObject.text = searchText
        add(item: searchObject, toCategory: .recent)
    }
    
    func addSearch(item: SuggestionObject) {
        if item.info != nil {
            add(item: item, toCategory: SearchCategory(withSuggestionType: item.type))
        } else {
            add(item: item, toCategory: .recent)
        }
    }
    
    private func add(item: SuggestionObject, toCategory category: SearchCategory) {
        var objects = searches[category] ?? [SuggestionObject]()
        
        if let existingIndex = objects.index(where: { $0.info?.id == item.info?.id && $0.text == item.text }) {
            objects.remove(at: existingIndex)
        } else if objects.count >= category.maxSearches {
            objects.removeLast(1)
        }
        objects.insert(item, at: 0)
        searches[category] = objects
        save(searches: objects, category: category)
    }
    
    private func save(searches: [SuggestionObject], category: SearchCategory) {
        let data = NSKeyedArchiver.archivedData(withRootObject: searches.flatMap { $0.json?.object })
        UserDefaults.standard.set(data, forKey: category.searchKey)
        UserDefaults.standard.synchronize()
    }
    
    private func convertOldSearches() {
        if let recentSearches = UserDefaults.standard.object(forKey: recentSearchesKey) as? [String] {
            recentSearches.forEach({ search in
                self.addSearch(search)
            })
            UserDefaults.standard.set(nil, forKey: recentSearchesKey)
        }
    }
    
    func clearAll() {
        searches[.recent] = []
        searches[.people] = []
        searches[.things] = []
        UserDefaults.standard.set([Data](), forKey: SearchCategory.recent.searchKey)
        UserDefaults.standard.set([Data](), forKey: SearchCategory.people.searchKey)
        UserDefaults.standard.set([Data](), forKey: SearchCategory.things.searchKey)
        UserDefaults.standard.set(nil, forKey: recentSearchesKey)
        UserDefaults.standard.synchronize()
    }
}
