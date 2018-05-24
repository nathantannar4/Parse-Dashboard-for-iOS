//
//  ConsoleView.swift
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
//  Created by Nathan Tannar on 12/20/17.
//

import UIKit

class ConsoleView: UIView {
    
    enum LogKind {
        case error, success, info
    }
    
    // MARK: - Properties
    
    static var shared = ConsoleView()
    
    private var textView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        textView.textColor = .white
        textView.font = UIFont(name: "Menlo", size: 11.0)!
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    
    func setupView() {
        
        backgroundColor = .black
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.darkGray.cgColor
        
        addSubview(textView)
        textView.fillSuperview()
    }
    
    // MARK: - Methods
    
    public func scrollToBottom() {
        if textView.bounds.height < textView.contentSize.height {
            textView.layoutManager.ensureLayout(for: textView.textContainer)
            let offset = CGPoint(x: 0, y: (textView.contentSize.height - textView.frame.size.height))
            textView.setContentOffset(offset, animated: true)
        }
    }
    
    func log(message: String, kind: LogKind = .info) {
        
        DispatchQueue.main.async {
            
            let dateString = Date().string(dateStyle: .none, timeStyle: .medium)
            
            let newText = NSMutableAttributedString(attributedString: self.textView.attributedText)
            newText.normal("\(dateString) > ", font: UIFont(name: "Menlo", size: 11.0)!, color: .white)
            switch kind {
            case .info: newText.normal(message + "\n", font: UIFont(name: "Menlo", size: 11.0)!, color: .white)
            case .error: newText.normal(message + "\n", font: UIFont(name: "Menlo", size: 11.0)!, color: .red)
            case .success: newText.normal(message + "\n", font: UIFont(name: "Menlo", size: 11.0)!, color: .green)
            }
            
            self.textView.attributedText = newText
            self.scrollToBottom()
        }
    }
}
