//
//  RaffleSummaryViewController.swift
//  Depo
//
//  Created by Ozan Salman on 30.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class RaffleSummaryViewController: BaseViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 45, height: 45)
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(RaffleSummaryCollectionViewCell.self, forCellWithReuseIdentifier: "RaffleSummaryCollectionViewCell")
        view.backgroundColor = AppColor.background.color
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private lazy var summaryPointLineView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = AppColor.lightGrayColor.cgColor
        return view
    }()
    
    private lazy var summaryPointContentView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.background.color
        return view
    }()
    
    private lazy var summaryPointLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.light, size: 10)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .right
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private var statusResponse: RaffleStatusResponse?
    private var raffleStatusElement: [RaffleElement] = [.login, .purchasePackage, .photopick, .createCollage, .photoPrint, .createStory]
    private var raffleStatusElementOppacity: [Float] = []
    private lazy var router = RouterVC()
    
    init(statusResponse: RaffleStatusResponse?) {
        self.statusResponse = statusResponse
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.gamificationRaffleBrief))
        view.backgroundColor = AppColor.background.color
        
        setupLayout()
    }
}

extension RaffleSummaryViewController: RaffleSummaryCollectionViewCellDelegate {
    func didActionButtonTapped(raffle: RaffleElement) {
        print("aaaaaaaaaaaa \(raffle.rawValue)")
    }
}

extension RaffleSummaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return raffleStatusElement.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RaffleSummaryCollectionViewCell", for: indexPath) as? RaffleSummaryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let raffle = raffleStatusElement[indexPath.row]
        let oppacity = raffleStatusElementOppacity[indexPath.row]
        cell.delegate = self
        cell.configure(raffle: raffle, imageOppacity: oppacity, statusResponse: statusResponse)
        
        if indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4 {
            cell.layer.addBorder(edge: .right, thickness: 1)
            cell.layer.addBorder(edge: .bottom, thickness: 1)
        } else {
            cell.layer.addBorder(edge: .all, thickness: 1)
        }
        return cell
    }
}

extension CALayer {
    func addBorder(edge: UIRectEdge, thickness: CGFloat) {
        let border = CALayer()
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width + thickness, y: 10, width: thickness, height: frame.height - 20)
        case .all:
            border.frame = CGRect(x: -5, y: frame.height - thickness, width: frame.width + 5, height: thickness)
        default:
            break
        }
        border.backgroundColor = AppColor.lightGrayColor.cgColor
        addSublayer(border)
    }
}

extension RaffleSummaryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let columns: CGFloat = 2
        let row: CGFloat = 3
        let spacing: CGFloat = 5
        
        let totalHorizontalSpacing = (columns - 1) * spacing
        let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / columns
        
        let totalVerticalSpacing = (row - 1) * spacing
        let itemHeight = (collectionView.bounds.height - totalVerticalSpacing) / row
        
        let itemSize = CGSize(width: itemWidth, height: 230)
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension RaffleSummaryViewController {
    private func setupLayout() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -58).isActive = true
        
        view.addSubview(summaryPointContentView)
        summaryPointContentView.translatesAutoresizingMaskIntoConstraints = false
        summaryPointContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        summaryPointContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        summaryPointContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        summaryPointContentView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(summaryPointLabel)
        summaryPointLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryPointLabel.topAnchor.constraint(equalTo: summaryPointContentView.topAnchor, constant: 10).isActive = true
        summaryPointLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        summaryPointLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        view.addSubview(summaryPointLineView)
        summaryPointLineView.translatesAutoresizingMaskIntoConstraints = false
        summaryPointLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        summaryPointLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        summaryPointLineView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -61).isActive = true
        summaryPointLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        setupPage()
    }
    
    private func setupPage() {
        for el in raffleStatusElement {
            var oppacity = 0.2
            for value in statusResponse?.details ?? [] {
                if el.rawValue == value.earnType {
                    oppacity = 1
                }
            }
            raffleStatusElementOppacity.append(Float(oppacity))
        }
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let mainText = "Toplam %@ kazandın."
        let pointCountText = "%d çekiliş puanı"
        let point = statusResponse?.totalPointsEarned
        
        let content = NSMutableAttributedString(string: mainText, attributes: [.font: UIFont.appFont(.light, size: 10)])
        let pointText = NSAttributedString(string: String(format: pointCountText, point ?? 0), attributes: [.font: UIFont.appFont(.bold, size: 10)])
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 14
        paragraphStyle.alignment = .right
        content.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, content.length))
        summaryPointLabel.attributedText = NSAttributedString(format: content, args: pointText)
    }
}
