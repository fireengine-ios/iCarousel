//
//  SocialAccountSectionMediator.swift
//  Depo
//
//  Created by Konstantin Studilin on 12/02/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class SocialAccountSectionMediator {
    private weak var socialConnectionCell: SocialConnectionCell?
    private weak var removeConnectionCell: SocialRemoveConnectionCell?
    
    
    func set(socialConnectionCell: SocialConnectionCell) {
        self.socialConnectionCell = socialConnectionCell
    }
    
    func set(removeConnectionCell: SocialRemoveConnectionCell) {
        self.removeConnectionCell = removeConnectionCell
    }
    
    func disconnect() {
        socialConnectionCell?.disconnect()
    }
    
    func setup(with username: String?) {
        removeConnectionCell?.set(username: username)
    }
}
