//
//  NetmeraEventValues.swift
//  Depo
//
//  Created by Alex on 1/10/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum NetmeraEventValues {
    
    enum GeneralStatus {
        case success
        case failure

        var text: String {
            switch self {
            case .success:
                return "Success"
            case .failure:
                return "Failure"
            }
        }
    }
    
    enum LoginType {
        case turkcell
        case phone
        case email
        case rememberMe
        
        var text: String {
            switch self {
            case .turkcell:
                return "Header Enrichment ile giriş"
            case .phone:
                return "GSM no ile şifreli giriş"
            case .email:
                return "Email ile giriş"
            case .rememberMe:
                return "Beni hatırla ile giriş"
            }
        }
    }
    
    enum AutoSyncState {
        case never
        case wifi
        case wifi_LTE
        
        var text: String {
            switch self {
            case .never:
                return "Never"
            case .wifi:
                return "Wifi"
            case .wifi_LTE:
                return "Wifi_LTE"
            }
        }
        
        static func getState(autosyncSettings: AutoSyncSetting) -> AutoSyncState {
            switch autosyncSettings.option {
            case .never:
                return .never
            case .wifiOnly:
                return .wifi
            case .wifiAndCellular:
                return .wifi_LTE
            }
            
        }
    }
    
    enum EmailVerification {
        case verified
        case notVerified
        
        var text: String {
            switch self {
            case .verified:
                return "Verified"
            case .notVerified:
                return "NotVerified"
            }
        }
    }

    enum OnOffSettings: String {
        case on
        case off
        
        var text: String {
            switch self {
            case .on:
                return "On"
            case .off:
                return "Off"
            }
        }
    }

    enum UploadFileType {
        case photo
        case video
        case document
        case music
        
        var text: String {
            switch self {
            case .photo:
                return "Photo"
            case .video:
                return "Video"
            case .document:
                return "Document"
            case .music:
                return "Music"
            }
        }
    }
    
    enum UploadType {
        case manual
        case autosync
        case background
        
        var text: String {
            switch self {
            case .manual:
                return "Manual"
            case .autosync:
                return "Autosync"
            case .background:
                return "Background"
            }
        }
    }
    
    enum ImportChannelType {
        case spotify
        case instagram
        case facebook
        case dropbox
        
        var text: String {
            switch self {
            case .spotify:
                return "Spotify"
            case .instagram:
                return "Instagram"
            case .facebook:
                return "Facebook"
            case .dropbox:
                return "Dropbox"
            }
        }
    }
    
    enum ContactBackupType {
        case backup
        case restore
        case deleteDuplicate
        case deleteBackup
        
        var text: String {
            switch self {
            case .backup:
                return "Backup"
            case .restore:
                return "Restore"
            case .deleteDuplicate:
                return "DeleteDuplicate"
            case .deleteBackup:
                return "DeleteBackup"
            }
        }
    }
    
    enum PhotopickUserAnalysisLeft {
        case premium
        case regular(analysisLeft: Int?)
        
        var text: String {
            switch self {
            case .premium:
                return "Free"
            case .regular(let analysisLeft):
                guard let analysisLeft = analysisLeft else {
                    return "null"
                }
                return "\(analysisLeft)"
            }
        }
    }
    
    enum DownloadType {
        case music
        case document
        case photo
        case video
        case album
        
        var text: String {
            switch self {
            case .music:
                return "Music"
            case .document:
                return "Document"
            case .photo:
                return "Photo"
            case .video:
                return "Video"
            case .album:
                return "Album"
            }
        }
    }
    
    ///same for delete
    enum TrashType {
        case photo
        case video
        case person
        case thing
        case place
        case album
        case document
        case music
        case folder

        var text: String {
            switch self {
            case .photo:
                return "Photo"
            case .video:
                return "Video"
            case .person:
                return "Person"
            case .thing:
                return "Thing"
            case .place:
                return "Place"
            case .album:
                return "Album"
            case .document:
                return "Document"
            case .music:
                return "Music"
            case.folder:
                return "Folder"
            }
        }
    }
    
    ///same for delete
    enum RestoredType {
        case photo
        case video
        case person
        case thing
        case place
        case album
        case document
        case music
        case folder

        var text: String {
            switch self {
            case .photo:
                return "Photo"
            case .video:
                return "Video"
            case .person:
                return "Person"
            case .thing:
                return "Thing"
            case .place:
                return "Place"
            case .album:
                return "Album"
            case .document:
                return "Document"
            case .music:
                return "Music"
            case.folder:
                return "Folder"
            }
        }
    }
    
    enum ShareMethodType {
        case smallSize
        case originalSize
        case link
        
        var text: String {
            switch self {
            case .smallSize:
                return "SmallSize"
            case .originalSize:
                return "OriginalSize"
            case .link:
                return "Link"
            }
        }
    }
    
    enum ShareChannelType {
        case facebook
        case instagram
        case whatsapp
        case bip
        case messages
        case mail
        
        var text: String {
            switch self {
            case .facebook:
                return "Facebook"
            case .instagram:
                return "Instagram"
            case .whatsapp:
                return "Whatsapp"
            case .bip:
                return "BİP"
            case .messages:
                return "Messages"
            case .mail:
                return "Mail"
            }
        }
    }
    
    enum PackageChannelType {
        case chargeToBill
        case inAppStorePurchase
        case creditCard
        
        var text: String {
            switch self {
            case .chargeToBill:
                return "ChargeToBill"
            case .inAppStorePurchase:
                return "InAppStorePurchase"
            case .creditCard:
                return "CreditCard"
            }
        }
    }
    
    enum AppPermissionType {
        case gallery
        case location
        case notification
        case contact
        
        var text: String {
            switch self {
            case .gallery:
                return "Gallery"
            case .location:
                return "Location"
            case .notification:
                return "Notification"
            case .contact:
                return "Contact"
            }
        }
    }

    enum AppPermissionStatus {
        case granted
        case notGranted
        
        var text: String {
            switch self {
            case .granted:
                return "Granted"
            case .notGranted:
                return "NotGranted"
            }
        }
    }
    
    enum AppPermissionValue {
        case always
        case never
        case inUse
        case allowOnce
        
        var text: String {
            switch self {
            case .always:
                return "Always"
            case .never:
                return "Never"
            case .inUse:
                return "InUse"
            case .allowOnce:
                return "AllowOnce"
            }
        }
    }
    
    enum SmashAction {
        case save
        case cancel
        
        var text: String {
            switch self {
            case .save:
                return "Save"
            case .cancel:
                return "Cancel"
            }
        }
    }

    enum HideUnhideObjectType {
        case photo
        case video
        case person
        case thing
        case place
        case album
        
        var text: String {
            switch self {
            case .photo:
                return "Photo"
            case .video:
                return "Video"
            case .person:
                return "Person"
            case .thing:
                return "Thing"
            case .place:
                return "Place"
            case .album:
                return "Album"
            }
        }
    }
    
    enum ButtonName {
        case freeUpSpace
        case deleteDuplicate
        case spotifyImport
        case instagramImport
        case facebookImport
        case dropboxImport
        case print
        case uploadFromPlus
        case share
        case download
        case edit
        case delete
        case addToAlbum
        case addToFavorites
        case removeFromFavorites
        case info
        case hide
        case unhide
        case restore
        case hiddenBin
        case trashBin
        case endSharing
   
        var text: String {
            switch self {
            case .freeUpSpace:
                return "Freeupspace"
            case .deleteDuplicate:
                return "Delete Duplicate"
            case .spotifyImport:
                return "Spotify Import"
            case .instagramImport:
                return "Instagram Import"
            case .facebookImport:
                return "Facebook Import"
            case .dropboxImport:
                return "Dropbox Import"
            case .print:
                return "Print"
            case .uploadFromPlus:
                return "Upload"
            case .share:
                return "Share"
            case .download:
                return "Download"
            case .edit:
                return "Edit"
            case .delete:
                return "Delete"
            case .addToAlbum:
                return "AddToAlbum"
            case .addToFavorites:
                return "AddToFavorites"
            case .removeFromFavorites:
                return "RemoveFromFavorites"
            case .info:
                return "Info"
            case .hide:
                return "Hide"
            case .unhide:
                return "Unhide"
            case .restore:
                return "Restore"
            case .hiddenBin:
                return "Hidden bin"
            case .trashBin:
                return "Trash bin"
            case .endSharing:
                return "End sharing"
            }
        }
    }

    enum AccountType {
        case standart
        case standartPlus
        case premium
        
        var text: String {
            switch self {
            case .standart:
                return " Standard"
            case .standartPlus:
                return "Standard+"
            case .premium:
                return "Premium"
            }
        }
    }
    
    enum PlusButtonAction {
        case useCamera
        case upload
        case uploadFiles
        case uploadMusic
        case createStory
        case newFolder
        case createAlbum
        case uploadFromLifebox
        case importFromSpotify
        
        var text: String {
            switch self {
            case .useCamera:
                return "Use Camera"
            case .upload:
                return "Upload"
            case .uploadFiles:
                return "Upload Files"
            case .uploadMusic:
                return "Upload Music"
            case .createStory:
                return "Create Story"
            case .newFolder:
                return "New Folder"
            case .createAlbum:
                return "Create Album"
            case .uploadFromLifebox:
                return "Upload from Lifebox"
            case .importFromSpotify:
                return "Import From Spotify"
            }
        }
    }
    
    enum PeriodicContactSyncType {
        case daily
        case weekly
        case monthly
        
        var text: String {
            switch self {
            case .daily:
                return "Daily"
            case .weekly:
                return "Weekly"
            case .monthly:
                return "Monthly"
            }
        }
    }
    
    enum PhotoEditAdjustmentType {
        case adjust
        case light
        case color
        case hsl
        case effect
        
        var text: String {
            switch self {
            case .adjust:
                return "Adjust"
            case .light:
                return "Light"
            case .color:
                return "Color"
            case .hsl:
                return "Color-HSL"
            case .effect:
                return "Effect"
            }
        }
    }
    
    enum PhotoEditActionType {
        case save
        case saveAsCopy
        
        var text: String {
            switch self {
            case .save:
                return "Save"
            case .saveAsCopy:
                return "Save as copy"
            }
        }
    }
    
    enum PhotoEditType {
        case filter
        case adjustment
        
        var text: String {
            switch self {
            case .filter:
                return "Filter"
            case .adjustment:
                return "Adjust"
            }
        }
    }
    
    enum PhotoEditButton {
        case save
        case saveAsCopy
        case resetToOriginal
        case cancel
        
        var text: String {
            switch self {
            case .save:
                return "Save"
            case .saveAsCopy:
                return "Save as copy"
            case .resetToOriginal:
                return "Reset to original"
            case .cancel:
                return "Cancel"
            }
        }
    }
}
