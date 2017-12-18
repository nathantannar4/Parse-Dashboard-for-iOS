//
//  DownloadViewer.swift
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
//  Created by Nathan Tannar on 12/11/17.
//

import UIKit

open class DownloadWheel: UIView {
    
    // MARK: - Properties [Public]
    
    open var currentState: Alert.State = .inactive
    
    public private(set) var trackLayer: CAShapeLayer!
    public private(set) var progressLayer: CAShapeLayer!
    public private(set) var pulsatingLayer: CAShapeLayer!
    
    open var progress: CGFloat = 0 {
        didSet {
            percentageLabel.text = "\(Int(progress * 100)) %"
            progressLayer.strokeEnd = progress
        }
    }
    
    open var circleColor: UIColor = Alert.Style.info.color {
        didSet {
            trackLayer.fillColor = circleColor.cgColor
        }
    }
    
    open var trackStrokeColor: UIColor = .white {
        didSet {
            progressLayer.strokeColor = trackStrokeColor.cgColor
        }
    }
    
    open var trackBackgroundColor: UIColor = Alert.Style.info.color.darker(by: 10) {
        didSet {
            trackLayer.strokeColor = trackBackgroundColor.cgColor
        }
    }
    
    open var pulseColor: UIColor = Alert.Style.info.color.darker(by: 5).withAlphaComponent(0.5) {
        didSet {
            pulsatingLayer.fillColor = pulseColor.cgColor
        }
    }
    
    open var dismissOnCompletion: Bool = true
    
    public let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "0 %"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 42)
        return label
    }()
    
    public let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Downloading..."
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.light)
        return label
    }()

    // MARK: - Properties [Private]
    
    public private(set) lazy var session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
    
    public var completion: ((_ wheel: DownloadWheel, _ data: Data?, _ error: Error?)->Void)?
    
    // MARK: - Properties
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup [Private]
    
    open func setup() {
        
        setupNotificationObservers()
        setupLayers()
        addSubview(percentageLabel)
        addSubview(statusLabel)
        percentageLabel.anchor(nil, left: leftAnchor, bottom: centerYAnchor, right: rightAnchor)
        statusLabel.anchor(centerYAnchor, left: leftAnchor, bottom: nil, right: rightAnchor)
    }
    
    private func setupLayers() {
        pulsatingLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: pulseColor)
        layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        
        trackLayer = createCircleShapeLayer(strokeColor: trackBackgroundColor, fillColor: circleColor)
        layer.addSublayer(trackLayer)
        
        progressLayer = createCircleShapeLayer(strokeColor: trackStrokeColor, fillColor: .clear)
        progressLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(animatePulsatingLayer), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * .pi, clockwise: true).cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.fillColor = fillColor.cgColor
        layer.lineCap = kCALineCapRound
        layer.position = center
        return layer
    }
    
    // MARK: - Presentation/Dismissal
    
    open func present(_ viewController: UIViewController, animated: Bool = true) {
        
        guard currentState == .inactive else { return }
        currentState = .transitioning
        viewController.view.addSubview(self)
        anchorCenterToSuperview()
        anchor(widthConstant: 200, heightConstant: 200)
        if animated {
            transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.transition(with: self, duration: 0.3, options: .curveLinear, animations: {
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
            UIView.transition(with: self, duration: 0.3, options: .curveEaseOut, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 2, y: 2)
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
    open func downloadFile(from url: URL, completion: ((DownloadWheel, Data?, Error?)->Void)?) -> Self {
        self.completion = completion
        progressLayer.strokeEnd = 0
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
        return self
    }
    
    // MARK: - Layer Animations [Private]
    
    @objc
    private func animatePulsatingLayer() {
        
        let animation = CABasicAnimation(keyPath: "transform.scale.xy")
        animation.toValue = 1.5
        animation.fromValue = 1.1
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    private func animateCircle() {
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        progressLayer.add(basicAnimation, forKey: "progress")
    }
}

extension DownloadWheel: URLSessionDownloadDelegate {
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progress = percentage
        }
    }
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let data = FileManager.default.contents(atPath: location.path)
        DispatchQueue.main.async {
            self.statusLabel.text = "Complete"
            self.completion?(self, data, nil)
            if self.dismissOnCompletion {
                self.dismiss()
            }
        }
    }
    
    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Error"
            self.completion?(self, nil, error)
        }
    }
}

