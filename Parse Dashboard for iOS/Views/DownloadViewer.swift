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

class DownloadViewer: UIView {
    
    // MARK: - Properties
    
    let shapeLayer = CAShapeLayer()
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "0 %"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 42)
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Downloading..."
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.light)
        return label
    }()
    
    lazy var session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
    
    var completion: ((Data?)->Void)?
    
    // MARK: - Properties
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        

        addSubview(percentageLabel)
        addSubview(statusLabel)
        percentageLabel.anchor(nil, left: leftAnchor, bottom: centerYAnchor, right: rightAnchor)
        statusLabel.anchor(centerYAnchor, left: leftAnchor, bottom: nil, right: rightAnchor)
        
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.darkPurpleAccent.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = kCALineCapRound
        trackLayer.position = center
        layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.position = center
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0

        layer.addSublayer(shapeLayer)
        
        addPulseAnimation()
    }
    
    func addPulseAnimation(){
        let pulse = PulseEffectCirlce(centerPosition: center)
        pulse.backgroundColor = UIColor.darkPurpleBackground.cgColor
        layer.insertSublayer(pulse, at: 0)
    }
    
    
    func downloadFile(from url: URL, completion: ((Data?)->Void)?) {
        self.completion = completion
        shapeLayer.strokeEnd = 0
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }
}

extension DownloadViewer: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(Int(percentage * 100)) %"
            self.shapeLayer.strokeEnd = percentage
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let data = FileManager.default.contents(atPath: location.path)
        DispatchQueue.main.async {
            self.completion?(data)
            self.statusLabel.text = "Complete"
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DispatchQueue.main.async {
            self.completion?(nil)
        }
    }
}

/// Pulse Effect Circle
class PulseEffectCirlce: CALayer {
    
    /// Radius of Circle
    private var radius: CGFloat = 100
    
    /// Repeat count of animation
    private var repeatedCount: Float = .infinity
    
    /// Animatin duration
    private var animationDuration: TimeInterval = 0.75
    
    // Need to implement that, because otherwise it can't find
    // the constructor init(layer:AnyObject!)
    // Doesn't seem to look in the super class
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    /// Init with position of Circle layer center position
    init(centerPosition position: CGPoint) {
        super.init()
        
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0.0
        
        self.backgroundColor = UIColor.blue.cgColor
        
        self.position = position
        
        DispatchQueue.global(qos: .background).async {
            let groupedAnimation = self.setupAnimationGroup()
            self.setPulse(radius: self.radius)
            
            DispatchQueue.main.async {
                self.add(groupedAnimation, forKey: "pulseEffect")
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Set pulse animation with Radius
    private func setPulse(radius maximumRadius: CGFloat) {
        self.radius = maximumRadius
        
        let tempPosition = self.position // Center position
        let diameter = self.radius * 2
        
        self.bounds = CGRect(x: 0.0, y: 0.0, width: diameter, height: diameter)
        self.cornerRadius = self.radius
        self.position = tempPosition
    }
    
    /// Grouping animation
    private func setupAnimationGroup() -> CAAnimationGroup {
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = self.animationDuration // animation duration
        animationGroup.repeatCount = self.repeatedCount // repeat count
        animationGroup.autoreverses = true
        animationGroup.isRemovedOnCompletion = false
        
        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animationGroup.timingFunction = defaultCurve // timingFunction
        
        animationGroup.animations = [setScaleAnimation(), setOpacityAniamtion()]
        
        return animationGroup
    }
    
    /// Scale animation
    private func setScaleAnimation() -> CABasicAnimation {
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 1.1
        scaleAnimation.toValue = 1.5
        scaleAnimation.duration = animationDuration
        return scaleAnimation
    }
    
    /// opacity animation
    private  func setOpacityAniamtion() -> CAKeyframeAnimation {
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = self.animationDuration
        opacityAnimation.values = [0.7, 0.5]
        opacityAnimation.keyTimes = [0, 0.75]
        opacityAnimation.isRemovedOnCompletion = false
        return opacityAnimation
        
    }
}
