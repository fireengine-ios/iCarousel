protocol BackButtonActions {
    func removeBackButtonTitle()
}
extension BackButtonActions where Self: UIViewController {
    func removeBackButtonTitle() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
