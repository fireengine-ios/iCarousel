//
//  AnalyticsServiceConstants.swift
//  Depo
//
//  Created by Andrei Novikau on 28.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import FirebaseAnalytics

//enum AnalyticsPackageProductParametrs {
//    case itemName
//    case itemID
//    case price
//    case itemBrand
//    case itemCategory
//    case itemVariant
//    case index
//    case quantity
//
//    var text: String {
//        switch self {
//        case .itemName:
//            return "AnalyticsParameterItemName"
//        case .itemID:
//            return "AnalyticsParameterItemID"
//        case .price:
//            return "AnalyticsParameterPrice"
//        case .itemBrand:
//            return "AnalyticsParameterItemBrand"
//        case .itemCategory:
//            return "AnalyticsParameterItemCategory"
//        case .itemVariant:
//            return "AnalyticsParameterItemVariant"
//        case .index:
//            return "AnalyticsParameterIndex"
//        case .quantity:
//            return "AnalyticsParameterQuantity"
//        }
//    }
//}

enum AnalyticsPackageEcommerce {
    case items
//    case itemList
//    case transactionID
//    case tax
//    case priceValue
//    case shipping
    
    var text: String {
        switch self {
        case .items:
            return "items"
//        case .itemList:
//            return "AnalyticsParameterItemList"
//        case .transactionID:
//            return "AnalyticsParameterTransactionID"
//        case .tax:
//            return "AnalyticsParameterTax"
//        case .priceValue:
//            return "AnalyticsParameterValue"
//        case .shipping:
//            return "AnalyticsParameterShipping"
        }
    }
}

enum GACustomEventKeys {
    case category
    case action
    case label
    case value
    
    var key: String {
        switch self {
        case .category:
            return "eventCategory"
        case .action:
            return "eventAction"
        case .label:
            return "eventLabel"
        case .value:
            return "eventValue"
        }
    }
}

enum GACustomEventsType {
    case event
    case screen
    case purchase
    case selectContent
    
    var key: String {
        switch self {
        case .event:
            return "GAEvent"
        case .screen:
            return "screenView"
        case .purchase:
            return AnalyticsEventEcommercePurchase
        case .selectContent:
            return AnalyticsEventSelectContent
        }
    }
}

enum GAOperationType {
    case hide
    case unhide
    case delete
    case trash
    case restore
    
    var eventActionText: String {
        switch self {
        case .hide:
            return "Hide"
        case .unhide:
            return "Unhide"
        case .delete:
            return "Delete"
        case .trash:
            return "Trash"
        case .restore:
            return "Restore"
        }
    }
    
    var popupEventActionText: String {
        switch self {
        case .hide:
            return "Hide Pop up"
        case .unhide:
            return "Unhide Pop up"
        case .delete:
            return "Delete Permanently Pop up"
        case .trash:
            return "Delete Pop up"
        case .restore:
            return "Restore Pop up"
        }
    }
    
    var confirmPopupEventActionText: String {
        switch self {
        case .hide:
            return "Hide Confirm Pop up"
        case .unhide:
            return "Unhide Confirm Pop up"
        case .delete:
            return "Delete Permanently Confirm Pop up"
        case .trash:
            return "Delete Confirm Pop up"
        case .restore:
            return "Restore Confirm Pop up"
        }
    }
    
    var itemsCountText: String {
        switch self {
        case .hide:
            return "countOfHiddenItems"
        case .unhide:
            return "countOfUnhiddenItems"
        case .delete:
            return "countOfDeletedItems"
        case .trash:
            return "countOfTrashedItems"
        case .restore:
            return "countOfRestoredItems"
        }
    }
    
    var checkingTypes: [GAEventLabel.FileType] {
        switch self {
        case .hide, .unhide:
            return [.photo, .video, .story]
        case .delete, .trash, .restore:
            return [.photo, .video, .story, .music, .document, .folder]
        }
    }
}
