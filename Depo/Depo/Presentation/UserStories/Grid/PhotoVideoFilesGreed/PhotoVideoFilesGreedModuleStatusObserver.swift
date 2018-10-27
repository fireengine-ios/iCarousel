//
//  PhotoVideoFilesGreedModuleStatusObserver.swift
//  Depo
//
//  Created by MISTAKE on 10/25/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

//WARNING:
//FIXME:
/// BE WARNED: this class only exist as a workaround to a fact to that we have separeted poto and videos pages. In the refactoring branch we use one root Photo/Videos controller that contains two seperate controllers, which would help a lot with QS preparetion card. But for now we can use this workaround
class PhotoVideoFilesGreedModuleStatusContainer {
    
    static let shared = PhotoVideoFilesGreedModuleStatusContainer()
    
    var isPhotoScreenPaginationDidEnd = false
    var isVideScreenPaginationDidEnd = false
    
}
