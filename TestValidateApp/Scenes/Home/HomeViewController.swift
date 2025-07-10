//
//  HomeViewController.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import UIKit

class HomeViewController: UIViewController {
    let viewModel: HomeViewModel
    
    var isDownloading: Bool = false
    
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .launchScreen
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var bodyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var bodyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let description = NSAttributedString(string: "Video Download",
                                             attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 36,
                                                                                                         weight: .bold)])
        
        label.attributedText = description
        return label
    }()
    
    lazy var containerTextFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var inputUrlTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 12)
        textField.placeholder = "Insert your video link here..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var urlImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = .linkLogo
        return imageView
    }()
    
    lazy var downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .buttonBg
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dowloadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var labelProgress: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .systemGray6
        progressView.progressTintColor = .systemGreen
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 2.5
        progressView.isHidden = true
        return progressView
    }()
    
    lazy var buttonToListSaved: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Saved Video", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .buttonBg
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(goToListVideosSaved), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var pasteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Paste", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pasteButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "Paste_button"
        return button
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(.clearButtonLogo, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupViews()
        setupConstraints()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func bindViewModel() {
    }
}

extension HomeViewController {
    private func resetInput() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else { return }
            self.cancelButton.isHidden = true
            self.labelProgress.isHidden = true
            self.progressView.isHidden = true
            self.labelProgress.text = ""
            self.inputUrlTextField.text = ""
            self.progressView.setProgress(0, animated: false)
        })
    }
    
    private func handleDownloadProgress(_ progress: Float) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.cancelButton.isHidden = false
            self.progressView.isHidden = false
            self.labelProgress.isHidden = false
            self.labelProgress.text = "Progress: \(Int(progress * 100))%"
            self.progressView.setProgress(progress, animated: true)
        }
    }
    
    private func handleFinsihedDownload() {
        DispatchQueue.main.async {
            self.viewModel.showAlert(title: "Download Success",
                                     message: "Video will saved on your app")
            self.cancelButton.isHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.resetInput()
        })
    }
    
    @objc func clearButtonTapped() {
        resetInput()
    }
    
    @objc func pasteButtonTapped() {
        let pasteBoard: UIPasteboard = UIPasteboard.general
        inputUrlTextField.text = pasteBoard.string
        title = "Pasted"
    }
    
    @objc func goToListVideosSaved() {
        guard let navigationController = self.navigationController else { return }
        viewModel.navigateToVideosSaved(navigationController)
    }
    
    @objc func cancelButtonTapped() {
        viewModel.cancelDownload()
        resetInput()
    }
    
    @objc func dowloadButtonTapped() {
        view.endEditing(true)
        
        let urlString = inputUrlTextField.text ?? ""
        handleDownloadProgress(0.0)
        
        if !urlString.isEmpty && viewModel.validateURL(urlString) {
            if Reachability.isConnectedToNetwork() {
                if urlString.contains(".mp4") {
                    viewModel.downloadVideo(
                        from: urlString,
                        progressCompletion: {[weak self] progress in
                            self?.handleDownloadProgress(progress)
                            
                        }, didFinishTask: {[weak self] in
                            self?.handleFinsihedDownload()
                        })
                }
                
                if urlString.contains(".m3u8") {
                    viewModel.downloadHLSVideo(
                        from: urlString,
                        progressCompletion: {[weak self] progress in
                            self?.handleDownloadProgress(progress)
                            
                        }, didFinishTask: {[weak self] in
                            self?.handleFinsihedDownload()
                        })
                }
                
            } else {
                viewModel.showAlert(title: "Network Error", message: "Please check your network connection!")
            }
            
        } else {
            viewModel.showAlert(title: "Invalid URL", message: "Please check your URL or do not empty!")
        }
    }
}
