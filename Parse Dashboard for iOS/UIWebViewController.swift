//
//  UIWebViewController.swift
//  UIWebViewController
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
//  Created by Nathan Tannar on 8/8/17.
//

import UIKit
import NTComponents
import WebKit

open class UIWebViewController: UIViewController, UIWebViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    // MARK: - Properties
    
    open var webView: UIWebView = {
        let webView = UIWebView()
        webView.allowsInlineMediaPlayback = true
        webView.allowsLinkPreview = true
        webView.backgroundColor = .white
        return webView
    }()
    
    open var url: URL?
    
    open var urlBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "URL/Search"
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.keyboardType = .URL
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.backgroundColor = .clear
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.isTranslucent = false
        return searchBar
    }()
    
    open var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.isTranslucent = false
        return toolbar
    }()
    
    open var isUITranslucent: Bool = false {
        didSet {
            toolbar.isTranslucent = isUITranslucent
            urlBar.isTranslucent = isUITranslucent
            navigationController?.navigationBar.isTranslucent = isUITranslucent
            webView.scrollView.contentInset.bottom = isUITranslucent ? 44 : 0
        }
    }
    
    private var previousScrollViewYOffset: CGFloat = 0
    
    // MARK: - Initialization
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(url: URL) {
        self.init(nibName: nil, bundle: nil)
        self.url = url
        urlBar.text = url.absoluteString
        loadRequest(forURL: url)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        webView.delegate = self
        webView.scrollView.delegate = self
        view.addSubview(webView)
        view.backgroundColor = .white
        
        navigationController?.navigationItem.leftBarButtonItem?.title = String()
        navigationController?.navigationItem.rightBarButtonItem = navigationItem(#imageLiteral(resourceName: "icon_share"), action: #selector(UIWebViewController.handleShare(_:)))
        navigationItem.titleView = urlBar
        urlBar.delegate = self
        urlBar.sizeToFit()
        
        toolbar.items = [
            navigationItem(#imageLiteral(resourceName: "icon_back"), action: #selector(UIWebViewController.goBack(_:))),
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            navigationItem(#imageLiteral(resourceName: "icon_forward"), action: #selector(UIWebViewController.goForward(_:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            navigationItem(#imageLiteral(resourceName: "icon_share"), action: #selector(UIWebViewController.handleShare(_:)))
        ]
        view.addSubview(toolbar)
        
        let inputView = NTInputAccessoryView()
        inputView.controller = self
        inputView.addSubview(toolbar)
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            toolbar.leftAnchor.constraint(equalTo: inputView.leftAnchor),
            toolbar.rightAnchor.constraint(equalTo: inputView.rightAnchor),
            toolbar.topAnchor.constraint(equalTo: inputView.topAnchor),
            toolbar.bottomAnchor.constraint(equalTo: inputView.bottomAnchor)
        ]
        _ = constraints.map{ $0.isActive = true }
    }
    
    // MARK: - Helper Methods
    
    private func navigationItem(_ icon: UIImage, action: Selector) -> UIBarButtonItem {
        let image = icon.withRenderingMode(.alwaysTemplate)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: action)
    }
    
    @discardableResult
    public func loadRequest(forURL: URL?) -> Bool {
        guard let url = url else {
            return false
        }
        let request = URLRequest(url: url)
        webView.loadRequest(request)
        return true
    }
    
    @objc open func handleShare(_ sender: UIBarButtonItem?) {
        
        guard let url = url else {
            return
        }
        
        animateNavBar(to: 20)
        updateBarButtonItems(1)
        
    
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [url] as [Any], applicationActivities: [OpenInSafariActivity()])
        activityViewController.popoverPresentationController?.barButtonItem = sender
        activityViewController.popoverPresentationController?.permittedArrowDirections = .unknown
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        present(activityViewController, animated: true, completion: nil)
    }
    
    open func makeValidURL(with text: String) -> String {
        if !text.contains("https://") {
            if text.contains("http://") {
                // Force HTTPS
                return text.replacingOccurrences(of: "http://", with: "https://")
            } else {
                if text.contains(" ") || !text.contains(".") {
                    // Make Google search
                    return "https://www.google.com/search?q=" + text.replacingOccurrences(of: " ", with: "+")
                } else {
                    return "https://" + text
                }
            }
        }
        return text
    }
    
    // MARK: - View Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = isUITranslucent
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        urlBar.resignFirstResponder()
        webView.resignFirstResponder()
        animateNavBar(to: 20)
        updateBarButtonItems(1)
    }
    
    // MARK: - WebView Navigation
    
    @objc open func goBack(_ sender: UIBarButtonItem?) {
        webView.goBack()
        if webView.canGoBack {
            updateBarButtonItems(1)
        }
    }
    
    @objc open func goForward(_ sender: UIBarButtonItem?) {
        webView.goForward()
        if webView.canGoForward {
            updateBarButtonItems(1)
        }
    }

    // MARK: - UIScrollView
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard var frame = navigationController?.navigationBar.frame else {
            return
        }
        let size = frame.size.height - 21
        let framePercentageHidden: CGFloat = (20 - frame.origin.y) / (frame.size.height - 1)
        let scrollOffset: CGFloat = scrollView.contentOffset.y
        let scrollDiff: CGFloat = scrollOffset - previousScrollViewYOffset
        let scrollHeight: CGFloat = scrollView.frame.size.height
        let scrollContentSizeHeight: CGFloat = scrollView.contentSize.height + scrollView.contentInset.bottom
        if scrollOffset <= -scrollView.contentInset.top {
            frame.origin.y = 20
            updateWebViewFrameYOrigin(0)
        }
        else if (scrollOffset + scrollHeight) >= scrollContentSizeHeight {
            frame.origin.y = -size
        }
        else {
            let size = min(20, max(-size, frame.origin.y - scrollDiff))
            frame.origin.y = size
            updateWebViewFrameYOrigin(size - 20)
        }
        
        navigationController?.navigationBar.frame = frame
        updateBarButtonItems((1 - framePercentageHidden))
        previousScrollViewYOffset = scrollOffset
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stoppedScrolling()
    }
    
    private func stoppedScrolling() {
        guard let frame = navigationController?.navigationBar.frame else {
            return
        }
        if frame.origin.y < 20 {
            animateNavBar(to: -(frame.size.height - 21))
        }
    }
    
    func updateBarButtonItems(_ alpha: CGFloat) {
        _ = navigationItem.leftBarButtonItems?.map{
            $0.customView?.alpha = alpha
        }
        _ = navigationItem.rightBarButtonItems?.map{
            $0.customView?.alpha = alpha
        }
        navigationItem.titleView?.alpha = alpha
        navigationController?.navigationBar.tintColor = navigationController?.navigationBar.tintColor?.withAlphaComponent(alpha)
    }
    
    private func animateNavBar(to y: CGFloat) {
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            guard var frame = self.navigationController?.navigationBar.frame else {
                return
            }
            let alpha: CGFloat = (frame.origin.y >= y ? 0 : 1)
            frame.origin.y = y
            self.navigationController?.navigationBar.frame = frame
            self.updateBarButtonItems(alpha)
        })
    }
    
    private func updateWebViewFrameYOrigin(_ y: CGFloat) {
        webView.frame.origin.y = isUITranslucent ? 0 : y
    }

    
    // MARK: - UIWebViewDelegate
    
    open func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        urlBar.text = request.url?.absoluteString
        return true
    }
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
    
    open func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Failed to load with error: ", error.localizedDescription)
    }
    
    // MARK: - UISearchBarDelegate
    
    open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
       
    }
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard var text = searchBar.text ?? url?.absoluteString else {
            print("Failed to load with error: Invalid URL")
            return
        }
        
        text = makeValidURL(with: text)
        
        if url?.absoluteString != text {
            url = URL(string: text)
            loadRequest(forURL: url)
        }
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty == true {
            urlBar.text = url?.absoluteString
        }
    }
}
