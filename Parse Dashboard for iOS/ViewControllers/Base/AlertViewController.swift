//
//  AlertViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 5/1/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import IGListKit

class AlertViewController: UIViewController {
    
    // MARK: - Properties
    
    override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var message: String? {
        didSet {
            messageTextView.text = message
        }
    }
    
    var additionalHeight: CGFloat = 0 {
        didSet {
            contentView.removeAllConstraints()
            contentView.anchorCenterXToSuperview()
            contentView.anchorCenterYToSuperview(constant: -additionalHeight/2)
            contentView.anchor(widthConstant: 300, heightConstant: 150 + additionalHeight)
            view.layoutIfNeeded()
        }
    }
    
    let action: ActionSheetAction
    
    // MARK: - Subviews

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    let messageTextView: InputTextView = {
        let textView = InputTextView()
        textView.font = UIFont.systemFont(ofSize: 13)
        textView.textColor = .darkGray
        textView.isEditable = false
        textView.tintColor = .logoTint
        return textView
    }()
    
    private lazy var cancelButton: RippleButton = {
        let button = RippleButton()
        button.layer.cornerRadius = 4
        button.trackTouchLocation = false
        button.ripplePercent = 1.25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitle(Localizable.cancel.localized, for: .normal)
        button.setTitleColor(.logoTint, for: .normal)
        button.rippleColor = UIColor.logoTint.withAlphaComponent(0.3)
        button.addTarget(self, action: #selector(AlertViewController.dismissViewController), for: .touchUpInside)
        return button
    }()
    
    private lazy var actionButton: RippleButton = {
        let button = RippleButton()
        button.layer.cornerRadius = 4
        button.trackTouchLocation = false
        button.ripplePercent = 1.25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.addTarget(self, action: #selector(AlertViewController.confirmAction), for: .touchUpInside)
        return button
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Initialization
    
    init(title: String?, message: String?, action: ActionSheetAction) {
        self.action = action
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        self.title = title
        self.message = message
        self.messageTextView.text = message
        if action.style == .destructive {
            actionButton.setTitle(action.title, for: .normal)
            actionButton.setTitleColor(.red, for: .normal)
            actionButton.rippleColor = UIColor.red.withAlphaComponent(0.3)
        } else {
            actionButton.setTitle(action.title, for: .normal)
            actionButton.setTitleColor(.logoTint, for: .normal)
            actionButton.rippleColor = UIColor.logoTint.withAlphaComponent(0.3)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageTextView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(actionButton)
        
        contentView.anchorCenterXToSuperview()
        contentView.anchorCenterYToSuperview(constant: -additionalHeight/2)
        contentView.anchor(widthConstant: 300, heightConstant: 150 + additionalHeight)
        
        titleLabel.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, heightConstant: 20)
        messageTextView.anchor(titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: actionButton.topAnchor, right: titleLabel.rightAnchor, topConstant: 8, leftConstant: -3.5, bottomConstant: 32)
        
        actionButton.anchor(bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 16, widthConstant: 75, heightConstant: 36)
        cancelButton.anchor(bottom: actionButton.bottomAnchor, right: actionButton.leftAnchor, rightConstant: 8, widthConstant: 75, heightConstant: 36)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        generateFeedback()
        contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .curveEaseOut, animations: { [weak self] in
            self?.contentView.transform = .identity
        }, completion: nil)
    }
    
    // MARK: - User Actions
    
    @objc
    private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func confirmAction() {
        dismiss(animated: true, completion: {
            self.action.callback?(nil)
        })
    }
    
}
