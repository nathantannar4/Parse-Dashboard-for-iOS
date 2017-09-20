//
//  QueryViewController.swift
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
//  Created by Nathan Tannar on 8/31/17.
//

import UIKit
import CoreData
import NTComponents

protocol QueryDelegate: class {
    func query(didChangeWith query: String, previewKeys: [String])
}

class QueryViewController: UITableViewController, UITextViewDelegate {
    
    // MARK: - Properties
    
    weak var delegate: QueryDelegate?
    
    private var schema: PFSchema
    private var keys = [String]()
    private var selectedKeys = [String]()
    private var query = String()
    
    var savedQueries: [Query] = []
    
    // MARK: - Initialization
    
    init(_ schma: PFSchema, selectedKeys: [String], query: String) {
        schema = schma
        super.init(nibName: nil, bundle: nil)
        self.selectedKeys = [.objectId, .createdAt, .updatedAt] != selectedKeys ? selectedKeys : []
        self.query = query
        self.keys = schema.fields?.map { return $0.key } ?? []
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        getSavedQueries()
    }
    
    // MARK: - Data Storage
    
    private func getSavedQueries() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let request: NSFetchRequest<Query> = Query.fetchRequest()
        do {
            savedQueries = try context.fetch(request)
        } catch {
            NTToast(text: "Could not load saved queries from Core Data", color: .darkPurpleBackground, height: 50).show(navigationController?.view, duration: 2.0)
        }
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.backgroundColor = .darkPurpleBackground
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(QueryHelpCell.self, forCellReuseIdentifier: QueryHelpCell.reuseIdentifier)
        tableView.register(QueryInputCell.self, forCellReuseIdentifier: QueryInputCell.reuseIdentifier)
    }
    
    private func setupNavigationBar() {
        
        navigationController?.popoverPresentationController?.backgroundColor = .darkPurpleBackground
        navigationController?.navigationBar.barTintColor = .darkPurpleBackground
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Save"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(self.didSaveQuery))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(self.didApplyQuery))
    }
    
    @objc func didSaveQuery() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let queryObject = NSManagedObject(entity: Query.entity(), insertInto: context)
        queryObject.setValue(query, forKey: "constraint")
        queryObject.setValue(selectedKeys, forKey: "keys")
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        guard let query = queryObject as? Query else {
            return
        }
        savedQueries.append(query)
        tableView.insertRows(at: [IndexPath(row: savedQueries.count - 1, section: 0)], with: .fade)
    }
    
    @objc func didApplyQuery() {
        dismiss(animated: true, completion: {
            self.delegate?.query(didChangeWith: self.query, previewKeys: self.selectedKeys)
        })
    }
    
    // MARK: - UITableViewController
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return 88
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.contentView.backgroundColor = .darkPurpleBackground
        header.textLabel?.textColor = .white
        header.textLabel?.font = Font.Default.Subtitle
        switch section {
        case 0:
            header.textLabel?.text = "Saved Queries"
            return header
        case 1:
            header.textLabel?.text = "New Query"
            return header
        case 2:
            header.textLabel?.text = "Preview Keys"
            return header
        default:
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return savedQueries.count
        } else if section == 1 {
            return 2
        }
        return keys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = savedQueries[indexPath.row].constraint
            cell.textLabel?.font = Font.Default.Body
            cell.textLabel?.numberOfLines = 0
            if let keys = savedQueries[indexPath.row].keys as? [String] {
                cell.detailTextLabel?.text = String(describing: keys)
            }
            cell.detailTextLabel?.textColor = .darkGray
            cell.detailTextLabel?.font = Font.Default.Body
            return cell
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: QueryInputCell.reuseIdentifier, for: indexPath) as! QueryInputCell
                cell.delegate = self
                cell.textInput.text = query
                cell.textInput.placeholder = "limit=10&where={\"name\":\"John Doe\"}"
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: QueryHelpCell.reuseIdentifier, for: indexPath) as! QueryHelpCell
                cell.title = "Help"
                cell.leftText = ["$lt", "$lte", "$gt", "$gte", "$ne", "$in", "$inQuery", "$nin", "$exists", "$select", "$dontSelect\n", "$all", "$regex", "order", "limit\n", "skip\n", "keys\n", "include\n", "&"]
                cell.rightText = ["Less Than", "Less Than Or Equal To", "Greater Than", "Greater Than Or Equal To", "Not Equal To", "Contained In", "Contained in query results", "Not Contained in", "A value is set for the key", "Match key value to query result", "Ignore keys with value equal to query result", "Contains all of the given values", "Match regular expression", "Specify a field to sort by", "Limit the number of objects returned by the query", "Use with limit to paginate through results", "Restrict the fields returned by the query", "Use on Pointer columns to return the full object", "Append constraints"]
                return cell
            }
        } else if indexPath.row < keys.count {
            let cell = UITableViewCell()
            cell.tintColor = Color.Default.Tint.View
            cell.textLabel?.text = keys[indexPath.row]
            cell.textLabel?.font = Font.Default.Body
            cell.textLabel?.textColor = UIColor.darkGray
            if selectedKeys.contains(keys[indexPath.row]) {
                cell.accessoryType = .checkmark
            }
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            
            let query = savedQueries[indexPath.row]
            dismiss(animated: true, completion: {
                self.delegate?.query(didChangeWith: query.constraint ?? String(), previewKeys: query.keys as? [String] ?? [])
            })
        } else if indexPath.section == 1 && indexPath.row == 0 {
            if let cell = tableView.cellForRow(at: indexPath) as? QueryInputCell {
                cell.textInput.becomeFirstResponder()
            }
        } else if indexPath.section == 2 {
            
            let cell = tableView.cellForRow(at: indexPath)!
            if cell.accessoryType == .checkmark {
                let index = selectedKeys.index(of: keys[indexPath.row])!
                selectedKeys.remove(at: index)
                cell.accessoryType = .none
            } else {
                if selectedKeys.count >= 3 {
                    NTToast(text: "Max preview of 3 keys", color: .darkPurpleBackground, height: 50).show(navigationController?.view, duration: 2.0)
                } else {
                    selectedKeys.insert(keys[indexPath.row], at: 0)
                    cell.accessoryType = .checkmark
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: " Edit ", handler: { action, indexpath in
            
            self.query = self.savedQueries[indexPath.row].constraint ?? String()
            self.selectedKeys = self.savedQueries[indexPath.row].keys as? [String] ?? []
            self.tableView.reloadRows(at: [indexPath, IndexPath(row: 0, section: 1)], with: .none)
            self.tableView.reloadSections([2], with: .none)
        })
        editAction.backgroundColor = .darkPurpleAccent
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexpath in
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(self.savedQueries[indexPath.row])
            do {
                try context.save()
            } catch {
                NTToast(text: "Could not delete server from core data", color: .darkPurpleBackground, height: 50).show(self.navigationController?.view, duration: 2.0)
            }
            
            self.savedQueries.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        return [deleteAction, editAction]
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        
        query = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
