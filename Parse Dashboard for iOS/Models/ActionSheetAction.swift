//
//  ActionSheetAction.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 5/1/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import IGListKit

final class ActionSheetAction: ListDiffable {
    
    typealias ActionSelectionCallback = (AnyObject?)->Void
    
    // MARK: - Properties
    
    var title: String
    
    var image: UIImage?
    
    var callback: ActionSelectionCallback?
    
    var style: UIAlertActionStyle
    
    // MARK: - Initialization
    
    init(title: String, image: UIImage? = nil, style: UIAlertActionStyle, callback: ActionSelectionCallback?) {
        self.title = title
        self.image = image
        self.style = style
        self.callback = callback
    }
    
    // MARK: - ListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return title as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let action = object as? ActionSheetAction else { return false }
        return action.title == title
    }
    
}
