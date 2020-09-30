//
//  WidgetService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 2/7/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MMWormhole


final class WidgetService {
    static let shared = WidgetService()
    
    //Using Wormhole is overkill but it's in the old app and we'll probably need it in a future
    private(set) lazy var wormhole: MMWormhole = MMWormhole(applicationGroupIdentifier: SharedConstants.groupIdentifier, optionalDirectory: SharedConstants.wormholeDirectoryIdentifier)
    
    private lazy var defaults = UserDefaults(suiteName: SharedConstants.groupIdentifier)
    
    var isPreperationFinished: Bool {
        get { return defaults?.bool(forKey: SharedConstants.isPreparationFinished) ?? false }
        set { defaults?.set(newValue, forKey: SharedConstants.isPreparationFinished)}
    }
    
    var mainAppResponsivenessDate: Date? {
        get { return defaults?.object(forKey: SharedConstants.mainAppSchemeResponsivenessDateKey) as? Date }
        set { defaults?.set(newValue, forKey: SharedConstants.mainAppSchemeResponsivenessDateKey)}
    }
    
    private (set) var totalCount: Int {
        get { return defaults?.integer(forKey: SharedConstants.totalAutoSyncCountKey) ?? 0 }
        set { defaults?.set(newValue, forKey: SharedConstants.totalAutoSyncCountKey) }
    }
    
    private (set) var finishedCount: Int {
        get { return defaults?.integer(forKey: SharedConstants.finishedAutoSyncCountKey) ?? 0 }
        set { defaults?.set(newValue, forKey: SharedConstants.finishedAutoSyncCountKey) }
    }
    
    private (set) var lastSyncedDate: String {
        get { return defaults?.string(forKey: SharedConstants.lastSyncDateKey) ?? "" }
        set { defaults?.set(newValue, forKey: SharedConstants.lastSyncDateKey) }
    }
    
    private (set) var syncStatus: AutoSyncStatus {
        get {
            let statusValue = defaults?.string(forKey: SharedConstants.syncStatusKey) ?? ""
            return AutoSyncStatus(rawValue: statusValue) ?? .undetermined
        }
        set { defaults?.set(newValue.rawValue, forKey: SharedConstants.syncStatusKey) }
    }
    
    private var currentImageData: Data? {
        get { return defaults?.data(forKey: SharedConstants.currentImageDataKey) }
        set { defaults?.set(newValue, forKey: SharedConstants.currentImageDataKey) }
    }
    
    var currentCompressedImage: UIImage? {
        guard let data = currentImageData else {
            return nil
        }
        
        var compressedImage = UIImage(data: data)
        compressedImage = compressedImage?.resizedImage(to: CGSize(width: 100, height: 100))
        return compressedImage
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter
    }()
    
    
    func notifyWidgetAbout(_ synced: Int, of total: Int) {
        finishedCount = synced
        totalCount = total
        lastSyncedDate = dateFormatter.string(from: Date())
        
        wormhole.passMessageObject(nil, identifier: SharedConstants.wormholeMessageIdentifier)
    }
    
    func notifyWidgetAbout(currentImage: UIImage?) {
//        currentImageData = currentImage?.jpeg(.low)
        wormhole.passMessageObject(nil, identifier: SharedConstants.wormholeMessageIdentifier)
    }
    
    func notifyWidgetAbout(status: AutoSyncStatus) {
        syncStatus = status
        
        if syncStatus != .executing {
            finishedCount = 0
            totalCount = 0
            currentImageData = nil
        }
        
        wormhole.passMessageObject(nil, identifier: SharedConstants.wormholeMessageIdentifier)
    }

}
