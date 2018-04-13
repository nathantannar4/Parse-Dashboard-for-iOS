//
//  QueryBuilderViewController.swift
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
import Former

protocol QueryBuilderDelegate: AnyObject {
    func query(didChangeWith query: String)
}

class QueryBuilderViewController: FormViewController {
    
    // MARK: - Properties
    
    let keys: [String]
    
    var schema: PFSchema?
    
    weak var delegate: QueryBuilderDelegate?
    
    private var limit = ""
    private var skip = ""
    private var order = Order.none
    private var constraints = [QueryConstraint]()
    
    private lazy var formerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    private var lastSection: SectionFormer? {
        return former.sectionFormers.last
    }
    
    // MARK: - Initialization
    
    init(for keys: [String]) {
        self.keys = keys
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset.bottom = 100
        setupNavigationBar()
        buildForm()
    }
    
    private func setupNavigationBar() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Save"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didSaveQuery))
    }
    
    // MARK: - String Parsing
    
    func createQueryString() -> String {
        
        var queryString = String()
        if !limit.isEmpty {
            queryString.append("limit=\(limit)")
        }
        if !skip.isEmpty {
            queryString.append("&skip=\(skip)")
        }
        switch order {
        case .ascending(let field) : queryString.append("&order=\(field)")
        case .descending(let field): queryString.append("&order=-\(field)")
        default: break
        }
        
        if !constraints.isEmpty {
            var subQuery = String()
            if constraints.count == 1 {
                subQuery.append(constraints[0].queryValue(for: schema))
            } else {
                for index in 0..<(constraints.count - 1) {
                    subQuery.append(constraints[index].queryValue(for: schema) + ",")
                }
                subQuery.append(constraints[constraints.count - 1].queryValue(for: schema))
            }
            if queryString.isEmpty {
                queryString.append("where={\(subQuery)}")
            } else {
                queryString.append("&where={\(subQuery)}")
            }
        }
        
        return queryString
    }
    
    // MARK: - Former
    
    func buildForm() {
        
        former.append(sectionFormer: buildAggregationSection(), buildSortSection(), buildConstraintsSection())
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
    }
    
    func buildAggregationSection() -> SectionFormer {
        
        let limitRow = numberInputRow(title: "limit", placeholder: nil)
            .onTextChanged { [weak self] newValue in
                self?.limit = newValue
        }
        
        let skipRow = numberInputRow(title: "skip", placeholder: nil)
            .onTextChanged { [weak self] newValue in
                self?.skip = newValue
        }
        return SectionFormer(rowFormer: limitRow, skipRow).set(headerViewFormer: createHeader(title: "Aggregation"))
    }
    
    func buildSortSection() -> SectionFormer {
        
        let items = ["","Ascending", "Descending"]
        let orderRow = self.pickerInputRow(title: "Order", items: items)
        
        var fields = keys
        fields.insert("", at: 0) //Empty space for no sorting
        let fieldRow = self.pickerInputRow(title: "field", items: fields)
            .onValueChanged { newValue in
                switch items[orderRow.selectedRow] {
                case "Ascending":
                    self.order = .ascending(newValue.title)
                case "Descending":
                    self.order = .descending(newValue.title)
                default:
                    self.order = .none
                }
        }
        return SectionFormer(rowFormer: orderRow, fieldRow).set(headerViewFormer: createHeader(title: "Sort"))
    }
    
    func buildConstraintsSection() -> SectionFormer {
        
        let whereKeyRow = labelRow(title: "Add Constraint").onSelected { [weak self] _ in
            self?.former.deselect(animated: true)
            guard let lastSection = self?.lastSection, let newSection = self?.whereKeyBuilderSection() else { return }
            self?.former.insertUpdate(sectionFormer: newSection, below: lastSection)
        }
        
        return SectionFormer(rowFormer: whereKeyRow).set(headerViewFormer: createHeader(title: "Constraints"))
    }
    
    func textInputRow(title: String?, placeholder: String?) -> TextFieldRowFormer<FormerFieldCell> {
        
        return TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
                $0.titleLabel.text = title
                $0.textField.textAlignment = .right
                $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = placeholder
        }
    }
    
    func numberInputRow(title: String?, placeholder: String?) -> TextFieldRowFormer<FormerFieldCell> {
        
        let row = textInputRow(title: title, placeholder: placeholder)
        row.cell.textField.keyboardType = .numberPad
        return row
    }
    
    func pickerInputRow(title: String, items: [String]) -> InlinePickerRowFormer<FormInlinePickerCell, Any> {
        
        return InlinePickerRowFormer<FormInlinePickerCell, Any>() {
                $0.titleLabel.text = title
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.displayLabel.textColor = .darkGray
                $0.displayLabel.font = .systemFont(ofSize: 15)
            }.configure {
                $0.pickerItems = items.map { return InlinePickerItem(title: $0) }
        }
    }
    
    func labelRow(title: String) -> LabelRowFormer<FormLabelCell> {
        
        return LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.titleLabel.textColor = .logoTint
            }.configure {
                $0.text = title
        }
    }
    
    func whereKeyBuilderSection() -> SectionFormer {
        
        let constraint = QueryConstraint()
        
        var fields = keys
        fields.insert("", at: 0) //Empty space for no sorting
        let fieldRow = self.pickerInputRow(title: "whereKey", items: fields)
            .onValueChanged { newValue in
                constraint.field = newValue.title
        }
        
        let types = QueryConstraint.allTyps()
        let typeRow = pickerInputRow(title: "is", items: types.map { return $0.displayValue() } )
            .onValueChanged { item in
                for type in types {
                    if type.displayValue() == item.title {
                        constraint.key = type
                    }
                }
        }
        
        let valueRow = textInputRow(title: "value", placeholder: nil)
            .onTextChanged { newValue in
                constraint.value = newValue as AnyObject
        }
        
        let section = SectionFormer(rowFormer: fieldRow, typeRow, valueRow)
        let deleteRow = labelRow(title: Localizable.cancel.localized).onSelected { [weak self] _ in
            self?.former.deselect(animated: true)
            self?.former.removeUpdate(sectionFormer: section, rowAnimation: .top)
        }
        deleteRow.cell.titleLabel.textColor = .red
        let addRow = labelRow(title: "Add").onSelected { [weak self] _ in
            self?.former.deselect(animated: true)
            guard !constraint.queryValue(for: self?.schema).isEmpty else {
                Ping(text: "Invalid/Incomplete Constraint", style: .danger).show()
                return
            }
            guard let newSection = self?.whereKeySection(for: constraint) else { return }
            self?.constraints.append(constraint)
            self?.former.insertUpdate(sectionFormer: newSection, above: section)
            self?.former.removeUpdate(sectionFormer: section)
        }
        return section.append(rowFormer: addRow, deleteRow)
    }
    
    func whereKeySection(for constraint: QueryConstraint) -> SectionFormer {
        
        let section = SectionFormer()
        let row = labelRow(title: constraint.queryValue(for: schema)).onSelected { [weak self] _ in
            self?.former.removeUpdate(sectionFormer: section, rowAnimation: .top)
        }
        row.cell.titleLabel.textColor = .darkGray
        let deleteRow = labelRow(title: Localizable.delete.localized).onSelected { [weak self] _ in
            self?.former.deselect(animated: true)
            if let index = self?.constraints.index(of: constraint) {
                // Delete from array
                self?.constraints.remove(at: index)
            }
            self?.former.removeUpdate(sectionFormer: section, rowAnimation: .top)
        }
        deleteRow.cell.titleLabel.textColor = .red
        return section.append(rowFormer: row, deleteRow)
    }
    
    func createHeader(title: String) -> LabelViewFormer<FormLabelHeaderView> {
        
        return LabelViewFormer<FormLabelHeaderView>()
            .configure {
                $0.viewHeight = 40
                $0.text = title
                
        }
    }
    
    // MARK: - User Actions
    
    @objc
    func didSaveQuery() {
        
        delegate?.query(didChangeWith: createQueryString())
        navigationController?.popViewController(animated: true)
    }
}

