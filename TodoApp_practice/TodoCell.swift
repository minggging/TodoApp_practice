//
//  TodoCell.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/26.
//

import Foundation
import UIKit

class TodoCell : UITableViewCell {
    
    @IBOutlet weak var todos : UILabel!
    
    @IBOutlet weak var clipBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
  
    
    @IBAction func onClipBtn(_ sender: UIButton) {
        clipBtn.isHidden = true
        doneBtn.isHidden = false
        todos.attributedText = todos.text?.strikeRemove()
        todos.textColor = UIColor.black

    }
    
    @IBAction func onDoneBtn(_ sender: UIButton) {
        doneBtn.isHidden = true
        clipBtn.isHidden = false
        todos.attributedText = todos.text?.strikeThrough()
        todos.textColor = UIColor.lightGray

    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    
    
    
}


extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
    
    func strikeRemove() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributeString.length))
        
//        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
}
