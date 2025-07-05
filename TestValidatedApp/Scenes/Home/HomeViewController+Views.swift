//
//  HomeViewController+Views.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 2/7/25.
//

import UIKit

extension HomeViewController {
    func setupConstraints() {
        backgroundImageView
            .top(view.topAnchor)
            .bottom(view.bottomAnchor)
            .leading(view.leadingAnchor)
            .trailing(view.trailingAnchor)
        
        vidDownImageView
            .leading(view.safeAreaLayoutGuide.leadingAnchor, constant: 24)
            .top(view.safeAreaLayoutGuide.topAnchor, constant: 36)
            .height(48)
        
        bodyView
            .top(vidDownImageView.bottomAnchor)
            .leading(view.leadingAnchor, constant: 36)
            .trailing(view.trailingAnchor, constant: -36)
            .heightMutipler(view.heightAnchor, multiplier: 1.5/3)
        
        bodyImageView
            .top(bodyView.topAnchor)
            .bottom(bodyView.bottomAnchor)
            .leading(bodyView.leadingAnchor)
            .trailing(bodyView.trailingAnchor)
        
        bodyLabel
            .leading(bodyView.leadingAnchor, constant: 36)
            .trailing(bodyView.trailingAnchor, constant: -36)
            .bottom(descriptionLabel.topAnchor)
            .topAnchor.constraint(lessThanOrEqualTo: bodyImageView.topAnchor, constant: 48).isActive = true
        
        descriptionLabel
            .centerX(bodyView.centerXAnchor)
            .leading(bodyView.leadingAnchor, constant: 36)
            .trailing(bodyView.trailingAnchor, constant: -36)
            .bottom(pasteButton.topAnchor, constant: -18)
        
        pasteButton
            .bottom(containerTextFieldView.topAnchor, constant: -18)
            .width(80)
            .height(25)
            .centerX(containerTextFieldView.centerXAnchor)
        
        clearButton
            .width(40)
            .height(25)
            .trailing(containerTextFieldView.trailingAnchor)
            .centerY(containerTextFieldView.centerYAnchor)
        
        containerTextFieldView
            .leading(bodyView.leadingAnchor, constant: 24)
            .trailing(bodyView.trailingAnchor, constant: -24)
            .height(50)
            .bottom(downloadButton.topAnchor, constant: -36)
        
        urlImageView
            .centerY(containerTextFieldView.centerYAnchor)
            .leading(containerTextFieldView.leadingAnchor, constant: 8)
            .height(15)
            .width(15)
        
        inputUrlTextField
            .centerY(containerTextFieldView.centerYAnchor)
            .leading(urlImageView.trailingAnchor, constant: 8)
            .trailing(containerTextFieldView.trailingAnchor)
            .bottom(containerTextFieldView.bottomAnchor)
        
        downloadButton
            .bottom(bodyView.bottomAnchor, constant: 0)
            .centerX(bodyView.centerXAnchor)
            .height(50)
            .widthMutipler(bodyView.widthAnchor, multiplier: 2/3)
        
        labelProgress
            .leading(progressView.leadingAnchor)
            .trailing(cancelButton.leadingAnchor, constant: -12)
            .top(bodyView.bottomAnchor, constant: 16)
        
        cancelButton
            .height(30)
            .width(50)
            .centerY(labelProgress.centerYAnchor)
            .trailing(progressView.trailingAnchor, constant: -16)

        progressView
            .widthMutipler(view.widthAnchor, multiplier: 2/3)
            .height(5)
            .top(labelProgress.bottomAnchor, constant: 16)
            .centerX(view.centerXAnchor)
        
        imageGuidToList
            .leading(view.leadingAnchor)
            .trailing(view.trailingAnchor)
            .height(100)
            .top(progressView.bottomAnchor, constant: 12)
            .bottom(buttonToListSaved.topAnchor, constant: 8)

        buttonToListSaved
            .widthMutipler(view.widthAnchor, multiplier: 2/3)
            .height(45)
            .centerX(view.centerXAnchor)
            .bottom(view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
    }
    
    func setupViews() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        view.addSubViews([
            backgroundImageView,
            vidDownImageView,
            bodyView,
            labelProgress,
            progressView,
            cancelButton,
            imageGuidToList,
            buttonToListSaved
        ])
        
        bodyView.addSubViews([
            bodyImageView,
            bodyLabel,
            descriptionLabel,
            pasteButton,
            containerTextFieldView,
            downloadButton
        ])
        
        containerTextFieldView.addSubViews([
            urlImageView,
            inputUrlTextField,
            clearButton
        ])
        
        inputUrlTextField.delegate = self
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 50
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
