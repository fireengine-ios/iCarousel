//
//  CreateStoryPhotosCreateStoryInitializer.swift
//  Depo
//
//  Created by Oleg on 02/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryModuleInitializer: BaseFilesGreedModuleInitializer {

    class func initializePhotoSelectionViewControllerForStory(with nibName:String, story:PhotoStory) -> UIViewController {
        let viewController = CreateStoryPhotoSelectionViewController(nibName: nibName, bundle: nil)
        let configurator = CreateStorySelectionConfigurator()

        configurator.configure(viewController: viewController, remoteServices: PhotoAndVideoService(requestSize: 100, type: .image),
                               filters: [.fileType(.image)], story: story)
        return viewController
    }
    
    class func initializeAudioSelectionViewControllerForStory(with nibName:String, story:PhotoStory) -> UIViewController {
        let viewController = CreateStoryAudioSelectionViewController(nibName: nibName, bundle: nil)
        let configurator = CreateStorySelectionConfigurator()

        configurator.configure(viewController: viewController, remoteServices: CreateStoryMusicService(),
                               filters: [.fileType(.audio)], story: story)
        return viewController
    }

}
