//
//  NetmeraScreenEvents.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents.Screens {
    
    final class NetmeraPhotoPickAnalysisDetailScreenEvent: NetmeraEvent {
        
        private let kPhotoPickAnalysisDetailScreenKey = "hup"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kPhotoPickAnalysisDetailScreenKey
        }
    }
    
    final class NetmeraAutoSyncScreenEvent: NetmeraEvent {
        
        private let kAutoSyncScreenKey = "mwv"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kAutoSyncScreenKey
        }
    }
    
    final class NetmeraPackagesScreenEvent: NetmeraEvent {
        
        private let kPackagesScreenKey = "wss"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kPackagesScreenKey
        }
    }

    final class NetmeraStoriesScreenEvent: NetmeraEvent {
         
         private let kStoriesScreenKey = "pvg"
         
         override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
             return [:]
         }
         
         override var eventKey : String {
             return kStoriesScreenKey
         }
     }
    
    final class NetmeraPlacesScreenEvent: NetmeraEvent {
        
        private let kPlacesScreenKey = "ots"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kPlacesScreenKey
        }
    }
    
    
    
    
    

    
    
    final class OTPDoubleOptInScreen: NetmeraEvent {
        
        private let kOTPDoubleOptInScreenKey = "mda"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kOTPDoubleOptInScreenKey
        }
    }
    
    final class ManualUploadScreen: NetmeraEvent {
        
        private let kManualUploadScreenKey = "adq"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kManualUploadScreenKey
        }
    }
    
    final class DocumentsScreen: NetmeraEvent {
        
        private let kDocumentsScreenKey = "tzv"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kDocumentsScreenKey
        }
    }
    
    final class SearchScreen: NetmeraEvent {
        
        private let kSearchScreenKey = "udf"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kSearchScreenKey
        }
    }
    
    final class CreateStoryPhotoSelectionScreen: NetmeraEvent {
        
        private let kCreateStoryPhotoSelectionScreeKey = "dsf"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kCreateStoryPhotoSelectionScreeKey
        }
    }
    
    final class VideosScreen: NetmeraEvent {
        
        private let kVideosScreenKey = "qdm"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kVideosScreenKey
        }
    }
    
    final class ProfileEditScreen: NetmeraEvent {
        
        private let kProfileEditScreenKey = "xbg"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kProfileEditScreenKey
        }
    }
    
    final class CreateStoryMusicSelectionScreen: NetmeraEvent {
        
        private let kCreateStoryMusicSelectionScreeKey = "img"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kCreateStoryMusicSelectionScreeKey
        }
    }
    
    final class PremiumDetails: NetmeraEvent {
        
        private let kPremiumDetailsKey = "iuo"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kPremiumDetailsKey
        }
    }
    
    final class RestoreConfirmPopUp: NetmeraEvent {
        
        private let kRestoreConfirmPopUpKey = "bor"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kRestoreConfirmPopUpKey
        }
    }
    
    final class BecomePremiumScreen: NetmeraEvent {
        
        private let kBecomePremiumScreenKey = "qmb"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kBecomePremiumScreenKey
        }
    }
    
    final class DeleteConfirmPopUp: NetmeraEvent {
        
        private let kDeleteConfirmPopUpKey = "caf"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kDeleteConfirmPopUpKey
        }
    }
    
    final class LoginScreen: NetmeraEvent {
        
        private let kLoginScreenKey = "quu"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kLoginScreenKey
        }
    }
    
    final class SplashPageScreen: NetmeraEvent {
        
        private let kSplashPageKey = "vgg"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kSplashPageKey
        }
    }
    
    final class PhotoEditScreen: NetmeraEvent {
          
          private let kPhotoEditScreenKey = "wiu"
          
          override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
              return [:]
          }
          
          override var eventKey : String {
              return kPhotoEditScreenKey
          }
      }
    
    final class PeopleScreen: NetmeraEvent {
          
          private let kPeopleScreenKey = "bpv"
          
          override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
              return [:]
          }
          
          override var eventKey : String {
              return kPeopleScreenKey
          }
      }
    
    final class UsageInfoScreen: NetmeraEvent {
          
          private let kUsageInfoScreenKey = "lde"
          
          override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
              return [:]
          }
          
          override var eventKey : String {
              return kUsageInfoScreenKey
          }
      }
    
    final class NativeSharefromGalleryScreen: NetmeraEvent {
          
          private let kNativeSharefromGalleryScreenKey = "yex"
          
          override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
              return [:]
          }
          
          override var eventKey : String {
              return kNativeSharefromGalleryScreenKey
          }
      }
    
    final class HomePageScreen: NetmeraEvent {
          
          private let kHomePageScreenKey = "unj"
          
          override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
              return [:]
          }
          
          override var eventKey : String {
              return kHomePageScreenKey
          }
      }
    
    final class ThingsScreen: NetmeraEvent {
        
        private let kThingsScreenKey = "qvw"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kThingsScreenKey
        }
    }
    
    final class PremiumDetailsScreen: NetmeraEvent {
        
        private let kPremiumDetailsScreenKey = "vhf"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kPremiumDetailsScreenKey
        }
    }
    
    final class DeletePermanentlyConfirmPopUp: NetmeraEvent {
        
        private let kDeletePermanentlyConfirmPopUpKey = "rya"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kDeletePermanentlyConfirmPopUpKey
        }
    }
    
    final class PasscodeScreen: NetmeraEvent {
        
        private let kPasscodeScreenKey = "xlr"
        
        override class func keyPathPropertySelectorMapping() -> [AnyHashable: Any] {
            return [:]
        }
        
        override var eventKey : String {
            return kPasscodeScreenKey
        }
    }
    
}


