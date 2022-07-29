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
    case iconEdit
    case iconInfo
    case iconMove

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
    
    case iconTabFiles
    case iconTabMusic
    case iconTabShare
    case iconTabStar
    case iconFavoriteStar
    case iconMoreActions
    case iconSelectCheck
    case iconSelectEmpty
    case iconSharePeople
    
    case iconProfileCircle
    case iconAddUnselect
    case iconArrowDownSmall
    
    ///  Files sorting
    case iconSizeSmallest
    case iconSizeLargest
    case iconArrowOldest
    case iconArrowNewest
    case iconLetterZA
    case iconLetterAZ
    
    /// People Flow
    case iconPremium
    case iconHideSelect
    case iconBackupContact


    ///  Popup
    case popupIconError
    case popupIconDelete
    case popupIconQuestion
    
    ///For You
    case forYouPeople
    case popupProfileScan
    
    /// User  Info
    case iconDisplaySelected
    ///  UiSwitch
    case gradientSwitch
}
