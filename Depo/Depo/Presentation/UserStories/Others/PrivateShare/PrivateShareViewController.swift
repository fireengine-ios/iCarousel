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
            let dismissKeyboardGuesture = UITapGestureRecognizer(target: self,
                                                                 action: #selector(stopEditing))
            newValue.addGestureRecognizer(dismissKeyboardGuesture)
            newValue.delaysContentTouches = false
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
    private var hasAccess = false
    
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
            showRemoteSuggestions()
            return
        }
        
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        localContactsService.fetchAllContacts { [weak self] isAuthorized in
            self?.hasAccess = isAuthorized
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
            self?.showRemoteSuggestions()
        }
    }
    
    private func showRemoteSuggestions() {
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
        removeRemoteSuggestionsView()
        
        let preparedQuery = prepare(searchQuery: query)
        searchSuggestionController.update(with: preparedQuery)
    }
    
    private func removeRemoteSuggestionsView() {
        if let suggestionsView = contentView.arrangedSubviews.first(where: { $0 is PrivateShareSuggestionsView }) {
            suggestionsView.removeFromSuperview()
        }
    }
    
    private func removeLocalSuggestionsView() {
        if !searchSuggestionsContainer.isHidden {
            searchSuggestionController.update(with: "")
            searchSuggestionsContainer.isHidden = true
        }
    }
    
    //workaround to support search without +9 for turkish msisdn
    private func prepare(searchQuery: String) -> String {
        let prefixToCheck = "+90" //Turkey country code
        let numberOfCharsToSearch = searchQuery.count - prefixToCheck.count + 1
        
        guard
            numberOfCharsToSearch >= minSearchLength,
            searchQuery.hasPrefix(prefixToCheck)
        else {
            return searchQuery
        }
        
        return String(searchQuery.suffix(numberOfCharsToSearch))
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
        guard hasAccess, searchSuggestionsContainer.isHidden else {
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
        view.endEditing(true)
        removeRemoteSuggestionsView()
        removeLocalSuggestionsView()
    }

    //MARK: - Actions
    
    @objc private func onCancelTapped(_ sender: Any) {
        if shareWithView.contacts.isEmpty {
            dismiss(animated: true)
        } else {
            let popup = PopUpController.with(title: TextConstants.privateShareStartPageClosePopupMessage,
                                             message: nil,
                                             image: .question,
                                             firstButtonTitle: TextConstants.cancel,
                                             secondButtonTitle: TextConstants.ok,
                                             firstAction: { vc in
                                                vc.close()
                                             },
                                             secondAction: { [weak self] vc in
                                                vc.close { [weak self] in
                                                    self?.dismiss(animated: true)
                                                }
                                             })
            router.presentViewController(controller: popup)
        }
    }

    @IBAction private func onShareTapped(_ sender: Any) {
        remoteSuggestions = []
        
        let shareObject = PrivateShareObject(items: items.compactMap { $0.uuid },
                                             invitationMessage: messageView.message,
                                             invitees: shareWithView.contacts,
                                             type: .file,
                                             duration: durationView.duration)
   
        shareApiService.privateShare(object: shareObject) { [weak self] result in
            switch result {
            case .success:
                self?.dismiss(animated: true)
                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.privateShareStartPageSuccess)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    @objc private func stopEditing() {
        self.view.endEditing(true)
    }
    
}

//MARK: - PrivateShareSelectPeopleViewDelegate

extension PrivateShareViewController: PrivateShareSelectPeopleViewDelegate {
    
    func startEditing(text: String) {
        if text.count < minSearchLength {
            getRemoteSuggestions()
            searchSuggestionsContainer.isHidden = true
        } else {
            showSearchLocalContactsViewIfNeeded()
            searchLocalSuggestions(query: text)
        }
    }
    
    func searchTextDidChange(text: String) {
        if text.count < minSearchLength {
            removeLocalSuggestionsView()
        } else {
            
            //we need this trimming for prepare(), so our +90 logic would work with whitespaces
            let trimmedText = text.filter{ $0 != " " }
            showSearchLocalContactsViewIfNeeded()
            searchLocalSuggestions(query: trimmedText)
        }
    }
    
    func hideKeyboard(text: String) {
        if text.count < minSearchLength {
            removeRemoteSuggestionsView()
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
        if Validator.isValid(email: text) || Validator.isValid(contactsPhone: text) {
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
    
    func contactListDidUpdate(isEmpty: Bool) {
        //display container only if local suggestions count > 0
        searchSuggestionsContainer.isHidden = isEmpty
    }
}
