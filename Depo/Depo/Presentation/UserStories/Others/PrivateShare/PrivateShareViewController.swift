//
//  PrivateShareViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareViewController: BaseViewController, NibInit {

    static func with(items: [WrapData]) -> PrivateShareViewController {
        let controller = PrivateShareViewController.initFromNib()
        controller.items = items
        return controller
    }
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.keyboardDismissMode = .interactive
        }
    }
    
    @IBOutlet private weak var contentView: UIStackView!
    @IBOutlet private weak var searchSuggestionsContainer: UIView!
    @IBOutlet private weak var searchSuggestionsContainerBottomOffset: NSLayoutConstraint!
    
    @IBOutlet private weak var bottomView: UIView! {
        willSet {
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOpacity = 0.1
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowRadius = 5
        }
    }
    @IBOutlet private weak var shareButton: RoundedButton! {
        willSet {
            newValue.setTitle(TextConstants.privateShareStartPageShareButton, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = .lightGray
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 16)
            newValue.isEnabled = false
        }
    }
    
    private lazy var closeButton = UIBarButtonItem(title: TextConstants.privateShareStartPageCloseButton,
                                                   font: UIFont.TurkcellSaturaDemFont(size: 19),
                                                   tintColor: UIColor.white,
                                                   accessibilityLabel: TextConstants.cancel,
                                                   style: .plain,
                                                   target: self,
                                                   selector: #selector(onCancelTapped))
    
    private lazy var selectPeopleView = PrivateShareSelectPeopleView.with(delegate: self)
    private lazy var shareWithView = PrivateShareWithView.with(contacts: [], delegate: self)
    private lazy var messageView = PrivateShareAddMessageView.initFromNib()
    private lazy var durationView = PrivateShareDurationView.initFromNib()
    private lazy var searchSuggestionController = PrivateShareLocalSuggestionsViewController.with(delegate: self)
    
    private let minSearchLength = 2
    
    private var items = [WrapData]()
    private var remoteSuggestions = [SuggestedApiContact]()
    
    private lazy var shareApiService = PrivateShareApiServiceImpl()
    private lazy var localContactsService = ContactsSuggestionServiceImpl()
    private lazy var router = RouterVC()
    
    override var keyboardHeight: CGFloat {
        didSet {
            searchSuggestionsContainerBottomOffset.constant = max(0, keyboardHeight - bottomView.frame.height)
        }
    }
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = TextConstants.actionSheetShare
        navigationItem.leftBarButtonItem = closeButton
        needCheckModalPresentationStyle = false
        
        contentView.addArrangedSubview(selectPeopleView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    private func getRemoteSuggestions() {
        //load remote suggestion once
        if !remoteSuggestions.isEmpty {
            showRemoteSuggestions(hasAccess: true)
            return
        }
        
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        var hasAccess = false
        
        localContactsService.fetchAllContacts { isAuthorized in
            hasAccess = isAuthorized
            group.leave()
        }
            
        shareApiService.getSuggestions { [weak self] result in
            switch result {
            case .success(let contacts):
                self?.remoteSuggestions = contacts
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.showRemoteSuggestions(hasAccess: hasAccess)
        }
    }
    
    private func showRemoteSuggestions(hasAccess: Bool) {
        guard !remoteSuggestions.isEmpty else {
            return
        }
        
        let suggestedContacts = remoteSuggestions.map { contact -> SuggestedContact in
            if hasAccess {
                let names = self.localContactsService.getContactName(for: contact.username ?? "", email: contact.email ?? "")
                return SuggestedContact(with: contact, names: names)
            } else {
                return SuggestedContact(with: contact)
            }
        }
        
        if !contentView.arrangedSubviews.contains(where: { $0 is PrivateShareSuggestionsView }) {
            let view = PrivateShareSuggestionsView.with(contacts: suggestedContacts, delegate: self)
            contentView.insertArrangedSubview(view, at: 1)
        }
    }
    
    private func searchLocalSuggestions(query: String) {
        if let suggestionsView = contentView.arrangedSubviews.first(where: { $0 is PrivateShareSuggestionsView }) {
            suggestionsView.removeFromSuperview()
        }
        
        searchSuggestionController.update(with: query)
    }
    
    private func updateShareButtonIfNeeded() {
        let needEnable = !shareWithView.contacts.isEmpty
        shareButton.isEnabled = needEnable
        shareButton.backgroundColor = needEnable ? ColorConstants.navy : .lightGray
    }
    
    private func showShareViews() {
        let orderedViews = [shareWithView, messageView, durationView]
        orderedViews.forEach { contentView.addArrangedSubview($0) }
    }
    
    private func hideShareViews() {
        let orderedViews = [shareWithView, messageView, durationView]
        orderedViews.forEach { $0.removeFromSuperview() }
    }
    
    private func showSearchLocalContactsViewIfNeeded() {
        guard searchSuggestionsContainer.isHidden else {
            return
        }
        
        scrollView.contentOffset = .zero
        if searchSuggestionController.contentView.superview == nil {
            searchSuggestionsContainer.addSubview(searchSuggestionController.contentView)
            searchSuggestionController.contentView.translatesAutoresizingMaskIntoConstraints = false
            searchSuggestionController.contentView.pinToSuperviewEdges()
        }
        searchSuggestionsContainer.isHidden = false
    }
    
    private func endSearchContacts() {
        if let suggestionsView = contentView.arrangedSubviews.first(where: { $0 is PrivateShareSuggestionsView }) {
            suggestionsView.removeFromSuperview()
        }
        
        view.endEditing(true)
        if !searchSuggestionsContainer.isHidden {
            searchSuggestionController.update(with: "")
            searchSuggestionsContainer.isHidden = true
        }
    }

    //MARK: - Actions
    
    @objc private func onCancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction private func onShareTapped(_ sender: Any) {
        remoteSuggestions = []
        
        let type: PrivateShareItemType
        if items.contains(where: { $0.isFolder == true }) {
            type = .folder
        } else {
            type = .file
        }
        
        var shareObject = PrivateShareObject(items: items.compactMap { $0.uuid },
                                             message: messageView.message,
                                             invitees: shareWithView.contacts,
                                             type: type,
                                             duration: durationView.duration)
        //TODO: continue sharing
    }
}

//MARK: - PrivateShareSelectPeopleViewDelegate

extension PrivateShareViewController: PrivateShareSelectPeopleViewDelegate {
    
    func startEditing(text: String) {
        searchTextDidChange(text: text)
    }
    
    func searchTextDidChange(text: String) {
        if text.count < minSearchLength {
            getRemoteSuggestions()
            searchSuggestionsContainer.isHidden = true
        } else {
            showSearchLocalContactsViewIfNeeded()
            searchLocalSuggestions(query: text)
        }
    }
    
    func addShareContact(_ contact: PrivateShareContact) {
        guard isValidContact(text: contact.username) else {
            UIApplication.showErrorAlert(message: TextConstants.privateShareValidationFailPopUpText)
            return
        }
        
        selectPeopleView.clear()
        shareWithView.add(contact: contact)
        if shareWithView.superview == nil {
            showShareViews()
        }
        endSearchContacts()
        updateShareButtonIfNeeded()
    }
}

//MARK: - PrivateShareWithViewDelegate

extension PrivateShareViewController: PrivateShareWithViewDelegate {
    
    func shareListDidEmpty() {
        hideShareViews()
        updateShareButtonIfNeeded()
    }
    
    func onUserRoleTapped(contact: PrivateShareContact, sender: Any) {
        let userRoleController = PrivateShareUserRoleViewController.with(contact: contact, delegate: sender as? PrivateShareUserRoleViewControllerDelegate)
        present(userRoleController, animated: true)
    }
    
    private func isValidContact(text: String) -> Bool {
        if Validator.isValid(email: text) || Validator.isValid(phone: text) {
            return true
        }
        return false
    }
}

//MARK: - PrivateShareSelectSuggestionsDelegate

extension PrivateShareViewController: PrivateShareSelectSuggestionsDelegate {
    
    func didSelect(contactInfo: ContactInfo) {
        selectPeopleView.setContact(info: contactInfo)
        endSearchContacts()
    }
}
