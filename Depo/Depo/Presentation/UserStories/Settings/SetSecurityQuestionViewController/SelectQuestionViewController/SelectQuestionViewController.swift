//
//  SelectQuestionViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 9/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SelectQuestionViewControllerDelegate {
    func didSelectQuestion(question: SecretQuestionsResponse?)
}

final class SelectQuestionViewController: UIViewController, NibInit  {
    
    private let cornerRadius: CGFloat = 8
    private let separatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private lazy var accountService = AccountService()
    private let analyticsService: AnalyticsService = factory.resolve()
    private var fromInfoView: Bool = false
    var questions = [SecretQuestionsResponse]()
    
    var delegate: SelectQuestionViewControllerDelegate?
    
    static func createController(questions: [SecretQuestionsResponse], delegate: SelectQuestionViewControllerDelegate, fromInfoView: Bool = false) -> SelectQuestionViewController {
        let controller = SelectQuestionViewController()
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        controller.questions = questions
        controller.delegate = delegate
        controller.fromInfoView = fromInfoView
        return controller
    }
    
    @IBOutlet private var backgroundView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.clear
        }
    }
    
    
    @IBOutlet private weak var headerLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.light, size: 14.0)
            newValue.text = ""
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet{
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12.0)
            newValue.text = TextConstants.userProfileSelectQuestion
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.register(nibCell: QuestionCell.self)
            newValue.delegate = self
            newValue.dataSource = self
            newValue.tableFooterView = UIView()
            newValue.tableHeaderView = UIView()
            newValue.separatorInset = separatorInsets
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        willSet{
            newValue.backgroundColor = AppColor.itemSeperator.color
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.layer.cornerRadius = cornerRadius
            newValue.layer.masksToBounds = true
            newValue.layer.shadowColor = UIColor.clear.cgColor
            newValue.layer.shadowRadius = 8
            newValue.layer.shadowOpacity = 0
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.darkTextAndLightGray.cgColor
            newValue.layer.shadowOffset = .zero
        }
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()

        analyticsService.logScreen(screen: .securityQuestionSelect)
        analyticsService.trackDimentionsEveryClickGA(screen: .securityQuestionSelect)
        setTitle(withString: TextConstants.userProfileSecretQuestion)
        
        if fromInfoView {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 400).activate()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        open()
    }
    @IBOutlet weak var cellsHeightConstraint: NSLayoutConstraint!
    
    @IBAction private func closeButtonTapped(_ sender: UIButton) {
        close()
    }
    
    private func open() {
        cellsHeightConstraint.constant = CGFloat(questions.count) * 61.0
    }
    
    func close(completion: VoidHandler? = nil) {
        self.view.alpha = 0
        self.contentView.transform = NumericConstants.scaleTransform
        
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
}

extension SelectQuestionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeue(reusable: QuestionCell.self, for: indexPath)
        cell.setupLabel(question: questions[indexPath.row].text)
        return cell
    }
}

extension SelectQuestionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectQuestion(question: questions[indexPath.row])
        analyticsService.trackCustomGAEvent(eventCategory: .securityQuestion,
                                            eventActions: .click,
                                            eventLabel: .clickSecurityQuestion(number: indexPath.row))
        close()
    }
}
