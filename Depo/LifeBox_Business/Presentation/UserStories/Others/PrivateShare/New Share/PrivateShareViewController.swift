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
    
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textAlignment = .left
            newValue.font = .GTAmericaStandardMediumFont(size: 20)
            newValue.textColor = ColorConstants.Text.labelTitle
            newValue.text = TextConstants.PrivateShare.page_title
        }
    }
    
    
    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.setImage(UIImage(named: "closeButton"), for: .normal)
        }
    }
    
    @IBOutlet private weak var scrollView: DismissKeyboardScrollView! {
        willSet {
            newValue.keyboardDismissMode = .interactive
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var contentView: UIStackView! {
        willSet {
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.spacing = 0
        }
    }
    
    @IBOutlet private weak var bottomView: UIView! {
        willSet {
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOpacity = 0.1
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowRadius = 5
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = 5.0
            
            newValue.setTitle(TextConstants.PrivateShare.start, for: .normal)
            
            newValue.setTitleColor(.white, for: .normal)
            newValue.setBackgroundColor(ColorConstants.PrivateShare.shareButtonBackgroundEnabled, for: .normal)
            
            newValue.titleLabel?.font = .GTAmericaStandardMediumFont(size: 14)
            newValue.isEnabled = false
        }
    }
    
    private lazy var selectPeopleView = PrivateShareSelectPeopleView.with(delegate: self)
    private lazy var shareWithView = PrivateShareWithView.with(contacts: [], delegate: self)
    private lazy var messageView = PrivateShareAddMessageView.initFromNib()
    private lazy var durationView = PrivateShareDurationView.initFromNib()
    
    private lazy var remoteSuggestionsView: PrivateShareSuggestionsView = {
        let view = PrivateShareSuggestionsView.with(contacts: [], delegate: self)
        
        //TODO: shadow as an additional layer + border color + masksToBounds
        view.layer.cornerRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.1
        view.layer.shadowColor = UIColor.black.cgColor
        
        return view
    }()
    
    private let minSearchLength = 2
    
    private var items = [WrapData]()
    private var remoteSuggestions = [SuggestedApiContact]()
    private var hasAccess = false
    
    private var startThresholdDate: Date?
    
    private lazy var shareApiService = PrivateShareApiServiceImpl()
    
    private let suggestionsOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private lazy var router = RouterVC()
    private lazy var analytics = PrivateShareAnalytics()
    
    override var keyboardHeight: CGFloat {
        didSet {
            let offset = max(0, keyboardHeight - bottomView.frame.height)
//            searchSuggestionsContainerBottomOffset.constant = offset
            scrollView.contentInset.bottom = offset
        }
    }
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addArrangedSubview(selectPeopleView)
        
        addRemoteSuggestions()
        
        setupSuggestedSubjects(searchText: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        selectPeopleView.textField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        selectPeopleView.layoutSubviews()
    }
    
    private func addRemoteSuggestions() {
        view.addSubview(remoteSuggestionsView)
        remoteSuggestionsView.translatesAutoresizingMaskIntoConstraints = false
        remoteSuggestionsView.topAnchor.constraint(equalTo: selectPeopleView.dropdownListAnchors.top).activate()
        remoteSuggestionsView.leadingAnchor.constraint(equalTo: selectPeopleView.dropdownListAnchors.leading).activate()
        remoteSuggestionsView.trailingAnchor.constraint(equalTo: selectPeopleView.dropdownListAnchors.trailing).activate()
    }
    
    private func setupSuggestedSubjects(searchText: String) {
        
        if let thresholdDate = startThresholdDate,
           Date().timeIntervalSince(thresholdDate) * 1000 < 50 {
            return
        }
        startThresholdDate = Date()
        
        suggestionsOperationQueue.cancelAllOperations()
        
        let fixed = searchText.precomposedStringWithCanonicalMapping
        let encodedText = fixed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText
        
        let operation = PrivateShareSuggestionsOperation(searchText: encodedText) { [weak self] result in
            switch result {
            case .success(let contacts):
                self?.remoteSuggestions = contacts
                self?.showRemoteSuggestions()
                self?.alloweManualAddIfNeeded(searchQuery: searchText)
                
            case .failed(let error):
                if let customError = error as? OperationError,
                   case OperationError.cancelled = customError {
                    debugPrint("Private Share operation cancelled")
                } else {
                    UIApplication.showErrorAlert(message: error.description)
                }
                
            }
        }
        suggestionsOperationQueue.addOperation(operation)
    }
    
    private func showRemoteSuggestions() {
        guard !remoteSuggestions.isEmpty else {
            removeRemoteSuggestionsView()
            return
        }
        
        let suggestedContacts = remoteSuggestions.map { SuggestedContact(with: $0) }
        
        remoteSuggestionsView.setup(with: suggestedContacts)
    }
    
    private func removeRemoteSuggestionsView() {
        remoteSuggestionsView.setup(with: [])
    }
    
    private func updateShareButtonIfNeeded() {
        let hasContacts = !shareWithView.contacts.isEmpty
        shareButton.isEnabled = hasContacts
    }
    
    private func showShareViews() {
        let orderedViews = [shareWithView, messageView, durationView]
        orderedViews.forEach { contentView.addArrangedSubview($0) }
    }
    
    private func hideShareViews() {
        let orderedViews = [shareWithView, messageView, durationView]
        orderedViews.forEach { $0.removeFromSuperview() }
    }
    
    private func endSearchContacts() {
        view.endEditing(true)
        removeRemoteSuggestionsView()
    }
    
    private func alloweManualAddIfNeeded(searchQuery: String) {
        let isAllowed = !searchQuery.isEmpty && (remoteSuggestions.first(where: { $0.email == searchQuery }) != nil)
        selectPeopleView.addManually(isAllowed: isAllowed)
    }

    //MARK: - Actions
    
    @IBAction private func onCloseTapped(_ sender: Any) {
        if shareWithView.contacts.isEmpty {
           dismiss(animated: true)
        } else {
            let popup = PopUpController.with(title: nil,
                                             message: TextConstants.PrivateShare.close_page,
                                             image: .question,
                                             firstButtonTitle: TextConstants.PrivateShare.close_page_no,
                                             secondButtonTitle: TextConstants.PrivateShare.close_page_yes,
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
        let sharedItems = items.compactMap { PrivateShareObjectItem(accountUuid: $0.accountUuid, uuid: $0.uuid) }
        let shareObject = PrivateShareObject(items: sharedItems,
                                             invitationMessage: messageView.message,
                                             invitees: shareWithView.contacts,
                                             type: .file,
                                             duration: durationView.duration)
   
        shareApiService.privateShare(object: shareObject) { [weak self] result in
            switch result {
            case .success:
                if let items = self?.items {
                    ItemOperationManager.default.didShare(items: items)
                    self?.analytics.successShare(items: items, duration: shareObject.duration, message: shareObject.invitationMessage)
                }
                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.privateShareStartPageSuccess)
                self?.dismiss(animated: true)
            case .failed(let error):
                let errorMessage = (error as? ServerMessageError)?.getPrivateShareError() ?? TextConstants.temporaryErrorOccurredTryAgainLater
                UIApplication.showErrorAlert(message: errorMessage)
            }
        }
    }
    
    override func hideKeyboard() {
        super.hideKeyboard()
        
        removeRemoteSuggestionsView()
    }
}

//MARK: - PrivateShareSelectPeopleViewDelegate

extension PrivateShareViewController: PrivateShareSelectPeopleViewDelegate {

    func startEditing(text: String) {
        if !remoteSuggestionsView.isShowingContacts {
            setupSuggestedSubjects(searchText: text)
        }
    }
    
    func searchTextDidChange(text: String) {
        setupSuggestedSubjects(searchText: text)
    }
    
    func hideKeyboard(text: String) {
//        if text.count < minSearchLength {
//            removeRemoteSuggestionsView()
//        }
    }
    
    func addShareContact(_ contact: PrivateShareContact, fromSuggestions: Bool) {
        var suggestedContact: PrivateShareContact? = nil
        
        if fromSuggestions {
            if let remoteSuggestion = remoteSuggestions.first(where: { $0.email == contact.username }) {
                suggestedContact = PrivateShareContact(displayName: remoteSuggestion.name ?? "", username: contact.username, type: remoteSuggestion.type ?? .knownName, role: contact.role, identifier: remoteSuggestion.identifier ?? "")
            }
        } else {
            suggestedContact = contact
        }
        
        guard let contactToShare = suggestedContact else {
            return
        }
        
        if let maxInviteeCount = SingletonStorage.shared.featuresInfo?.maxSharingInviteeCount,
            shareWithView.contacts.count >= maxInviteeCount {
            UIApplication.showErrorAlert(message: String(format: TextConstants.privateShareMaxNumberOfUsersMessageFormat, maxInviteeCount))
            return
        }
        
        guard isValidContact(text: contactToShare.username) else {
            return
        }
        
        selectPeopleView.clear()
        shareWithView.add(contact: contactToShare)
        if shareWithView.superview == nil {
            showShareViews()
        }
        endSearchContacts()
        updateShareButtonIfNeeded()
    }
    
    private func isValidContact(text: String) -> Bool {
        if text.contains("@") {
            if Validator.isValid(email: text) {
                return true
            } else {
                UIApplication.showErrorAlert(message: TextConstants.privateShareEmailValidationFailPopUpText)
                return false
            }
        }
        
        return true
    }

}

//MARK: - PrivateShareWithViewDelegate

extension PrivateShareViewController: PrivateShareWithViewDelegate {
    
    func shareListDidEmpty() {
        hideShareViews()
        updateShareButtonIfNeeded()
    }
    
    func onUserRoleTapped(contact: PrivateShareContact, sender: Any, completion: @escaping ValueHandler<PrivateShareUserRole>) {
        showRoleSelectionMenu(sender: sender as? UIView, handler: completion)
    }
    
    private func showRoleSelectionMenu(sender: UIView?, handler: @escaping ValueHandler<PrivateShareUserRole>) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let allowedRoles: [PrivateShareUserRole] = [.viewer, .editor]
        
        allowedRoles.forEach { role in
            let action = UIAlertAction(title: role.selectionTitle, style: .default) { _ in
                handler(role)
            }
            actionSheet.addAction(action)
        }

        let cancelAction = UIAlertAction(title: TextConstants.cancel, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        actionSheet.popoverPresentationController?.sourceView = sender

        present(actionSheet, animated: true)
    }
}

//MARK: - PrivateShareSelectSuggestionsDelegate

extension PrivateShareViewController: PrivateShareSelectSuggestionsDelegate {
    
    func didSelect(contactInfo: ContactInfo) {
        selectPeopleView.setContact(info: contactInfo)
        endSearchContacts()
    }
}
