//
//  UserInfoSubViewUserInfoSubViewViewOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol UserInfoSubViewViewOutput {

    /**
        @author Oleg
        Notify presenter that view is ready
    */

    func viewIsReady()
    
    func reloadUserInfoRequered()
    func loadingIndicatorRequered()
    
    func loadingIndicatorDismissalRequered()
}
