//
//  CloudCodeViewController.swift
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
//  Created by Nathan Tannar on 12/19/17.
//

import UIKit
import AlertHUDKit
import CoreData

class CloudCodeViewController: PFTableViewController {
    
    // MARK: - Properties
    
    var functions: [CloudCode] = []
    var jobs: [CloudCode] = []
    
    let consoleView = ConsoleView()
    
    fileprivate var context: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        getSavedCloudCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConsoleView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    // MARK: - Data Storage
    
    private func getSavedCloudCode() {
        guard let context = context else { return }
        let request: NSFetchRequest<CloudCode> = CloudCode.fetchRequest()
        do {
            let codes = try context.fetch(request)
            functions.removeAll()
            jobs.removeAll()
            for code in codes {
                if code.isFunction == true {
                    functions.append(code)
                } else {
                    jobs.append(code)
                }
            }
        } catch let error {
            self.handleError(error.localizedDescription)
        }
    }
    
    // MARK: - Setup
    
    private func setupConsoleView() {
        
        guard let navView = navigationController?.view else { return }
        navView.addSubview(consoleView)
        consoleView.anchor(nil, left: navView.leftAnchor, bottom: navView.bottomAnchor, right: navView.rightAnchor, heightConstant: view.frame.height / 4)
    }
    
    private func setupTableView() {
        
        tableView.contentInset.bottom = view.frame.height / 4
        tableView.tableFooterView = UIView()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(white: 0.1, alpha: 1).cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0 , 0.75]
        gradient.frame = view.bounds
        tableView.backgroundView = UIView()
        tableView.backgroundView?.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupNavigationBar() {
        
        title = "Cloud Code Executor"
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .darkPurpleBackground
        navigationController?.navigationBar.barTintColor = UIColor(white: 0.1, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 24),
                NSAttributedStringKey.foregroundColor : UIColor.white
            ]
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(dismissView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addCloudCode))
        navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    }
    
    // MARK: - User Actions
    
    @objc
    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func addCloudCode() {
        
        let object = CloudCode(entity: CloudCode.entity(), insertInto: nil)
        object.body = String()
        object.endpoint = "/functions"
        object.isFunction = true
        
        let vc = CloudCodeBuilderViewController(for: object)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UITableViewController
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.contentView.backgroundColor = .darkPurpleBackground
        header.textLabel?.textColor = .white
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        let isFunctions = functions.count > 0
        
        if section == 0 && isFunctions {
            header.textLabel?.text = "Cloud Functions"
        } else {
            header.textLabel?.text = "Background Jobs"
        }
        return header
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let isFunctions = functions.count > 0
        let isJobs = jobs.count > 0
        return (isFunctions ? 1 : 0) + (isJobs ? 1 : 0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let isFunctions = functions.count > 0
        
        if section == 0 && isFunctions {
            return functions.count
        } else {
            return jobs.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.font = .boldSystemFont(ofSize: 15)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = .systemFont(ofSize: 14)
        cell.detailTextLabel?.numberOfLines = 0
        
        let isFunctions = functions.count > 0
        
        if indexPath.section == 0 && isFunctions {
            cell.textLabel?.text = functions[indexPath.row].name
            cell.detailTextLabel?.text = functions[indexPath.row].body
            return cell
        } else {
            cell.textLabel?.text = jobs[indexPath.row].name
            cell.detailTextLabel?.text = jobs[indexPath.row].body
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cloudCode = indexPath.section == 0 ? functions[indexPath.row] : jobs[indexPath.row]
        guard let endpoint = cloudCode.endpoint, let name = cloudCode.name else { return }
        let data = cloudCode.body?.data(using: .utf8)
        handeLog("POST \(endpoint)/\(name)")
        Parse.shared.post("\(endpoint)/\(name)", data: data) { (result, json) in
            guard result.success, let json = json else {
                self.handeLog(result.error)
                return
            }
            let message = json["result"] as? String ?? String(describing: json)
            self.handeLog(message)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { _, indexPath in
            
            let cloudCode = indexPath.section == 0 ? self.functions[indexPath.row] : self.jobs[indexPath.row]
            let vc = CloudCodeBuilderViewController(for: cloudCode)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        editAction.backgroundColor = .darkPurpleAccent
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
            
            guard let context = self.context else { return }
            do {
                let isFunctions = self.functions.count > 0
                
                if indexPath.section == 0 && isFunctions {
                    let function = self.functions[indexPath.row]
                    context.delete(function)
                    try context.save()
                    self.functions.remove(at: indexPath.row)
                    self.handleSuccess("Cloud Function Removed")
                    if self.functions.count == 0 {
                        self.tableView.deleteSections([indexPath.section], with: .none)
                    } else {
                        self.tableView.deleteRows(at: [indexPath], with: .none)
                    }
                } else {
                    let job = self.jobs[indexPath.row]
                    context.delete(job)
                    try context.save()
                    self.handleSuccess("Background Job Removed")
                    self.jobs.remove(at: indexPath.row)
                    if self.jobs.count == 0 {
                        self.tableView.deleteSections([indexPath.section], with: .none)
                    } else {
                        self.tableView.deleteRows(at: [indexPath], with: .none)
                    }
                }
            } catch let error {
                self.handleError(error.localizedDescription)
            }
        }
        return [deleteAction, editAction]
    }
    
    // MARK: - Error Handling
    
    override func handleSuccess(_ message: String?) {
        let message = message ?? "Success"
        print(message)
        Ping(text: message, style: .warning).show()
    }
    
    func handeLog(_ message: String?) {
        let message = message ?? String()
        let dateString = Date().string(dateStyle: .short, timeStyle: .medium)
        consoleView.log(message: "\(dateString): " + message)
    }
    
}

extension CloudCodeViewController: CloudCodeBuilderDelegate {
    
    func cloudCode(didEnterNew cloudCode: CloudCode) {
        
        guard let context = context else { return }
        if cloudCode.managedObjectContext == nil {
            context.insert(cloudCode)
        }
        do {
            try context.save()
            getSavedCloudCode()
            tableView.reloadData()
        } catch let error {
            self.handleError(error.localizedDescription)
        }
    }
}
