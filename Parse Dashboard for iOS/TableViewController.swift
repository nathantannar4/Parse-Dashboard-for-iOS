//
//  ClassViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 3/1/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import NTComponents

class ClassViewController: UITableViewController {
    
    var parseClass: ParseClass?
    var objects = [ParseObject]()
    var previewKeys = ["objectId", "createdAt", "updatedAt"]
    var query: String = "limit=1000"
    
    convenience init(parseClass: ParseClass) {
        self.init()
        self.parseClass = parseClass
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView(title: parseClass?.name)
        view.backgroundColor = Color(r: 102, g: 99, b: 122)
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 10
        tableView.backgroundColor = Color(r: 102, g: 99, b: 122)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ObjectPreviewCell.self, forCellReuseIdentifier: "ObjectPreviewCell")
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(loadObjects), for: .valueChanged)
        tableView.refreshControl = refreshControl
        navigationItem.rightBarButtonItem = { () -> UIBarButtonItem in
            let button = UIBarButtonItem(image: UIImage(named: "Filter")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.setPreferredCellLabels(sender:)))
            button.tintColor = Color.Defaults.tint
            return button
        }()
        
        loadObjects()
    }
    
    func loadObjects() {
        objects.removeAll()
        tableView.reloadSections([0], with: .automatic)
        Parse.fetch(endpoint: "/classes/" + parseClass!.name, query: "?" + query) { (json) in
            guard let results = json["results"] as? [[String: AnyObject]] else {
                Toast(text: "Unexpected Results").show(duration: 2.0)
                self.setTitleView(title: self.parseClass?.name, subtitle: "0 Objects")
                self.tableView.refreshControl?.endRefreshing()
                return
            }
            self.objects = results.map({ (dictionary) -> ParseObject in
                return ParseObject(dictionary)
            })
            DispatchQueue.main.async {
                self.tableView.reloadSections([0], with: .automatic)
                self.tableView.refreshControl?.endRefreshing()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.setTitleView(title: self.parseClass!.name, subtitle: String(results.count) + " Objects")
            }
        }
    }
    
    func setPreferredCellLabels(sender: AnyObject) {
        
        let queryVC = QuerySelectionViewController(parseClass!, selectedKeys: previewKeys, query: query)
        queryVC.delegate = self
        
        let navVC = NTNavigationController(rootViewController: queryVC)
        navVC.modalPresentationStyle = .popover
        navVC.popoverPresentationController?.permittedArrowDirections = .up
        navVC.popoverPresentationController?.delegate = self
        navVC.popoverPresentationController?.sourceView = navigationItem.titleView
        navVC.popoverPresentationController?.sourceRect = navigationItem.titleView!.bounds
        
        present(navVC, animated: true, completion: nil)
    }

    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectPreviewCell", for: indexPath) as! ObjectPreviewCell
        cell.previewKeys = previewKeys
        cell.object = objects[indexPath.row]
        cell.backgroundColor = ((indexPath.row % 2) == 0) ? Color(r: 102, g: 99, b: 122) : Color(r: 114, g: 111, b: 133)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ObjectViewController(objects[indexPath.row], parseClass: parseClass!)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ClassViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension ClassViewController: TableQueryDelegate {
    
    // MARK: - TableQueryDelegate
    
    func parseQuery(didChangeWith query: String, previewKeys: [String]) {
        if self.query != query {
            self.query = query
            self.previewKeys = previewKeys
            loadObjects()
        } else {
            self.previewKeys = previewKeys
            tableView.reloadData()
        }
    }
}
class ObjectPreviewCell: UITableViewCell {
    
    var object: ParseObject? {
        set {
            guard let object = newValue else { return }
            guard let keys = self.previewKeys else { return }
            if keys.count >= 1 {
                objectIdLabel.text = object.keys.index(of: keys[0]) != nil ? String(describing: object.values[object.keys.index(of: keys[0])!]) : "<NSNull>"
                if keys.count >= 2 {
                    createdAtLabel.text = object.keys.index(of: keys[1]) != nil ? String(describing: object.values[object.keys.index(of: keys[1])!]) : "<NSNull>"
                    if keys.count >= 3 {
                        updatedAtLabel.text = object.keys.index(of: keys[2]) != nil ? String(describing: object.values[object.keys.index(of: keys[2])!]) : "<NSNull>"
                    } else {
                        updatedAtLabel.text = String(describing: object.updatedAt)
                    }
                } else {
                    createdAtLabel.text = String(describing: object.createdAt)
                    updatedAtLabel.text = String(describing: object.updatedAt)
                }
            } else {
                objectIdLabel.text = object.id
                createdAtLabel.text = String(describing: object.createdAt)
                updatedAtLabel.text = String(describing: object.updatedAt)
            }
        }
        get {
            return nil
        }
    }
    var previewKeys: [String]?
    
    let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 3
        return view
    }()
    
    let objectIdLabel: UILabel = {
        let label = NTLabel(type: .subtitle)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    let createdAtLabel: UILabel = {
        let label = NTLabel(type: .content)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    let updatedAtLabel: UILabel = {
        let label = NTLabel(type: .content)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initalizers
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = Color(r: 102, g: 99, b: 122)
        
        addSubview(colorView)
        addSubview(objectIdLabel)
        addSubview(createdAtLabel)
        addSubview(updatedAtLabel)
        
        colorView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 5, leftConstant: 12, bottomConstant: 5, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        objectIdLabel.anchor(colorView.topAnchor, left: colorView.leftAnchor, bottom: createdAtLabel.topAnchor, right: colorView.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        
        createdAtLabel.anchor(objectIdLabel.bottomAnchor, left: objectIdLabel.leftAnchor, bottom: updatedAtLabel.topAnchor, right: objectIdLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        updatedAtLabel.anchor(createdAtLabel.bottomAnchor, left: objectIdLabel.leftAnchor, bottom: colorView.bottomAnchor, right: objectIdLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            colorView.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.colorView.backgroundColor = .white
            }
        }
    }
}
