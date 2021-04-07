//
//  PrivateShareSearchViewController.swift
//  Depo
//
//  Created by Alex Developer on 07.04.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

class PrivateShareSearchViewController: BaseViewController, NibInit {
    
    @IBOutlet weak var collection: UICollectionView! {
        willSet {
            newValue.backgroundColor = .brown
        }
    }
    
    
    
}

extension PrivateShareSearchViewController: UISearchControllerDelegate {
//    @available(iOS 8.0, *)
//    optional func willPresentSearchController(_ searchController: UISearchController)
//
//    @available(iOS 8.0, *)
//    optional func didPresentSearchController(_ searchController: UISearchController)
//
//    @available(iOS 8.0, *)
//    optional func willDismissSearchController(_ searchController: UISearchController)
//
//    @available(iOS 8.0, *)
//    optional func didDismissSearchController(_ searchController: UISearchController)
//
//
//    // Called after the search controller's search bar has agreed to begin editing or when 'active' is set to YES. If you choose not to present the controller yourself or do not implement this method, a default presentation is performed on your behalf.
//    @available(iOS 8.0, *)
//    optional func presentSearchController(_ searchController: UISearchController)
//}
}

extension PrivateShareSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        debugPrint("!!! HERE WE GO S")
    }

}

extension PrivateShareSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("!!! search button click")
        
//        fileInfoManager
            
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
