//
//  AlertPromptViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 5/1/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit

final class AlertPromptViewController: AlertViewController, UITextViewDelegate {
    
    // MARK: - Initialization
    
    init(title: String?, initialValue: String?, placeholder: String?, action: ActionSheetAction) {
        super.init(title: title, message: initialValue, action: action)
        messageTextView.placeholder = placeholder
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextView.isEditable = true
        messageTextView.layer.cornerRadius = 4
        messageTextView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        messageTextView.delegate = self
        messageTextView.isScrollEnabled = true
    }
    
    // MARK: - User Actions
    
    override func confirmAction() {
        let text = messageTextView.text
        dismiss(animated: true, completion: {
            self.action.callback?(text as AnyObject)
        })
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.contentView.transform = CGAffineTransform(translationX: 0, y: -100)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.contentView.transform = .identity
        }
    }
}
