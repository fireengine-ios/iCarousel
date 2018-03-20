//
//  PhotoStory.swift
//  Depo
//
//  Created by Oleg on 02.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class PhotoStory: NSObject {
    
    var storyName: String
    var storyPhotos = [Item]()
    var music: Item?
    
    init(name: String) {
        storyName = name
        super.init()
    }
    
    func photoStoryRequestParameter() -> CreateStory? {
        if let music = music {
            let idsArray = storyPhotos.map {
                $0.uuid
            }
            if music.metaData != nil {
                return CreateStory(name: storyName, imageuuid: idsArray, musicUUID: music.uuid)
            } else {
                return CreateStory(name: storyName, imageuuid: idsArray, musicId: music.id)
            }
        }
        return nil
    }
}
