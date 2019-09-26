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
    var questions = [SecretQuestionsResponse]()
    
    var delegate: SelectQuestionViewControllerDelegate?
    
    static func createController(questions: [SecretQuestionsResponse], delegate: SelectQuestionViewControllerDelegate) -> SelectQuestionViewController {
        let controller = SelectQuestionViewController()
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        controller.questions = questions
        controller.delegate = delegate
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    @IBOutlet private var backgroundView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet{
            newValue.textColor = UIColor.lrTealish
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.text = TextConstants.userProfileSelectQuestion
            newValue.backgroundColor = .white
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
            newValue.backgroundColor = ColorConstants.lightText.withAlphaComponent(0.5)
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.layer.cornerRadius = cornerRadius
            newValue.layer.masksToBounds = true
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 10
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowOffset = .zero
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        open()
    }
    
    @IBAction private func closeButtonTapped(_ sender: UIButton) {
        close()
    }
    
    private func open() {
        contentView.transform = NumericConstants.scaleTransform
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    func close(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.contentView.transform = NumericConstants.scaleTransform
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
        close()
    }
}
