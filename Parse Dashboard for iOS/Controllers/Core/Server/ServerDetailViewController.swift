//
//  ServerDetailViewController.swift
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
//  Created by Nathan Tannar on 9/5/17.
//

import UIKit

class ServerDetailViewController: PFTableViewController {
    
    // MARK: - Properties
    
    var server: PFServer
    enum ViewStyle {
        case json, formatted
    }
    var viewStyle = ViewStyle.formatted
    
    // MARK: - Initialization
    
    init(_ server: PFServer) {
        self.server = server
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
    }
    
    // MARK: Data Refresh
    
    @objc
    func refreshClass() {
       
        Parse.shared.get("/serverInfo") { [weak self] (result, json) in
            guard result.success, let json = json else {
                self?.handleError(result.error)
                self?.tableView.refreshControl?.endRefreshing()
                return
            }
            self?.server = PFServer(json)
            self?.tableView.reloadData()
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.backgroundColor = .lightBlueBackground
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        tableView.register(FieldCell.self, forCellReuseIdentifier: FieldCell.reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshClass), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
       
        title = "Server Info"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Raw"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(toggleView(sender:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(dismissInfo))
    }
    
    // MARK: - User Actions
    
    @objc
    func dismissInfo() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func toggleView(sender: UIBarButtonItem) {
        switch viewStyle {
        case .json:
            sender.image = UIImage(named: "Raw")
            viewStyle = .formatted
            tableView.reloadSections([0], with: .automatic)
        case .formatted:
            sender.image = UIImage(named: "Raw_Filled")
            viewStyle = .json
            tableView.reloadSections([0], with: .automatic)
        }
    }

    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewStyle == .formatted ? server.keys.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FieldCell.reuseIdentifier, for: indexPath)  as! FieldCell
        
        if viewStyle == .formatted {
            cell.key = server.keys[indexPath.row]
            cell.value = server.values[indexPath.row] 
            return cell
        }
        cell.key = "JSON"
        cell.value = server.json 
        return cell
    }
}
