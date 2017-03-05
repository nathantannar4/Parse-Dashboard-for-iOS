//
//  QuerySelectionViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 3/2/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import NTComponents
import CoreData

protocol TableQueryDelegate {
    func parseQuery(didChangeWith query: String, previewKeys: [String])
}

class QuerySelectionViewController: UITableViewController {

    var parseClass: ParseClass!
    var delegate: TableQueryDelegate?
    var keys = [String]()
    var selectedKeys: [String] = []
    var query: String!
    var savedQueries: [Query] = []
    
    convenience init(_ parseClass: ParseClass, selectedKeys: [String], query: String) {
        self.init()
        self.parseClass = parseClass
        self.selectedKeys = ["objectId", "createdAt", "updatedAt"] != selectedKeys ? selectedKeys : []
        self.query = query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color(r: 114, g: 111, b: 133)
        tableView.backgroundColor = Color(r: 114, g: 111, b: 133)
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(HelpCell.self, forCellReuseIdentifier: "HelpCell")
        navigationController?.popoverPresentationController?.backgroundColor = Color(r: 114, g: 111, b: 133)
        navigationController?.navigationBar.barTintColor = Color(r: 114, g: 111, b: 133)
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Save"), style: .plain, target: self, action: #selector(didSaveQuery))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(didApplyQuery))
        
        for field in parseClass!.fields! {
            keys.append(field.key)
        }
        
        getSavedQueries()
    }
    
    func getSavedQueries() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Query> = Query.fetchRequest()
        do {
            savedQueries = try context.fetch(request)
        } catch {
            let toast = Toast(text: "Could not load saved queries from Core Data", button: nil, color: Color(r: 114, g: 111, b: 133), height: 44)
            toast.dismissOnTap = true
            toast.show(navigationController?.view, duration: 2.0)
        }
    }
    
    func didSaveQuery() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let queryObject = NSManagedObject(entity: Query.entity(), insertInto: context)
        queryObject.setValue(query, forKey: "constraint")
        queryObject.setValue(selectedKeys, forKey: "keys")
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        savedQueries.append(queryObject as! Query)
        tableView.insertRows(at: [IndexPath(row: savedQueries.count - 1, section: 0)], with: .fade)
    }
    
    func didApplyQuery() {
        dismiss(animated: true, completion: {
            self.delegate?.parseQuery(didChangeWith: self.query, previewKeys: self.selectedKeys)
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Saved Queries"
        } else if section == 1 {
            return "New Query"
        }
        return "Preview Keys"
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.contentView.backgroundColor = Color(r: 102, g: 99, b: 122)
        header.textLabel?.textColor = .white
        header.textLabel?.font = Font.Defaults.subtitle
        return header
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
            cell.textLabel?.font = Font.Defaults.content
            cell.textLabel?.numberOfLines = 0
            if let keys = savedQueries[indexPath.row].keys as? [String] {
                cell.detailTextLabel?.text = String(describing: keys)
            }
            cell.detailTextLabel?.textColor = Color.darkGray
            cell.detailTextLabel?.font = Font.Defaults.content
            return cell
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                let cell = NTTextInputCell()
                cell.textInput.autocapitalizationType = .none
                cell.textInput.autocorrectionType = .no
                cell.textInput.returnKeyType = .done
                cell.delegate = self
                cell.textInput.text = query
                cell.textInput.placeholder = "limit=10&where={\"name\":\"John Doe\"}"
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath)  as! HelpCell
                cell.title = "Help"
                cell.leftText = ["$lt", "$lte", "$gt", "$gte", "$ne", "$in", "$nin", "$exists", "$select", "$dontSelect\n", "$all", "$regex", "order", "limit\n", "skip\n", "keys\n", "include\n", "&"]
                cell.rightText = ["Less Than", "Less Than Or Equal To", "Greater Than", "Greater Than Or Equal To", "Not Equal To", "Contained In", "Not Contained in", "A value is set for the key", "Match key value to query result", "Ignore keys with value equal to query result", "Contains all of the given values", "Match regular expression", "Specify a field to sort by", "Limit the number of objects returned by the query", "Use with limit to paginate through results", "Restrict the fields returned by the query", "Use on Pointer columns to return the full object", "Append constraints"]
                return cell
            }
        }
        let cell = UITableViewCell()
        cell.tintColor = Color.Defaults.tint
        cell.textLabel?.text = keys[indexPath.row]
        cell.textLabel?.font = Font.Defaults.content
        cell.textLabel?.textColor = Color.darkGray
        if selectedKeys.contains(keys[indexPath.row]) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            
            let query = savedQueries[indexPath.row]
            dismiss(animated: true, completion: {
                self.delegate?.parseQuery(didChangeWith: query.constraint ?? String(), previewKeys: query.keys as? [String] ?? [])
            })
        } else if indexPath.section == 1 && indexPath.row == 0 {
            if let cell = tableView.cellForRow(at: indexPath) as? NTTextInputCell {
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
                    let toast = Toast(text: "Max preview of 3 keys", button: nil, color: Color(r: 114, g: 111, b: 133), height: 44)
                    toast.dismissOnTap = true
                    toast.show(navigationController?.view, duration: 2.0)
                } else {
                    selectedKeys.insert(keys[indexPath.row], at: 0)
                    cell.accessoryType = .checkmark
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: " Edit ", handler: { action, indexpath in
            
            self.query = self.savedQueries[indexPath.row].constraint
            self.selectedKeys = self.savedQueries[indexPath.row].keys as? [String] ?? []
            self.tableView.reloadRows(at: [indexPath, IndexPath(row: 0, section: 1)], with: .none)
            self.tableView.reloadSections([2], with: .none)
        })
        editAction.backgroundColor = Color.Defaults.tint
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexpath in
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(self.savedQueries[indexPath.row])
            do {
                try context.save()
            } catch {
                let toast = Toast(text: "Could not delete server from core data", button: nil, color: Color(r: 114, g: 111, b: 133), height: 44)
                toast.dismissOnTap = true
                toast.show(self.navigationController?.view, duration: 2.0)
            }
            
            self.savedQueries.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        return [deleteAction, editAction]
    }
}

extension QuerySelectionViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        query = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

class HelpCell: UITableViewCell {
    
    var title: String? {
        didSet {
            titleLabel.text = self.title
        }
    }
    var leftText: [String]! {
        didSet {
            var text = String()
            for item in self.leftText {
                text.append(item)
                text.append("\n")
            }
            leftTextView.text = text
        }
    }
    var rightText: [String]! {
        didSet {
            var text = String()
            for item in self.rightText {
                text.append(item)
                text.append("\n")
            }
            rightTextView.text = text
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Color.Defaults.tint
        label.font = Font.Defaults.subtitle
        return label
    }()
    
    let leftTextView: NTTextView = {
        let textView = NTTextView()
        textView.isEditable = false
        textView.textColor = Color.darkGray
        return textView
    }()
    
    let rightTextView: NTTextView = {
        let textView = NTTextView()
        textView.isEditable = false
        textView.textColor = Color.darkGray
        return textView
    }()
    
    // MARK: - Initalizers
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(leftTextView)
        contentView.addSubview(rightTextView)
        
        titleLabel.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: leftTextView.topAnchor, right: contentView.rightAnchor, topConstant: 8, leftConstant: 12, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 0)
        leftTextView.anchor(titleLabel.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 7, bottomConstant: 0, rightConstant: 0, widthConstant: 85, heightConstant: 0)
        rightTextView.anchor(titleLabel.bottomAnchor, left: leftTextView.rightAnchor, bottom: contentView.bottomAnchor, right: titleLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

