import UIKit

final class FullscreenTextController: UIViewController {
    
    var textToPresent = ""
    
    init(text: String) {
        textToPresent = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.TurkcellSaturaRegFont(size: 15)
        textView.textColor = .black
        return textView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupLayout()
        textView.text = textToPresent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    private func setupLayout() {
        view.addSubview(textView)
        
        let edgeInset: CGFloat = 16
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeInset).activate()
        textView.topAnchor.constraint(equalTo: view.topAnchor, constant: edgeInset).activate()
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeInset).activate()
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -edgeInset).activate()
    }
}
