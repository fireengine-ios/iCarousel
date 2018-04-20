//
//  NumericConstants.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/10/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import CoreGraphics

struct NumericConstants {
    
    static let vereficationCharacterLimit = 6
    static let vereficationTimerLimit = 120//in seconds
    static let maxVereficationAttempts = 3
    
    static let maxDetailsLoadingAttempts = 5
    static let detailsLoadingTimeAwait = UInt32(2)
    
    static let countOfLoginBeforeNeedShowUploadOffPopUp = 3
    
    static let numerCellInLineOnIphone: CGFloat = 4
    static let numerCellInDocumentLineOnIphone: CGFloat = 2
    static let iPhoneGreedInset: CGFloat = 2
    static let iPhoneGreedHorizontalSpace: CGFloat = 1
    static let iPadGreedInset: CGFloat = 2
    static let iPadGreedHorizontalSpace: CGFloat = 1
    static let numerCellInLineOnIpad: CGFloat = 8
    static let numerCellInDocumentLineOnIpad: CGFloat = 4
    static let maxNumberPhotosInStory: Int = 20
    static let maxNumberAudioInStory: Int = 1
    static let creationStoryOrderingCountPhotosInLineiPhone: Int = 4
    static let creationStoryOrderingCountPhotosInLineiPad: Int = 6
    static let albumCellListHeight: CGFloat = 100
    static let albumCellGreedHeight: CGFloat = 121
    static let albumCellGreedWidth: CGFloat = 100
    static let storiesCellGreedHeight: CGFloat = 100
    
    static let  heightTextAlbumCell: CGFloat = 21
    static let amountInsetForStoryAlbum: CGFloat = 10
    static let amountInsetForAlbum: CGFloat = 3
    
    static let numberOfElementsInSyncRequest: Int = 30000
    
    static let animationDuration: Double = 0.3
    static let fastAnimationDuration: Double = 0.1
    static let scrollIndicatorAnimationDuration: TimeInterval = 1.8
    
    static let timeIntervalBetweenAutoSyncInBackground: TimeInterval = 0
    
    static let timeIntervalBetweenAutoSyncAfterOutOfSpaceError: TimeInterval = 60 * 60 * 12 // 12 hours
    
    static let freeAppSpaceLimit = 0.2
    
    static let fourGigabytes: UInt64 = 4 * 1024 * 1024 * 1024
    static let copyVideoBufferSize = 1024 * 1024
    
    static let scaleTransform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
    
    static let maxRecentSearchesObjects: Int = 4
    static let maxRecentSearchesPeople: Int = 6
    static let maxRecentSearchesThings: Int = 6
    static let maxSuggestions: Int = 3  
    
    static let minute: TimeInterval = 60
    static let defaultTimeout: TimeInterval = 300.0
    
    static let faceImageCellTransperentAlpha: CGFloat = 0.6
    
    static let numberCellDefaultOpacity: Float = 0.1
    static let numberCellAnimateOpacity: Float = 1
    
    static let maxNumberOfUploadAttempts = 5
    static let secondsBeetweenUploadAttempts = 5
    
    static let emptyEmailUserCloseLimit = 3
    
    static let logDuration: TimeInterval = 24 * 60 * 60 * 3
    static let logMaxSize: UInt64 = 5_242_880
    
    static let numberOfLocalItemsOnPage: Int = 100
    
    static let limitContactsForBackUp: Int = 5000
    static let defaultCustomScrollIndicatorOffset: CGFloat = 50
}

struct RequestSizeConstant {
    
    static let faceImageItemsRequestSize = 100
    
}
