//
//  CollectionViewSpinnerFooter.swift
//  Depo
//
//  Created by Aleksandr on 3/24/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class CollectionViewSpinnerFooter: UICollectionReusableView {
    
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    func startSpinner() {
        spinner.startAnimating()
        self.isHidden = false
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
        self.isHidden = true
    }
    
}
