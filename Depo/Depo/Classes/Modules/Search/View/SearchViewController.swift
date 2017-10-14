//
//  SearchViewController.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, SearchViewInput {
    
    // MARK: - Outlets
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var suggestTableView: UITableView!
    
    @IBOutlet weak var noFilesView: UIView!
    @IBOutlet weak var noFilesLabel: UILabel!
    @IBOutlet weak var noFilesImage: UIImageView!
    @IBOutlet weak var startCreatingFilesButton: BlueButtonWithWhiteText!
    
    // MARK: - Variables
    
    var output: SearchViewOutput!
    
    var suggestionList = [SuggestionObject]()
    
    // MARK: - Life Cicle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = false
        self.view.backgroundColor = ColorConstants.searchShadowColor
        self.collectionView.isHidden = true
        self.suggestTableView.isHidden = true
        self.noFilesLabel.text = "No results found for your query."
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
         self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    // MARK: - Configuration
    
    func configureNavigationBar() {
        self.navigationBar.topItem?.rightBarButtonItems = []
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.tintColor = ColorConstants.darcBlueColor
        searchBar.delegate = self
        searchBar.setImage(UIImage(named: TextConstants.searchIcon), for: .search, state: .normal)
        for subView in (searchBar.subviews.first?.subviews)! {
            if subView.isKind(of: UITextField.self) {
                let textFileld = (subView as! UITextField)
                textFileld.backgroundColor = ColorConstants.searchBarColor
                textFileld.placeholder = TextConstants.search
                textFileld.font = UIFont.TurkcellSaturaBolFont(size: 19)
                textFileld.textColor = ColorConstants.darcBlueColor
                textFileld.keyboardAppearance = .dark
            }
            if subView.isKind(of: UIButton.self) {
                (subView as! UIButton).titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 17)
            }
        }
        if Device.isIpad {
            self.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: TextConstants.cancel, style: .plain, target: self, action: #selector(self.searchBarCancelButtonClicked(_:)))
            self.navigationBar.topItem?.rightBarButtonItem?.tintColor = ColorConstants.darcBlueColor
        }
        self.navigationBar.topItem?.titleView = searchBar
        searchBar.becomeFirstResponder()
        output.viewIsReady(collectionView: collectionView)
    }
    
    // MARK: - UISearchbarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text! != "" {
            let customAllowedSet =  NSCharacterSet(charactersIn:"=\"#%/<>?@\\^`{|}&").inverted
            output.searchWith(searchText: searchBar.text!.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!, sortBy: SortType.date, sortOrder: SortOrder.asc)
        } else {
            self.collectionView.isHidden = true
        }
        self.view.endEditing(true)
        self.suggestTableView.isHidden = true
    }
    
    var timerToSearch = Timer()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !output.isShowedSpinner() {
            self.timerToSearch.invalidate()
            self.timerToSearch = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.searchTimerIsOver(timer:)), userInfo: searchText, repeats: false)
        }
    }
    
    @objc func searchTimerIsOver(timer: Timer) {
        self.output.getSuggestion(text: timer.userInfo as! String)
    }
    
    func endSearchRequestWith(text: String) {
        self.collectionView.isHidden = false
        if let searchBar = self.navigationBar.topItem?.titleView {
            if text != (searchBar as! UISearchBar).text! {
                self.timerToSearch.invalidate()
                self.timerToSearch = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.searchTimerIsOver(timer:)), userInfo: (searchBar as! UISearchBar).text!, repeats: false)
            }
        }
    }
    
    // MARK: - SearchViewInput
    
    func getCollectionViewWidth() -> CGFloat{
        return collectionView.frame.size.width
    }
    
    
    func setCollectionViewVisibilityStatus(visibilityStatus: Bool){
        collectionView.isHidden = visibilityStatus
        noFilesView.isHidden = !visibilityStatus
        noFilesLabel.isHidden = !visibilityStatus
    }
    
    func successWithSuggestList(list: [SuggestionObject]) {
        if list.count > 0 {
            self.suggestTableView.isHidden = false
            self.suggestionList = list
            self.suggestTableView.reloadData()
        } else {
            self.suggestTableView.isHidden = true
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func dismissController() {
        self.dismiss(animated: false, completion: nil)
    }
}

//MARK: - UITableViewDelagate & DataSource 

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.suggestionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let suggest = self.suggestionList[indexPath.row]
        cell.textLabel?.font = UIFont.TurkcellSaturaDemFont(size: 15)
        cell.textLabel?.textColor = ColorConstants.darcBlueColor
        if let text = suggest.highlightedText {
            cell.textLabel?.attributedText = text
        } else {
            cell.textLabel?.text = suggest.text!
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchBar = self.navigationBar.topItem?.titleView as! UISearchBar
        searchBar.text = self.suggestionList[indexPath.row].text!
        self.searchBarSearchButtonClicked(searchBar)
    }
}
