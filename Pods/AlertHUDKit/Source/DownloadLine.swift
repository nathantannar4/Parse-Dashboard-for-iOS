//
//  DownloadLine.swift
//  AlertKit
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
//  Created by Nathan Tannar on 12/16/17.
//

import UIKit

open class DownloadLine: UIView {
    
    // MARK: - Properties [Public]
    
    open var currentState: Alert.State = .inactive
    
    public private(set) var trackLayer: CAShapeLayer!
    public private(set) var progressLayer: CAShapeLayer!
    public private(set) var pulsatingLayer: CAShapeLayer!
    
    open var progress: CGFloat = 0 {
        didSet {
            let referenceWidth = referenceView?.frame.width ?? 0
            UIView.animate(withDuration: 0.1) {
                self.widthConstraint?.constant = self.progress * referenceWidth
                self.layoutIfNeeded()
            }
        }
    }
    
    open var height: CGFloat {
        return 6
    }
    
    public let progressLine: UIView = {
        let line = UIView()
        line.backgroundColor = Alert.Style.info.color
        return line
    }()
    
    open var dismissOnCompletion: Bool = true
    
    private var referenceView: UIView?
    private var widthConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    // MARK: - Properties [Private]
    
    public private(set) lazy var session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
    
    public var completion: ((_ line: DownloadLine, _ data: Data?, _ error: Error?)->Void)?
    
    // MARK: - Properties
    
    public init() {
        super.init(frame: .zero)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup [Private]
    
    open func setup() {
        backgroundColor = Alert.Style.info.color.withAlphaComponent(0.3)
        addSubview(progressLine)
        widthConstraint = progressLine.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, widthConstant: .leastNonzeroMagnitude).last
    }
    
    // MARK: - Presentation/Dismissal
    
    open func present(_ viewController: UIViewController, topAnchor: NSLayoutYAxisAnchor, animated: Bool = true) {
        
        guard currentState == .inactive else { return }
        currentState = .transitioning
        viewController.view.addSubview(self)
        referenceView = viewController.view
        topConstraint = anchor(topAnchor, left: viewController.view.leftAnchor, right: viewController.view.rightAnchor, heightConstant: height).first
        present(animated: animated)
    }
    
    open func present(_ viewController: UIViewController, bottomAnchor: NSLayoutYAxisAnchor, animated: Bool = true) {
        
        guard currentState == .inactive else { return }
        currentState = .transitioning
        viewController.view.addSubview(self)
        referenceView = viewController.view
        bottomConstraint = anchor(left: viewController.view.leftAnchor, bottom: bottomAnchor, right: viewController.view.rightAnchor, heightConstant: height)[1]
        present(animated: animated)
    }
    
    private func present(animated: Bool = true) {
        
        if animated {
            alpha = 0
            let y = topConstraint != nil ? -height : height
            transform = CGAffineTransform(translationX: 0, y: y)
            UIView.transition(with: self, duration: 0.3, options: .curveEaseOut, animations: {
                self.alpha = 1
                self.transform = .identity
            }, completion: { _ in
                self.currentState = .active
                
            })
        } else {
            currentState = .active
        }
    }
    
    open func dismiss(animated: Bool = true) {
        
        guard currentState == .active else { return }
        currentState = .transitioning
        if animated {
            let y = topConstraint != nil ? -height : height
            UIView.transition(with: self, duration: 0.3, options: .curveLinear, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(translationX: 0, y: y)
            }, completion: { _ in
                self.currentState = .inactive
                self.removeFromSuperview()
            })
        } else {
            currentState = .inactive
            removeFromSuperview()
        }
    }
    
    // MARK: - Download
    
    /// Resets the current sessions and resumes a new download task with the provided URL
    ///
    /// - Parameters:
    ///   - url: Endpoint to download
    ///   - completion: Action upon completion
    /// - Returns: Self
    @discardableResult
    open func downloadFile(from url: URL, completion: ((DownloadLine, Data?, Error?)->Void)?) -> Self {
        self.completion = completion
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
        return self
    }
    
    // MARK: - Layer Animations [Private]
    
    
}

extension DownloadLine: URLSessionDownloadDelegate {
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progress = percentage
        }
    }
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let data = FileManager.default.contents(atPath: location.path)
        DispatchQueue.main.async {
            self.completion?(self, data, nil)
            if self.dismissOnCompletion {
                self.dismiss()
            }
        }
    }
    
    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DispatchQueue.main.async {
            self.completion?(self, nil, error)
        }
    }
}


