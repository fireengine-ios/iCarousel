//
//  UploadPickerAssetSelectionHelper.swift
//  Depo
//
//  Created by Konstantin Studilin on 30.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation


final class UploadPickerAssetSelectionHelper {
    static let shared = UploadPickerAssetSelectionHelper()
    
    private var selectedAssetIds = SynchronizedSet<String>()

    
    private init() {}
    
    
    func clear() {
        selectedAssetIds.removeAll()
    }
    
    func getAll() -> Set<String> {
        return selectedAssetIds.getSet()
    }
    
    func appendAsset(identifier: String) {
        selectedAssetIds.insert(identifier)
    }
    
    func removeAsset(identifier: String) {
        selectedAssetIds.remove(identifier)
    }
    
    func has(identifier: String) -> Bool {
        return selectedAssetIds.contains(identifier)
    }
}
