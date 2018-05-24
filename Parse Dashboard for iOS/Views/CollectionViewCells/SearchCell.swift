/*
 MIT License
 
 Copyright © 2018 Nathan Tannar.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

final class SearchCell: UICollectionViewCell {

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = Localizable.search.localized
        searchBar.tintColor = .logoTint
        searchBar.barTintColor = .white
        searchBar.isTranslucent = false
        searchBar.clipsToBounds = true
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .darkText
            textField.backgroundColor = UIColor(white: 0.95, alpha: 1)
//            if let backgroundview = textField.subviews.first {
//                backgroundview.backgroundColor = .white
//                backgroundview.layer.cornerRadius = 10
//                backgroundview.clipsToBounds = true
//            }
        }
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        self.contentView.addSubview(searchBar)
        return searchBar
    }()
    
    lazy var stretchyView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        self.contentView.insertSubview(view, at: 0)
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        sendSubview(toBack: stretchyView)
        searchBar.frame = contentView.bounds
        stretchyView.frame = contentView.bounds
    }

}
