//
//  TutorialViewController.swift
//  Parse Dashboard for iOS
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 12/10/17.
//

import UIKit

struct TutorialAction {
    var sourceView: UIView?
    var sourceItem: UIBarButtonItem?
    var text: String?
    
    init(text: String?, sourceView: UIView? = nil, sourceItem: UIBarButtonItem? = nil) {
        self.text = text
        self.sourceView = sourceView
        self.sourceItem = sourceItem
    }
}

final class TutorialViewController: ViewController {
    
    // MARK: - Properties
    
    lazy var continueButton: RippleButton = { [weak self] in
        let button = RippleButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = .lightBlueAccent
        button.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
        button.setTitle(Localizable.continue.localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .highlighted)
        return button
    }()
    
    var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var onContinue: (()->Void)?
    
    // MARK: - Initialization
    
    init(action: TutorialAction) {
        super.init(nibName: nil, bundle: nil)
        label.text = action.text
        preferredContentSize = CGSize(width: 300, height: 300)
        modalPresentationStyle = .popover
        popoverPresentationController?.barButtonItem = action.sourceItem
        popoverPresentationController?.sourceView = action.sourceView
        popoverPresentationController?.sourceRect = action.sourceView?.frame ?? .zero
        popoverPresentationController?.backgroundColor = .lightBlueBackground
        popoverPresentationController?.permittedArrowDirections = .up
        popoverPresentationController?.canOverlapSourceViewRect = true
        popoverPresentationController?.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .lightBlueBackground
        
        view.addSubview(continueButton)
        view.addSubview(label)
        
        continueButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        let height = continueButton.heightAnchor.constraint(equalToConstant: 60)
        height.priority = .defaultLow
        height.isActive = true
        label.anchor(view.topAnchor, left: view.leftAnchor, bottom: continueButton.topAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
    }
    
    // MARK: - User Actions
    
    @objc
    func continueButtonPressed() {
        dismiss(animated: true, completion: {
            self.onContinue?()
        })
    }
}


// MARK: - UIPopoverPresentationControllerDelegate

extension TutorialViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
}
