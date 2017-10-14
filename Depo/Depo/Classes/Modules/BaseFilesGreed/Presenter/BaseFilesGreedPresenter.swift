//
//  BaseFilesGreedPresenter.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BaseFilesGreedPresenter: BasePresenter, BaseFilesGreedModuleInput, BaseFilesGreedViewOutput, BaseFilesGreedInteractorOutput, BaseDataSourceForCollectionViewDelegate {    
    
    typealias Item = WrapData
    
    var dataSource = BaseDataSourceForCollectionView()

    weak var view: BaseFilesGreedViewInput!
   
    var interactor: BaseFilesGreedInteractorInput!
    
    var router: BaseFilesGreedRouterInput!
    
    var sortedRule: SortedRules = .timeDown
    
    var filters: [GeneralFilesFiltrationType] = []
    
    let custoPopUp = CustomPopUp()

    var bottomBarConfig: EditingBarConfig?
    
    weak var bottomBarPresenter: BottomSelectionTabBarModuleInput?
    
    weak var sliderModule: LBAlbumLikePreviewSliderModuleInput?
    
    var topBarConfig: GridListTopBarConfig?
    
    var alertSheetModule: AlertFilesActionsSheetModuleInput?
    
    func viewIsReady(collectionView: UICollectionView) {
        interactor.viewIsReady()
        
        dataSource.setupCollectionView(collectionView: collectionView,
                                       filters: interactor.originalFilesTypeFilter)

        dataSource.delegate = self
        
        view.setupInitialState()
        getContent()
        setupTopBar()
    }
    
    func searchByText(searchText: String) {
        uploadData(searchText)
    }
    
    func onReloadData(){
        uploadData()
    }
    
    func onStartCreatingPhotoAndVideos(){
        getContent()
    }
    
    func getContent() {
        uploadData()
    }
    
    func uploadData(_ searchText: String! = nil){
        startAsyncOperation()
        interactor.nextItems(searchText,
                             sortBy: .name,
                             sortOrder: .asc)
    }
    
    func onNextButton(){
        
    }
    
    func getContentWithFail(errorString: String) {
        
    }
    
    func serviceAreNotAvalible() {
        
    }
    
    func getContentWithSuccess(){
        if (view == nil){
            return
        }
        //
        asyncOperationSucces()
        view.stopRefresher()
        dataSource.reloadData()
        // TODO: 
//        let sectionsCount = dataSource.numberOfSections(in: dataSource.collectionView!)
//        let  needShow = (sectionsCount == 0) ? interactor.needShowNoFileView() : false
//
//        view.setCollectionViewVisibilityStatus(visibilityStatus: needShow)
    }
    
    func getNextItems() {
        interactor.nextItems(nil, sortBy: .name,
                             sortOrder: .asc)
    }
    
    func showCustomPopUpWithInformationAboutAccessToMediaLibrary(){
        view.showCustomPopUpWithInformationAboutAccessToMediaLibrary()
    }
    
    func needShowNoFileView()-> Bool{
        return interactor.needShowNoFileView()
    }
    
    func textForNoFileLbel() -> String{
        return interactor.textForNoFileLbel()
    }
    
    func textForNoFileButton() -> String{
        return interactor.textForNoFileButton()
    }
    
    func imageForNoFileImageView() -> UIImage{
        return interactor.imageForNoFileImageView()
    }
    
    func getRemoteItemsService() -> RemoteItemsService{
        return interactor.getRemoteItemsService()
    }
    
    func onCancelSelection(){
        stopEditing()
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    
    //MARK: BaseGridDataSourceForCollectionView
    
    func onItemSelected(item: BaseDataSourceItem, from data:[[BaseDataSourceItem]]) {
        if item.fileType.isUnSupportedOpenType {
            if interactor.remoteItems is MusicService {
                guard let array = data as? [[Item]],
                    let wrappered = item as? Item else{
                    return
                }
                SingleSong.default.playWithItems(list: array.flatMap({$0}), startItem: wrappered)
            } else {
                router.onItemSelected(item: item, from: data)
            }
        } else {
            custoPopUp.showCustomInfoAlert(withTitle: TextConstants.warning, withText: TextConstants.theFileIsNotSupported, okButtonText: TextConstants.ok)
        }
    }
    
    func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: 65)
    }
    
    func getCellSizeForGreed() -> CGSize {
        if (Device.isIpad) {
            return CGSize(width: 90, height: 90)
        }
        
        let w = view.getCollectionViewWidth()
        let cellW: CGFloat = (w - NumericConstants.iPhoneGreedInset * 2 - NumericConstants.iPhoneGreedHorizontalSpace * NumericConstants.numerCellInLineOnIphone)/NumericConstants.numerCellInLineOnIphone
        return CGSize(width: cellW, height: cellW)
    }
    
    func onLongPressInCell() {
        startEditing()
    }
    
    
    //MARK: - UnderNavBarBar/TopBar
    
    private func setupTopBar() {
        guard let unwrapedConfig = topBarConfig else {
            return
        }
        view.setupUnderNavBarBar(withConfig: unwrapedConfig)
    }
    
    // MARK: Bottom Bar
    
    private func startEditing() {
        //call tabbar

        view.setupSelectionStyle(isSelection: true)
        dataSource.setSelectionState(selectionState: true)
    }
    

    private func stopEditing() {
        bottomBarPresenter?.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowTabBar), object: nil)
        view.setupSelectionStyle(isSelection: false)
        dataSource.setSelectionState(selectionState: false)
    }

    func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        if (selectedItemsCount == 0){
            bottomBarPresenter?.dismiss(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowTabBar), object: nil)
        }else{
            bottomBarPresenter?.show(animated: true, onView: nil)
        }
        
        setupNewBottomBarConfig()
        self.view.selectedItemsCountChange(with: selectedItemsCount)
    }
    
    private func setupNewBottomBarConfig() {
     
        guard let barConfig = interactor.bottomBarConfig,
              let array = dataSource.getSelectedItems() as? [Item] else {
            return
        }
        
        bottomBarPresenter?.setupTabBarWith(items: array, originalConfig: barConfig)
    }
    
    func onMoreActions(ofItem: Item?, sender: Any) {
        guard let item = ofItem else {
            return
        }
        alertSheetModule?.showSpecifiedAlertSheet(with: item,
                                                  presentedBy: sender,
                                                  onSourceView: nil)
    }
    
    func onMaxSelectionExeption(){
        
    }
    
    
    //MARK: - MoreActionsViewDelegate
    
    func viewAppearanceChanged(asGrid: Bool){
        if (asGrid){
            dataSource.updateDisplayngType(type: .greed)
        }else{
            dataSource.updateDisplayngType(type: .list)
        }
    }
    
    func sortedPushed(with rule: SortedRules){
        sortedRule = rule
        view.changeSortingRepresentation(sortType: rule)
        dataSource.fetchService.performFetch(sortingRules: sortedRule,
                                             filtes: filters)
        dataSource.reloadData()
    }
    
    func selectPressed(type: MoreActionsConfig.SelectedType) {
        if (type == .Selected) {
            dataSource.selectAll(isTrue: true)
            startEditing()
        } else {
            dataSource.selectAll(isTrue: false)
            stopEditing()
        }
    }
    
    func viewWillDisappear() {
        bottomBarPresenter?.dismiss(animated: true)
        dataSource.setSelectionState(selectionState: false)
        view.setupSelectionStyle(isSelection: false)
    }
    
    func viewWillAppear() {
        if dataSource.selectedItemsArray.count > 0 {
            bottomBarPresenter?.show(animated: true, onView: nil)
        }
    }
    
    func moreActionsPressed(sender: Any) {
        dataSource.isInSelectionMode() ?
            alertSheetModule?.showAlertSheet(with: (interactor.alerSheetMoreActionsConfig?.selectionModeTypes ?? []),
                                             items: dataSource.getSelectedItems(),
                                             presentedBy: sender, onSourceView: nil) :
            alertSheetModule?.showAlertSheet(with: (interactor.alerSheetMoreActionsConfig?.initialTypes ?? []),
                                             presentedBy: sender, onSourceView: nil)
    }
    
    
    //MARK: - View outbut/ TopBar/UnderNavBarBar Delegates
    
    func viewAppearanceChangedTopBar(asGrid: Bool) {
        viewAppearanceChanged(asGrid: asGrid)
    }
    
    func sortedPushedTopBar(with rule:  MoreActionsConfig.SortRullesType) {

        var sortRule: SortedRules
        switch rule {
        case .AlphaBetricAZ:
            sortRule = .lettersAZ
        case .AlphaBetricZA:
            sortRule = .lettersZA
        case .TimeNewOld:
            sortRule = .timeUp
        case .TimeOldNew:
            sortRule = .timeDown
        case .Largest:
            sortRule = .sizeAZ
        case .Smallest:
            sortRule = .sizeZA
        default:
            sortRule = .timeUp
        }
        sortedPushed(with: sortRule)
    }
    
    func filtersTopBar(cahngedTo filters: [MoreActionsConfig.MoreActionsFileType]) {
        self.filters = filters.map{ $0.convertToGeneralFilterFileType() }
        dataSource.fetchService.controller.delegate = dataSource
        dataSource.fetchService.performFetch(sortingRules: sortedRule,
                                             filtes: self.filters)
        dataSource.reloadData()
    }
    
    
    // MARK: subModule presenter
    
    var selectedItems: [BaseDataSourceItem] {
        return dataSource.getSelectedItems()
    }

    func operationFinished(withType type: ElementTypes, response: Any?) {
        debugPrint("finished")
    }
    
    func operationFailed(withType type: ElementTypes) {
        debugPrint("failed")
    }
    
    func selectModeSelected() {
        view.setupSelectionStyle(isSelection: true)
        dataSource.setSelectionState(selectionState: true)
    }
    
    func selectAllModeSelected() {
        view.setupSelectionStyle(isSelection: true)
        dataSource.selectAll(isTrue: true)
    }
    
    func getFolder() -> Item? {
        return interactor.getFolder()
    }
    
    func getSortTypeString() -> String {
        return self.sortedRule.stringValue
    }
}
