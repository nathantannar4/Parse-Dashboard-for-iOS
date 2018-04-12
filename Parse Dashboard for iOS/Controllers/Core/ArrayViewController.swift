//
//  ArrayViewController.swift
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

class ArrayViewController: PFTableViewController {
    
    // MARK: - Properties
    
    private var array: NSArray
    
    // MARK: - Initialization
    
    init(_ array: NSArray, fieldName: String) {
        self.array = array
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Array View"
        setupTableView()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        
        tableView.contentInset.top = 10
        tableView.backgroundColor = .darkPurpleAccent
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(FieldCell.self, forCellReuseIdentifier: FieldCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FieldCell.reuseIdentifier, for: indexPath) as? FieldCell else {
            return UITableViewCell()
        }
        
        cell.key = "Element \(indexPath.row)"
        
        if let dict = array[indexPath.row] as? [String : AnyObject] {
            
            // Pointer
            let stringValue = String(describing: dict).replacingOccurrences(of: "[", with: " ").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: ",", with: "\n")
            cell.value = stringValue 
            cell.valueTextView.layer.cornerRadius = 3
            cell.valueTextView.layer.backgroundColor = UIColor.darkPurpleAccent.cgColor
            cell.valueTextView.textColor = .white
            cell.valueTextView.isUserInteractionEnabled = false
        } else {
            cell.value = array[indexPath.row] 
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let dict = array[indexPath.row] as? [String : AnyObject] {
            
            guard let classname = dict["className"] as? String, let objectId = dict[.objectId] as? String else { return }
            
            ParseLite.shared.get("/schemas/" + classname, completion: { [weak self] (result, json) in
                
                guard result.success, let schemaJSON = json else {
                    self?.handleError(result.error)
                    return
                }
                ParseLite.shared.get("/classes/\(classname)/\(objectId)", completion: { (result, json) in
                    guard result.success, let objectJSON = json else {
                        self?.handleError(result.error)
                        return
                    }
                    let object = PFObject(objectJSON)
                    object.schema = PFSchema(schemaJSON)
                    self?.navigationController?.pushViewController(ObjectViewController(object), animated: true)
                })
            })
        }
    }
}

