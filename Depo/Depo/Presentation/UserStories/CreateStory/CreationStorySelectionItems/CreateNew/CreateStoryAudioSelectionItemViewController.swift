//
//  CreateStoryAudioSelectionItemViewController.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 7/1/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CreateStoryAudioSelectionItemViewController: ViewController, NibInit {
    
    private var photoStory: PhotoStory?
    private var selectedItem: WrapData?
    
    private lazy var smallPlayer: MediaPlayer = MediaPlayer()
    private lazy var isSomethingPlaing = false
    
    private var itemsArray: [WrapData] = [] {
        didSet {
            tableView.reloadData()
            defaultSelectedCell()
        }
    }
    
    @IBOutlet private var designer: CreateStoryAudioSelectionItemDesigner!
    @IBOutlet private weak var tableView: UITableView!
    
    init(forStory story: PhotoStory) {
        photoStory = story
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: .UIApplicationWillResignActive, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func applicationWillResignActive(_ notification: NSNotification) {
        smallPlayer.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSpinner()
        getMusics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBarActions()
    }
    
    @IBAction private func segmentedControlChanged(_ sender: UISegmentedControl) {
        unselectPlayingCell()
        onChangeSource(isYourUpload: sender.selectedSegmentIndex == 1)
    }
    
    private func configureNavBarActions() {
        navigationBarWithGradientStyle()
        setTitle(withString: TextConstants.createStoryAudioSelected)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.createStorySelectAudioButton,
                                                            target: self,
                                                            selector: #selector(onNextButton))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.selectFolderCancelButton,
                                                           target: self,
                                                           selector: #selector(onCancelButton))
    }
    
    private func onChangeSource(isYourUpload: Bool) {
        itemsArray.removeAll()
        showSpinner()
        if isYourUpload {
            getUploads()
        } else {
            getMusics()
        }
    }
    
    @objc private func onNextButton() {
        
        print(selectedItem?.name)
        print("Next")
    }
    
    @objc private func onCancelButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateStoryAudioSelectionItemViewController {
    
    private func getMusics() {
        CreateStoryMusicService().allItems(success: { [weak self] items in
            self?.showEmtyView(array: items)
            self?.itemsArray = items
            self?.hideSpinner()
        }) {
            assertionFailure("Failure with get getMusic request ")
            self.hideSpinner()
        }
    }
    
    private func getUploads() {
        let remoteService  =  RemoteItemsService(requestSize: 100, fieldValue: .audio)
        remoteService.nextItems(sortBy: .date,
                                sortOrder: .asc,
                                success: { [weak self] items in
                                    self?.showEmtyView(array: items)
                                    DispatchQueue.main.async {
                                        self?.itemsArray = items
                                        self?.hideSpinner()
                                    }
            }, fail: {
                assertionFailure("Failure with getUpload music request")
                self.hideSpinner()
        })
    }
    
    private func showEmtyView<T>(array: [T]) {
        if array.isEmpty {
            DispatchQueue.main.async {
                self.designer.emtyListView.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.designer.emtyListView.isHidden = true
            }
        }
    }
}

extension CreateStoryAudioSelectionItemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

extension CreateStoryAudioSelectionItemViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingCell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.createStoryAudioItemCell, for: indexPath)
        
        guard let cell = settingCell as? CreateStoryAudioItemCell else {
            assertionFailure("Unexpected cell type")
            return UITableViewCell()
        }
        cell.setCellIndexPath(index: indexPath.row)
        cell.createStoryAudioItemCellDelegate = self
        cell.selectionStyle = .none
        let item = itemsArray[indexPath.row].name
        
        if let name = item {
            cell.setTextForLabel(titleText: name)
        }
        
        return cell
    }
}

extension CreateStoryAudioSelectionItemViewController: CreateStoryAudioItemCellDelegate {
    
    func playButtonPressed(cell index: Int) {
        
        if isSomethingPlaing {
            unselectPlayingCell()
        } else {
            unselectPlayingCell {
                let cell = self.tableView.visibleCells[index]
                if let audioCell = cell as? CreateStoryAudioItemCell {
                    audioCell.onPlay()
                    self.playItem(playItem: index)
                }
            }
        }
    }
    
    func selectButtonPressed(cell index: Int) {
        unselectOtherCells {
            let cell = tableView.visibleCells[index]
            if let audioCell = cell as? CreateStoryAudioItemCell {
                audioCell.selectItem()
            }
        }
        if !itemsArray.isEmpty {
            selectedItem = itemsArray[index]
        }
    }
    
    private func unselectOtherCells(completion: () -> Void) {
        
        tableView.visibleCells.forEach {
            if let audioCell = $0 as? CreateStoryAudioItemCell {
                audioCell.deselectItem()
            }
        }
      
        completion()
    }
    
    private func defaultSelectedCell() {
        guard !tableView.visibleCells.isEmpty else {
            return
        }
        
        unselectOtherCells {
            selectedItem = itemsArray.first
            let cell = tableView.visibleCells.first
            if let audioCell = cell as? CreateStoryAudioItemCell {
                audioCell.selectItem()
            }
        }
    }
    
    private func unselectPlayingCell(completion: (() -> Void)? = nil) {
        smallPlayer.stop()
        isSomethingPlaing = false
        tableView.visibleCells.forEach {
            if let audioCell = $0 as? CreateStoryAudioItemCell {
                audioCell.isStopped()
            }
        }
        completion?()
    }
    
}

extension CreateStoryAudioSelectionItemViewController {
    
    private func playItem(playItem index: Int) {
        guard !itemsArray.isEmpty else {
            return
        }
        isSomethingPlaing = true
        smallPlayer.play(list: itemsArray, startAt: index)
    }

}
