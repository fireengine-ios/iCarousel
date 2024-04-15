//
//  RaffleConditionViewController.swift
//  Depo
//
//  Created by Ozan Salman on 9.04.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class RaffleConditionViewController: BaseViewController {
    private lazy var topContentView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.raffleCondition.color
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var topContentTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 14)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var topContentLineView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = AppColor.settingsButtonColor.cgColor
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(RaffleConditionTableViewCell.self, forCellReuseIdentifier: "RaffleConditionTableViewCell")
        view.backgroundColor = AppColor.raffleCondition.color
        view.separatorStyle = .none
        return view
    }()
    
    private lazy var bottomContentView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.raffleCondition.color
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var bottomContentTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 14)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var bottomContentLineView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = AppColor.lightGrayColor.cgColor
        return view
    }()
    
    private lazy var bottomTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = AppColor.raffleCondition.color
        view.textColor = AppColor.label.color
        view.font = .appFont(.medium, size: 8)
        view.textAlignment = .left
        return view
    }()
    
    private var statusResponse: RaffleStatusResponse?
    private var raffleStatusElement: [RaffleElement] = []
    private var raffleStatusElementOppacity: [Float] = []
    private var rulesText: String = ""
    
    init(statusResponse: RaffleStatusResponse?) {
        self.statusResponse = statusResponse
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: localized(.paycellCampaignDetailTitle))
        view.backgroundColor = AppColor.background.color
        showSpinner()
        getRaffleRules()
        configureTableView()
    }
    
    private func getRaffleRules() {
        let service = RaffleService()
        service.getRaffleConditions(id: 1) { [weak self] result in
            switch result {
            case .success(let stringResponse):
                self?.hideSpinner()
                self?.rulesText = stringResponse
                self?.setRaffleElement()
            case .failed(let error):
                self?.hideSpinner()
                UIApplication.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setRaffleElement() {
        for detail in self.statusResponse?.details ?? [] {
            let element = RaffleElement(rawValue: detail.earnType!)
            self.raffleStatusElement.append(element)
        }
        for el in raffleStatusElement {
            var oppacity = 0.2
            for value in statusResponse?.details ?? [] {
                if el.rawValue == value.earnType {
                    oppacity = 1
                }
            }
            raffleStatusElementOppacity.append(Float(oppacity))
        }
        setupPage()
        configureTableView()
    }
    
}


extension RaffleConditionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusResponse?.details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RaffleConditionTableViewCell", for: indexPath) as? RaffleConditionTableViewCell else {
            return UITableViewCell()
        }
        
        //cell.delegate = self
        let raffle = raffleStatusElement[indexPath.row]
        let oppacity = raffleStatusElementOppacity[indexPath.row]
        let earnCount = statusResponse?.details?[indexPath.row].dailyRemainingPoints ?? 1
        cell.configure(raffle: raffle, imageOppacity: oppacity, earnCount: earnCount)
        return cell
    }
}
extension RaffleConditionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? RaffleConditionTableViewCell else {
            return
        }
    }
}

extension RaffleConditionViewController {
    private func setupPage() {
        let height = (view.frame.height - 70) / 2
        
        // MARK: TOPCONTENTVIEW
        view.addSubview(topContentView)
        topContentView.translatesAutoresizingMaskIntoConstraints = false
        topContentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        topContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        topContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        topContentView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        view.addSubview(topContentTitleLabel)
        topContentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topContentTitleLabel.topAnchor.constraint(equalTo: topContentView.topAnchor, constant: 8).isActive = true
        topContentTitleLabel.leadingAnchor.constraint(equalTo: topContentView.leadingAnchor, constant: 8).isActive = true
        topContentTitleLabel.trailingAnchor.constraint(equalTo: topContentView.trailingAnchor, constant: -8).isActive = true
        
        view.addSubview(topContentLineView)
        topContentLineView.translatesAutoresizingMaskIntoConstraints = false
        topContentLineView.topAnchor.constraint(equalTo: topContentTitleLabel.bottomAnchor, constant: 8).isActive = true
        topContentLineView.leadingAnchor.constraint(equalTo: topContentView.leadingAnchor, constant: 8).isActive = true
        topContentLineView.trailingAnchor.constraint(equalTo: topContentView.trailingAnchor, constant: -8).isActive = true
        topContentLineView.heightAnchor.constraint(equalToConstant: 1).activate()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: topContentLineView.bottomAnchor, constant: 8).isActive = true
        tableView.leadingAnchor.constraint(equalTo: topContentView.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: topContentView.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: topContentView.bottomAnchor, constant: 0).isActive = true
        
        // MARK: BOTTOMCONTENTVIEW
        view.addSubview(bottomContentView)
        bottomContentView.translatesAutoresizingMaskIntoConstraints = false
        bottomContentView.topAnchor.constraint(equalTo: topContentView.bottomAnchor, constant: 20).isActive = true
        bottomContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        bottomContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        bottomContentView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        view.addSubview(bottomContentTitleLabel)
        bottomContentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomContentTitleLabel.topAnchor.constraint(equalTo: bottomContentView.topAnchor, constant: 8).isActive = true
        bottomContentTitleLabel.leadingAnchor.constraint(equalTo: bottomContentView.leadingAnchor, constant: 8).isActive = true
        bottomContentTitleLabel.trailingAnchor.constraint(equalTo: bottomContentView.trailingAnchor, constant: -8).isActive = true
        
        view.addSubview(bottomContentLineView)
        bottomContentLineView.translatesAutoresizingMaskIntoConstraints = false
        bottomContentLineView.topAnchor.constraint(equalTo: bottomContentTitleLabel.bottomAnchor, constant: 8).isActive = true
        bottomContentLineView.leadingAnchor.constraint(equalTo: bottomContentView.leadingAnchor, constant: 8).isActive = true
        bottomContentLineView.trailingAnchor.constraint(equalTo: bottomContentView.trailingAnchor, constant: -8).isActive = true
        bottomContentLineView.heightAnchor.constraint(equalToConstant: 1).activate()
        
        view.addSubview(bottomTextView)
        bottomTextView.translatesAutoresizingMaskIntoConstraints = false
        bottomTextView.topAnchor.constraint(equalTo: bottomContentLineView.bottomAnchor, constant: 8).isActive = true
        bottomTextView.leadingAnchor.constraint(equalTo: bottomContentView.leadingAnchor, constant: 8).isActive = true
        bottomTextView.trailingAnchor.constraint(equalTo: bottomContentView.trailingAnchor, constant: -8).isActive = true
        bottomTextView.bottomAnchor.constraint(equalTo: bottomContentView.bottomAnchor, constant: -8).activate()
        
        topContentTitleLabel.text = "Puan Tablosu"
        bottomContentTitleLabel.text = "Çekiliş Tablosu"
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                bottomTextView.attributedText = rulesText.getAsHtml
            } else {
                bottomTextView.attributedText = rulesText.getAsHtmldarkMode
            }
        } else {
            bottomTextView.attributedText = rulesText.getAsHtml
        }
    }
}

