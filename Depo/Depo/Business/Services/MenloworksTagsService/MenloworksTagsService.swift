//
//  MenloworksTagsService.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class MenloworksTagsService {
    
    private let reachabilityService = ReachabilityService()
    private init() { }
    
    static let shared = MenloworksTagsService()
    
    // MARK: - Event methods
    
    func onTutorial() {
        let tag = MenloworksTags.Tutorial()
        hitTag(tag)
    }
    
    func onFileUploadedWithType(_ type: FileType) {
        var tag: MenloworksTag?
        
        switch type {
        case .image:
            tag = MenloworksTags.PhotoUpload(isWiFi: reachabilityService.isReachableViaWiFi)
        case .audio:
            tag = MenloworksTags.MusicUpload()
        case .video:
            tag = MenloworksTags.VideoUpload()
        case .allDocs, .unknown, .application:
            tag = MenloworksTags.FileUpload()
        default:
            break
        }
        
        if let tag = tag {
            hitTag(tag)
        }
    }
    
    func onLogin() {
        let tagWiFi3G = MenloworksTags.WiFi3G(isWiFi: reachabilityService.isReachableViaWiFi)
        hitTag(tagWiFi3G)
        
        let tagLogginCompleted = MenloworksTags.LogginCompleted()
        hitTag(tagLogginCompleted)
    }
    
    func onStartWithLogin(_ isLoggedIn: Bool) {
        let tag = MenloworksTags.LoggedIn(isLoggedIn: isLoggedIn)
        hitTag(tag)
        
        if isLoggedIn {
            sendInstagramImportStatus()
            sendFacebookImportStatus()
            sendFIRStatus()
        }
    }
    
    func onSignUp() {
        let tag = MenloworksTags.SignUpCompleted()
        hitTag(tag)
    }
    
    // MARK: - Accessory methods
    
    private func hitTag(_ tag: MenloworksTag) {
        if let value = tag.value {
            MPush.hitTag(tag.name, withValue: value)
        } else {
            MPush.hitTag(tag.name)
        }
    }
    
    private func sendInstagramImportStatus() {
        InstagramService().getSyncStatus(success: { (response) in
            guard let response = response as? SocialSyncStatusResponse,
                  let status = response.status else { return }
            let tag = MenloworksTags.InstagramImportStatus(isEnabled: status)
            self.hitTag(tag)
        }, fail: nil)
    }
    
    private func sendFacebookImportStatus() {
        FBService().requestStatus(success: { (response) in
            guard let response = response as? FBStatusObject,
                  let status = response.syncEnabled else { return }
            let tag = MenloworksTags.FacebookImportStatus(isEnabled: status)
            self.hitTag(tag)
        }, fail: nil)
    }
    
    private func sendFIRStatus() {
        AccountService().faceImageAllowed(success: { (response) in
            guard let response = response as? FaceImageAllowedResponse,
                  let status = response.allowed else { return }
            let tag = MenloworksTags.FaceImageRecognitionStatus(isEnabled: status)
            self.hitTag(tag)
        }, fail: { _ in })
    }
}
