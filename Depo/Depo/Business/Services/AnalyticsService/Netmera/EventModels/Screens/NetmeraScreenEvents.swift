//
//  NetmeraScreenEvents.swift
//  Depo
//
//  Created by Alex on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Netmera

extension NetmeraEvents.Screens {
    
    final class ContactBackUpScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "dmi"
        }
    }
    
    final class WelcomePage: NetmeraScreenEventTemplate {
        
        private var welomePageKey = ""
        
        override var key: String {
            return welomePageKey
        }
        
        convenience init(pageNum: Int) {
            
            self.init()
            
            switch pageNum {
            case 1:
                self.welomePageKey = "wly"
            case 2:
                self.welomePageKey = "koi"
            case 3:
                self.welomePageKey = "wow"
            case 4:
                self.welomePageKey = "rbs"
            case 5:
                self.welomePageKey = "ujh"
            case 6:
                self.welomePageKey = "xxz"
            case 7:
                self.welomePageKey = "vbt"
            default:
                break
            }

        }
    }
    
    final class PhotoPickAnalysisDetailScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "hup"
        }
    }
    
    final class AutoSyncScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "mwv"
        }
    }
    
    final class EmailVerification: NetmeraScreenEventTemplate {
        override var key: String {
            return "axi"
        }
    }
    
    final class PackagesScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "wss"
        }
    }
    
    final class StoriesScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "pvg"
        }
    }
    
    final class PlacesScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "ots"
        }
    }
    
    final class FirstAutoSyncScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "mpu"
        }
    }
    
    final class FavoritesScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "pnx"
        }
    }
    
    final class ForgetPasswordScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "sdx"
        }
    }
    
    final class EulaScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "keg"
        }
    }
    
    final class AlbumsScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "uqm"
        }
    }
    
    final class FAQScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return  "nsv"
        }
    }
    
    final class DeleteDuplicateScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return  "lxb"
        }
    }
    
    final class CreateStoryPreviewScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return  "rcl"
        }
    }
    
    final class MusicScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "ark"
        }
    }
    
    final class ActivitiyTimelineScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return  "ijd"
        }
    }
    
    final class OTPSignupScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return  "zkx"
        }
    }
    
    final class ContactUsScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "dpv"
        }
    }
    
    final class LoginSettingsScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "bdr"
        }
    }
    
    final class FreeUpSpaceScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return  "fmb"
        }
    }
    
    final class SignupScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return  "xyf"
        }
    }
    
    final class CreateStoryNameScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "dqt"
        }
    }
    
    final class ContactsSyncScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "lil"
        }
    }
    
    final class FaceImageGroupingScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "nmu"
        }
    }
    
    final class AllFilesScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "xqq"
        }
    }
    
    final class ConnectedAccountsScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "liu"
        }
    }
    
    final class PhotosScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "kxn"
        }
    }
    
    final class SettingsScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "tiu"
        }
    }
    
    final class PhotoPickHistoryScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "dzx"
        }
    }
    
    final class OTPDoubleOptInScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "mda"
        }
    }
    
    final class ManualUploadScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "adq"
        }
    }
    
    final class DocumentsScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "tzv"
        }
    }
    
    final class SearchScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "udf"
        }
    }
    
    final class CreateStoryPhotoSelectionScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "dsf"
        }
    }
    
    final class VideosScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "qdm"
        }
    }
    
    final class ProfileEditScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "xbg"
        }
    }
    
    final class CreateStoryMusicSelectionScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "img"
        }
    }
    
    final class PremiumDetails: NetmeraScreenEventTemplate {
        override var key: String {
            return "iuo"
        }
    }
    
    final class RestoreConfirmPopUp: NetmeraScreenEventTemplate {
        override var key: String {
            return "bor"
        }
    }
    
    final class BecomePremiumScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "qmb"
        }
    }
    
    final class DeleteConfirmPopUp: NetmeraScreenEventTemplate {
        override var key: String {
            return "caf"
        }
    }
    
    final class LoginScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "quu"
        }
    }
    
    final class SplashPageScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "vgg"
        }
    }
    
    final class LiveCollectRememberScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "mms"
        }
    }
    
    final class PhotoEditScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "wiu"
        }
    }
    
    final class PeopleScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "bpv"
        }
    }
    
    final class UsageInfoScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "lde"
        }
    }
    
    final class NativeSharefromGalleryScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "yex"
        }
    }
    
    final class HomePageScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "unj"
        }
    }
    
    final class ThingsScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "qvw"
        }
    }
    
    final class PremiumDetailsScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "vhf"
        }
    }
    
    final class DeletePermanentlyConfirmPopUp: NetmeraScreenEventTemplate {
        override var key: String {
            return "rya"
        }
    }
    
    final class PasscodeScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "xlr"
        }
    }
    
    final class SmashPreview: NetmeraScreenEventTemplate {
        override var key: String {
            return "yqb"
        }
    }
    
    final class TrashBinScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return  "vco"
        }
    }
    
    final class HiddenBinScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "wgd"
        }
    }
    
    final class SmashConfirmPopUp: NetmeraScreenEventTemplate {
        override var key: String {
            return "txu"
        }
    }
    
    final class UnhideConfirmPopUp: NetmeraScreenEventTemplate {
        override var key: String {
            return "gfe"
        }
    }
    
    final class HideConfirmPopUp: NetmeraScreenEventTemplate {
        override var key: String {
            return "bsa"
        }
    }
    
    final class SaveSmashSuccessfullyPopUp: NetmeraScreenEventTemplate {
        override var key: String {
            return "eyd"
        }
    }
    
    
    final class PhotoPickPhotoSelectionScreen: NetmeraScreenEventTemplate {
        override var key: String {
            return "wtj"
        }
    }
    
    final class NonStandardUserFIGroupingOFF: NetmeraScreenEventTemplate {
        override var key: String {
            return "you"
        }
    }
    
    final class StandardUserFIRGroupingON: NetmeraScreenEventTemplate {
        override var key: String {
            return "hjz"
        }
    }
    
    final class StandardUserFIGroupingOFF: NetmeraScreenEventTemplate {
        override var key: String {
            return "qml"
        }
    }
    
    final class SaveHiddenSuccessfullyPopUp: NetmeraScreenEventTemplate {
        override var key: String {
            return "hbh"
        }
    }
}


