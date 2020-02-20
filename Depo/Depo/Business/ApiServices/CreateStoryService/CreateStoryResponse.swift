//
//  CreateStoryResponse.swift
//  Depo_LifeTech
//
//  Created by Oleg on 18.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryResponse: ObjectRequestResponse {
    var storyURLString: String?
    var uuid: String?
    
    override func mapping() {
        storyURLString = json?[CreateStoryPropertyName.downloadUrl].string
        uuid = json?[CreateStoryPropertyName.uuid].string
    }
}
