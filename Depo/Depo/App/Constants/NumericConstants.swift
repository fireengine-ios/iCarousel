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
    static let numerCellInLineOnIpad: CGFloat = 6
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
    static let setImageAnimationDuration: Double = 0.2
    static let fastAnimationDuration: Double = 0.1
    static let scrollIndicatorAnimationDuration: TimeInterval = 1.8
    
    static let timeIntervalBetweenAutoSyncInBackground: TimeInterval = 0
    
    static let timeIntervalBetweenAutoSyncAfterOutOfSpaceError: TimeInterval = 60 * 60 * 12 // 12 hours
    
    static let freeAppSpaceLimit = 0.2
    
    static let fourGigabytes: UInt64 = 4 * 1024 * 1024 * 1024
    static let hundredMegabytes: UInt64 = 100 * 1024 * 1024
    static let copyVideoBufferSize = 4096 //old 1024 * 1024
    
    static let scaleTransform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
    
    static let maxRecentSearchesObjects: Int = 4
    static let maxRecentSearchesPeople: Int = 6
    static let maxRecentSearchesThings: Int = 6
    static let maxSuggestions: Int = 3  
    
    static let minute: TimeInterval = 60
    static let defaultTimeout: TimeInterval = 30.0
    
    static let faceImageCellTransperentAlpha: CGFloat = 0.6
    
    static let numberCellDefaultOpacity: Float = 0.1
    static let numberCellAnimateOpacity: Float = 1
    
    static let maxNumberOfUploadAttempts = 5
    static let secondsBeetweenUploadAttempts = 5
    
    static let logDuration: TimeInterval = 24 * 60 * 60 * 3
    static let logMaxSize: UInt64 = 5_242_880
    
    static let numberOfLocalItemsOnPage: Int = 100
    static let itemProviderSearchRequest: Int = 1000
    
    static let limitContactsForBackUp: Int = 5000
    static let defaultCustomScrollIndicatorOffset: CGFloat = 50
    
    static let myStreamSliderThumbnailsCount: Int = 4
    
    static let intervalInSecondsBetweenAutoSyncItemsAppending = 8.0
    
    static let intervalInSecondsBetweenAppResponsivenessUpdate: TimeInterval = 3 * 60
    
    static let scaleForPremiumButton: CGFloat = 0.85
    static let defaultScaleForPremiumButton: Double = 1
    static let repeatCountForPremiumButton: Float = 1
    static let delayForStartAnimation: Double = 3
    static let durationBetweenAnimation: CFTimeInterval = 3
    static let repeatCountForAnimation: Float = 10000000
    static let initialVelocityForAnimation: CGFloat = 0.3
    static let dampingForAnimation: CGFloat = 0.3
    static let speedForAnimation: Float = 1.7
    static let durationAnimationForPremiumButton: Double = 0.5

    static let timeIntervalForPremiumFeaturesView: TimeInterval = 2
    static let imageViewSizeForPremiumFeaturesView: CGFloat = 46
    static let transitionDurationForPremiumFeaturesView: TimeInterval = 1

    static let alphaForColorsPremiumButton: CGFloat = 0.85

    static let packageViewCornerRadius: CGFloat = 5
    static let packageViewShadowOpacity: Float = 1
    static let packageViewMainShadowRadius: CGFloat = 3
    static let packageViewBottomViewShadowRadius: CGFloat = 2
    static let iPadPackageSumInset: CGFloat = 24
    static let packageSumInset: CGFloat = 15
    static let heightForPackageCell: CGFloat = 255
    
    static let premiumViewHeight: CGFloat = 508
    static let plusPremiumViewHeightForTurkcell: CGFloat = 30
    
    static let instaPickSelectionSegmentedTransparentGradientViewHeight: CGFloat = 130
    static let instaPickHashtagCellHeight: CGFloat = 35
    static let instaPickHashtagCellWidthConstant: CGFloat = 45
    
    static let instaPickHashtagCellCornerRadius: CGFloat = 12
    static let instaPickHashtagCellBorderWidth: CGFloat = 0.2
    static let instaPickHashtagCellShadowRadius: CGFloat = 5
    
    static let instaPickHashtagCellShadowColorAlpha: CGFloat = 0.11
    static let instaPickHashtagCellBorderColorAlpha: CGFloat = 0.15
    
    static let instaPickDetailsPopUpCornerRadius: CGFloat = 2
    
    static let instaPickImageViewTransitionDuration: TimeInterval = 0.25
    
    static let instapickTimeoutForAnalyzePhotos: TimeInterval = 5
    
    static let usageInfoCardCornerRadius: CGFloat = 12
    static let usageInfoCardShadowRadius: CGFloat = 8
    static let usageInfoCardShadowOpacity: Float = 0.5
    
    static let usageInfoProgressWidth: CGFloat = 8
    
    static let usageInfoCollectionViewCellsOffset: CGFloat = 0

    static let progressViewBackgroundColorAlpha: CGFloat = 0.25
    
    static let maxStringLengthForUserProfile = 255
    
    static let profileStackViewHiddenSubtitleSpacing: CGFloat = 8
    static let profileStackViewShowSubtitleSpacing: CGFloat = 2
    static let firstResponderBottomOffset: CGFloat = 50
}

struct RequestSizeConstant {
    static let faceImageItemsRequestSize = 100
    static let quickScrollRangeApiPageSize = Device.isIpad ? 128 : 32
    
}
