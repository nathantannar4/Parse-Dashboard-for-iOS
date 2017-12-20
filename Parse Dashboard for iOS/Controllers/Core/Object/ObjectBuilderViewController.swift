//
//  ObjectBuilderViewController.swift
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
//  Created by Nathan Tannar on 12/17/17.
//

import UIKit
import AlertHUDKit
import Former
import SwiftyJSON

class ObjectBuilderViewController: FormViewController {
    
    // MARK: - Properties
    
    private var body = JSON()
    
    private let schema: PFSchema
    
    private lazy var formerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    lazy var moreSection: SectionFormer = {
        let addFieldRow = LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.titleLabel.textColor = .logoTint
            }.configure {
                $0.text = "Add Field"
            }.onSelected { [weak self] _ in
                self?.former.deselect(animated: true)
                self?.addField()
        }
        return SectionFormer(rowFormer: addFieldRow)
    }()
    
    // MARK: - Initialization
    
    init(for schema: PFSchema) {
        self.schema = schema
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
        buildForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    // MARK: - View Setup
    
    private func setupTableView() {
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 80
    }
    
    private func setupNavigationBar() {
        title = "New \(schema.name) Object"
        navigationController?.navigationBar.barTintColor = .darkPurpleBackground
        navigationController?.navigationBar.tintColor = .white
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
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelCreation))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Save"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(saveNewObject))
    }
    
    private func buildForm() {
        
        let currentFields = schema.editableFields().map { return createRow(for: $0) }
        let bodySection = SectionFormer(rowFormers: currentFields)
        former
            .append(sectionFormer: bodySection, moreSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
    }
    
    private func addField() {
        
        let types: [String] = ["Select One", .string, .boolean, .number, .date, .pointer, .array, .file]
        
        let fieldNameRow = TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
                $0.titleLabel.text = "Field Name"
                $0.textField.textAlignment = .right
                $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "ex. Foo"
        }
        
        let pointerClassRow = TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
                $0.titleLabel.text = "Target Class"
                $0.textField.textAlignment = .right
                $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "ex. _User"
        }
        
        let dataTypePickerRow = InlinePickerRowFormer<FormInlinePickerCell, Any>() {
                $0.titleLabel.text = "Data Type"
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.displayLabel.textColor = .darkGray
            }.configure {
                $0.pickerItems = types.map { return InlinePickerItem(title: $0) }
            }.onValueChanged { [weak self] item in
                if item.title == .pointer {
                    self?.former.insertUpdate(rowFormer: pointerClassRow, below: fieldNameRow, rowAnimation: .fade)
                } else {
                    self?.former.removeUpdate(rowFormer: pointerClassRow, rowAnimation: .fade)
                }
        }
    
        let addRow = LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                $0.titleLabel.textAlignment = .center
                $0.titleLabel.textColor = .logoTint
            }.configure {
                $0.text = "Add"
            }.onSelected { [weak self] _ in
                self?.former.deselect(animated: true)
                guard let className = self?.schema.name else { return }
                guard let fieldName = fieldNameRow.text, !fieldName.isEmpty else {
                    self?.handleError("Empty Field Name")
                    return
                }
                guard dataTypePickerRow.selectedRow > 0 else {
                    self?.handleError("Please Select a Data Type")
                    return
                }
                let dataType = types[dataTypePickerRow.selectedRow]
                var newField = JSON()
                newField.dictionaryObject?["className"] = className
                if dataType == .pointer {
                    guard let targetClass = pointerClassRow.text else {
                        self?.handleError("Empty Target Class")
                        return
                    }
                    newField.dictionaryObject?["fields"] = [
                        fieldName : ["type":dataType, "targetClass":targetClass]
                    ]
                } else {
                    newField.dictionaryObject?["fields"] = [fieldName : ["type":dataType]]
                }
                
                do {
                    let data = try newField.rawData()
                    Parse.shared.put("/schemas/" + className, data: data, completion: { (result, json) in
                        guard result.success, let json = json else {
                            self?.handleError(result.error)
                            return
                        }
                        let updatedSchema = PFSchema(json)
                        let index = (self?.schema.editableFields().count ?? 0) > 0 ? 1 : 0
                        self?.schema.fields?[fieldName] = updatedSchema.fields?[fieldName]
                        self?.handleSuccess("Class Updated")
                        if let newRow = self?.createRow(for: fieldName), let sectionToDelete = self?.former.sectionFormers[index] {
                            
                            let numberOfRows = self?.former.sectionFormers.first?.numberOfRows ?? 0
                            let row = index == 1 ? numberOfRows : 0 // Accounts for there being no initial fields
                            let indexPath = IndexPath(row: row, section: 0)
                            
                            self?.former
                                .removeUpdate(sectionFormer: sectionToDelete, rowAnimation: .fade)
                                .insertUpdate(rowFormer: newRow, toIndexPath: indexPath, rowAnimation: .fade)
                                .insertUpdate(sectionFormer: self!.moreSection, toSection: 1, rowAnimation: .fade)
                            
                        } else {
                            self?.handleError(nil)
                        }
                    })
                } catch let error {
                    self?.handleError(error.localizedDescription)
                }
        }
        
        let section = SectionFormer(rowFormer: fieldNameRow, dataTypePickerRow, addRow)
        let index = schema.editableFields().count > 0 ? 1 : 0 // Accounts for there being no initial fields
        former
            .removeUpdate(sectionFormer: moreSection, rowAnimation: .fade)
            .insertUpdate(sectionFormer: section, toSection: index, rowAnimation: .fade)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
    }
    
    private func createRow(for field: String) -> RowFormer {
        
        let type = schema.typeForField(field) ?? String.string
        
        switch type {
        case .string:
            return TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
                    $0.titleLabel.text = field
                    $0.textField.textAlignment = .right
                    $0.textField.inputAccessoryView = self?.formerInputAccessoryView
                }.configure {
                    $0.placeholder = type
                }.onTextChanged { [weak self] newValue in
                    // Update
                    self?.body.dictionaryObject?[field] = newValue
            }
        case .file:
            return LabelRowFormer<FormLabelCell>() {
                    $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                    $0.accessoryType = .disclosureIndicator
                }.configure {
                    $0.text = field
                    $0.subText = type
                }.onSelected { [weak self] _ in
                    self?.former.deselect(animated: true)
                    self?.handleError("Sorry, files can only be uploaded after objects creation.")
            }
        case .boolean:
            return SwitchRowFormer<FormSwitchCell>() {
                    $0.titleLabel.text = field
                    $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                    $0.switchButton.onTintColor = .logoTint
                }.configure {
                    $0.switched = false
                }.onSwitchChanged { [weak self] newValue in
                    // Update
                    self?.body.dictionaryObject?[field] = newValue
            }
        case .number:
            return TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
                    $0.titleLabel.text = field
                    $0.textField.keyboardType = .numbersAndPunctuation
                    $0.textField.textAlignment = .right
                    $0.textField.inputAccessoryView = self?.formerInputAccessoryView
                }.configure {
                    $0.placeholder = type
                }.onTextChanged { [weak self] newValue in
                    // Update
                    let numberValue = Double(newValue)
                    self?.body.dictionaryObject?[field] = numberValue
            }
        case .date:
            return InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
                    $0.titleLabel.text = field
                    $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                    $0.displayLabel.textColor = .darkGray
                    $0.displayLabel.font = .systemFont(ofSize: 15)
                }.inlineCellSetup {
                    $0.detailTextLabel?.text = type
                    $0.datePicker.datePickerMode = .dateAndTime
                }.onDateChanged { [weak self] newValue in
                    // Update
                    self?.body.dictionaryObject?[field] = [
                        "__type" : "Date",
                        "iso"    : newValue.stringify()
                    ]
                }.displayTextFromDate { date in
                    return date.string(dateStyle: .medium, timeStyle: .short)
            }
        case .pointer:
            
            let targetClass = (schema.fields?[field] as? [String:AnyObject])?["targetClass"] as? String
            
            return LabelRowFormer<FormLabelCell>() {
                    $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                    $0.accessoryType = .disclosureIndicator
                }.configure {
                    $0.text = field
                    $0.subText = targetClass
                }.onUpdate { [weak self] in
                    let pointer = self?.body.dictionaryObject?[field] as? [String:AnyObject]
                    $0.subText = pointer?[.objectId] as? String ?? targetClass
                }.onSelected { [weak self] _ in
                    self?.former.deselect(animated: true)
                    
                    guard let targetClass = targetClass else { return }
                    Parse.shared.get("/schemas/" + targetClass, completion: { [weak self] (result, json) in
                        
                        guard result.success, let schemaJSON = json else {
                            self?.handleError(result.error)
                            return
                        }
                        let schema = PFSchema(schemaJSON)
                        let selectionController = ObjectSelectorViewController(schema)
                        selectionController.delegate = self
                        selectionController.selectorKey = field
                        self?.navigationController?.pushViewController(selectionController, animated: true)
                    })
            }
        case .object, .array:
            return TextViewRowFormer<FormTextViewCell> { [weak self] in
                    $0.titleLabel.text = field
                    $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                    $0.textView.inputAccessoryView = self?.formerInputAccessoryView
                }.configure {
                    $0.placeholder = type
                }.onTextChanged { [weak self] newValue in
                    // Update
                    let arrayValue = JSON(arrayLiteral: newValue)
                    self?.body.dictionaryObject?[field] = arrayValue
            }
        case .relation:
            return LabelRowFormer<FormLabelCell>() {
                    $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                    $0.accessoryType = .disclosureIndicator
                }.configure {
                    $0.text = field
                    $0.subText = type
                }.onSelected { [weak self] _ in
                    self?.former.deselect(animated: true)
                    self?.handleError("Sorry, relations cannot be added via Parse Server's REST API")
            }
        default:
            return TextFieldRowFormer<FormerFieldCell>(instantiateType: .Nib(nibName: "FormerFieldCell")) { [weak self] in
                    $0.titleLabel.text = field
                    $0.textField.textAlignment = .right
                    $0.textField.inputAccessoryView = self?.formerInputAccessoryView
                }.configure {
                    $0.placeholder = type
                }.onTextChanged { [weak self] newValue in
                    // Update
                    self?.body.dictionaryObject?[field] = newValue
            }
        }
    }
    
    // MARK: - Error Handling
    
    func handleError(_ error: String?) {
        let error = error ?? "Unexpected Error"
        Ping(text: error, style: .danger).show()
    }
    
    func handleSuccess(_ message: String?) {
        let message = message?.capitalized ?? "Success"
        Ping(text: message, style: .success).show()
    }
    
    // MARK: - User Actions
    
    @objc
    func cancelCreation() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func saveNewObject() {
        
        do {
            let data = try body.rawData()
            Parse.shared.post("/classes/" + schema.name, data: data, completion: { [weak self] (result, json) in
                guard result.success, let json = json else {
                    self?.handleError(result.error)
                    return
                }
                let newObject = PFObject(json)
                self?.handleSuccess("Object \(newObject.id) Created")
                self?.dismiss(animated: true, completion: nil)
            })
        } catch let error {
            Ping(text: error.localizedDescription, style: .danger).show()
        }
    }
    
}

extension ObjectBuilderViewController: ObjectSelectorViewControllerDelegate {
    
    func didSelectObject(_ object: PFObject, for key: String) {
        
        guard let type = schema.typeForField(key) else { return }
        
        switch type {
        case .pointer:
            body.dictionaryObject?[key] = [
                "__type"    : "Pointer",
                "objectId"  : object.id,
                "className" : object.schema?.name
            ]
            guard let index = schema.editableFields().index(of: key) else { return }
            former.reload(indexPaths: [IndexPath(row: index, section: 0)])
        default:
            handleError(nil)
        }
    }
    
}
