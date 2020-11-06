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
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIStackView!
    
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
    
    private var items = [WrapData]()
    
    private lazy var shareApiService = PrivateShareApiServiceImpl()
    private lazy var localContactsService = ContactsSuggestionServiceImpl()
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = TextConstants.actionSheetShare
        navigationItem.leftBarButtonItem = closeButton
        
        addSelectionPeopleView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    private func addSelectionPeopleView() {
        let view = PrivateShareSelectPeopleView.with(delegate: self)
        contentView.addArrangedSubview(view)
    }
    
    private func getSuggestions() {
        showApiSuggestions(contacts: SuggestedApiContact.testContacts())
        return
            
//        shareApiService.getSuggestions { [weak self] result in
//            switch result {
//            case .success(let contacts):
//                self?.showApiSuggestions(contacts: contacts)
//            case .failed(let error):
//                UIApplication.showErrorAlert(message: error.description)
//            }
//        }
    }
    
    private func showApiSuggestions(contacts: [SuggestedApiContact]) {
        contentView.arrangedSubviews.dropFirst().forEach { $0.removeFromSuperview() }
        let view = PrivateShareSuggestionsView.with(contacts: contacts, delegate: self)
        contentView.addArrangedSubview(view)
    }
    
    private func searchSuggestions(query: String) {
        //TODO: implement search controller and needed logic
    }
    
    private func updateShareButtonIfNeeded() {
        let needEnable = true //TODO: need to implement check logic
        shareButton.isEnabled = needEnable
        shareButton.backgroundColor = needEnable ? ColorConstants.navy : .lightGray
    }

    //MARK: - Actions
    @objc private func onCancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction private func onShareTapped(_ sender: Any) {
        
    }
    
}

//MARK: - PrivateShareSelectPeopleViewDelegate

extension PrivateShareViewController: PrivateShareSelectPeopleViewDelegate {
    
    func startEditing(text: String) {
        if text.count < 2 {
            getSuggestions()
        } else {
            searchSuggestions(query: text)
        }
    }
    
    func addContact(_ contact: Contact) {
        
    }
    
    func addShare(text: String) {
        
    }
    
    func onEditorTapped() {
        
    }
}

//MARK: - PrivateShareSuggestionsViewDelegate

extension PrivateShareViewController: PrivateShareSuggestionsViewDelegate {
    
}
