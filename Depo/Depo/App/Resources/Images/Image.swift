//
//  Image.swift
//  Depo
//
//  Created by Hady on 4/27/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

enum Image: String, AppImage {
    case quickScrollBarHandle
    case iconThreeDotsHorizontal
    case iconCheckmarkNotSelected
    case iconCheckmarkSelected
    case iconSyncStatusSynced
    case iconSyncStatusNotSynced
    case iconSyncStatusFailed
    case iconSyncStatusQueued
    case iconPlay
    case iconArrowDown
    case iconNetworkWifi
    case iconNetworkLTE
    case iconInfoDeleteAccount
    
    /// Actions
    case iconShare
    case iconDownload
    case iconBackupBordered
    case iconDelete
    case iconFavorite
    case iconStory
    case iconPrint
    case iconAddToAlbum
    case iconCamera
    case iconFileUpload
    case iconUploadPhoto
    case iconFolderCreate
    case iconSelect
    case iconUnShare
    case iconSend
    case iconCopy
    case iconChangePhoto
    case iconChangePerson
    case iconAll
    case iconVideo
    case iconGalleryPhoto
    case iconBackupCheck
    case iconBackupUncheck
    case iconEdit
    case iconInfo
    case iconMove
    case iconAlbum
    case iconUnstar
    case iconErrorRed
    /// Actions/Function Menu
    case iconFilter
    case iconGif
    case iconSettingsFilter
    case iconSticker
    case iconColor
    case iconEffect
    case iconLight
    case iconAdjust
    case iconSize
    case iconMix
    case iconRotate
    case iconOcr
    case iconDeletePlain
    /// Action/Small
    case iconRadioButtonSelect
    case iconRadioButtonUnselect
    case iconRadioButtonSelectBlue
    case iconCheckBlue
    case iconArrowLeftSmall
    case iconArrowRightsmall
    case leftCircleArrow
    case rightCircleArrow
    /// Action/Header
    case iconKebabBorder
    case iconViewGrid
    case iconViewList
    case iconHideSee
    case iconHideUnselect
    case iconAddSelect
    /// Action/Snack
    case iconArrowDownSmall
    case iconArrowUpSmall
    case iconArrowDownDisable
    /// Action/SelectUnselect
    case iconCancelBorder
    case iconSelectCheck
    case iconSelectEmpty
    case iconSelectFills
    case iconCircleCancel
    /// Action/Music
    case iconPauseRed
    case iconPlayRed
    case iconPause
    case iconPlay40x40
    case iconPlayLowSound
    case iconPlayMix
    case iconPlayNext
    case iconPlayPre
    case iconPlayThumb
    case iconSound
    case iconPause40x40Red
    case iconMusicPlayerNoImage
    /// Action/Tab
    case iconTabMusicEmpty
    case iconTabMusic
    case iconTabFiles
    case iconTabShare
    case iconTabStar
    case iconTabDelete
    ///NoImage/PhotoPick
    case iconPickNoAlbums
    case iconPickNoFavorites
    case iconPickNoPhotos
    ///Switch
    case iconSwitchToggleOn
    case iconSwitchToggleOff
    
    ///  Files Tab
    case iconFileAudio
    case iconFileDoc
    case iconFileEmpty
    case iconFilePdf
    case iconFilePhoto
    case iconFilePpt
    case iconFileRar
    case iconFileTxt
    case iconFileVideo
    case iconFileXls
    case iconFileZip
    case iconFolder
    case iconMusic
    
    case iconFileAudioBig
    case iconFileDocBig
    case iconFileEmptyBig
    case iconFilePdfBig
    case iconFilePhotoBig
    case iconFilePptBig
    case iconFileRarBig
    case iconFileTxtBig
    case iconFileVideoBig
    case iconFileXlsBig
    case iconFileZipBig
    case iconFolderBig
    case iconMusicBig
    
    case iconFavoriteStar
    case iconMoreActions
    case iconSharePeople
    
    case iconProfileCircle
    case iconAddUnselect
    
    case popupDocuments
    case popupFavorites
    case popupShared
    case popupMusic
    case popupMemories
    
    ///  Files sorting
    case iconSizeSmallest
    case iconSizeLargest
    case iconArrowOldest
    case iconArrowNewest
    case iconLetterZA
    case iconLetterAZ
    
    /// People Flow
    case iconPremium
    case iconBackupContact

    /// Popup
    case popupIconError
    case popupIconDelete
    case popupIconQuestion
    case popupHide
    case iconCancelUnborder
    case popupUnHide
    case popupRestore
    case popupLogout
    
    /// For You
    case forYouPeople
    case popupProfileScan
    case popupLoading
    case createCollageThumbnail
    
    /// Settings
    case gradientSwitch
    case settingsIconCancel
    case iconTabInstagramPink
    case iconBackupContactMain
    case iconDuplicateContact
    case contact_phone
    case contact_email
    case contact_address
    case contactPeople
    
    /// Discover
    case popupCloudBackup
    case launchCampaign
    case divorceCardPlay
    
    /// Introduce
    case circleIntoduce
    
    /// Forget My Password
    case forgetPassPopupLock

    /// Gallery
    case popupNoMemories
    case popupNoVideo
    case popupSuccessful
    case popupUnsync
    case iconPhotosPlaceholder
    case iconVideosPlaceholder
    case iconStoryGroup

}
