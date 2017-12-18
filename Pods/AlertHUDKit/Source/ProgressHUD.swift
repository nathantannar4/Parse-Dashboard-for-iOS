//
//  ProgressHUD.swift
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

open class ProgressHUD: UIView {
    
    // MARK: - Properties [Public]

    open var currentState: Alert.State = .inactive
    
    open var dismissOnCompletion: Bool = true
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22)
        label.textColor = .darkGray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        return UIVisualEffectView(effect: blurEffect)
    }()
    
    // MARK: - Properties [Private]
    
    public private(set) lazy var session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
    
    public var progressUpdate: ((_ hud: ProgressHUD, _ progress: CGFloat)->Void)?
    public var completion: ((_ hud: ProgressHUD, _ data: Data?, _ error: Error?)->Void)?
    
    // MARK: - Properties
    
    public init(title: String?, subtitle: String?, image: UIImage?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        setup()
        imageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup [Private]
    
    open func setup() {
        
        backgroundColor = UIColor.white.withAlphaComponent(0.3)
        clipsToBounds = true
        layer.cornerRadius = 16
        
        addSubview(blurView)
        addSubview(imageView)
        
        blurView.fillSuperview()
        imageView.anchor(topAnchor, left: leftAnchor, bottom: centerYAnchor, right: rightAnchor, topConstant: 12, leftConstant: 12, bottomConstant: 12, rightConstant: 12)
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        addSubview(stackView)
        stackView.anchor(centerYAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 12, leftConstant: 12, bottomConstant: 12, rightConstant: 12)
    }
    
    // MARK: - Presentation/Dismissal
    
    open func present(_ viewController: UIViewController, animated: Bool = true, duration: TimeInterval = 1.5) {
        
        guard currentState == .inactive else { return }
        currentState = .transitioning
        viewController.view.addSubview(self)
        anchorCenterToSuperview()
        anchor(widthConstant: 250, heightConstant: 250)
        if animated {
            transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveLinear, animations: {
                self.transform = .identity
            }, completion: { _ in
                self.currentState = .active
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    self.dismiss(animated: animated)
                }
            })
        } else {
            currentState = .active
        }
    }
    
    open func dismiss(animated: Bool = true) {
        
        guard currentState == .active else { return }
        currentState = .transitioning
        if animated {
            UIView.transition(with: self, duration: 0.3, options: .curveEaseOut, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
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
    open func downloadFile(from url: URL, completion: ((ProgressHUD, Data?, Error?)->Void)?) -> Self {
        self.completion = completion
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
        return self
    }
    
    @discardableResult
    open func onProgressUpdate(_ code: ((ProgressHUD, CGFloat)->Void)?) -> Self {
        self.progressUpdate = code
        return self
    }

}

extension ProgressHUD: URLSessionDownloadDelegate {
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progressUpdate?(self, percentage)
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