enum Order {
    case ascending(String)
    case descending(String)
    case none
}

class QueryConstraint: NSObject {
    
    enum Key {
        case lt, lte, gt, gte, eq, ne, none
        
        func displayValue() -> String {
            switch self {
            case .lt:    return "Less Than"
            case .lte:   return "Less Than or Equal"
            case .gt:    return "Greater Than"
            case .gte:   return "Greater Than or Equal"
            case .eq:    return "Equal To"
            case .ne:    return "Not Equal To"
            case .none:  return ""
            }
        }
    }
    
    var key: Key?
    var field: String?
    var value: AnyObject?
    
    static func allTyps() -> [Key] {
        return [.none,.lt,.lte,.gt,.gte,.eq,.ne]
    }
    
    func queryValue(for schema: PFSchema?) -> String {
        
        guard let type = schema?.typeForField(field) else { return "" }
        guard let field = field, let value = value else { return "" }
        let stringValue: String
        if type == .string {
            stringValue = "\"\(value)\""
        } else if type == .boolean {
            stringValue = "\(value)".lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            stringValue = "\(value)"
        }
        if key == .eq {
            return "\"\(field)\":\(stringValue)"
        } else {
            return "\"\(field)\":{\"\(keyString())\":\(stringValue)}"
        }
    }
    
    func keyString() -> String {
        guard let key = key else { return "" }
        switch key {
        case .lt:
            return "$lt"
        case .lte:
            return "$lte"
        case .gt:
            return "$gt"
        case .gte:
            return "$gte"
        case .eq:
            return "$eq"
        case .ne:
            return "$ne"
        case .none:
            return ""
        }
    }
}
