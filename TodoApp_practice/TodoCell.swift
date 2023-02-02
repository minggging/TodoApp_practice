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
        print("클립 버튼 눌림 -", #fileID, #function, #line)
    }
    
    @IBAction func onDoneBtn(_ sender: UIButton) {
        doneBtn.isHidden = true
        clipBtn.isHidden = false
        todos.attributedText = todos.text?.strikeThrough()
        todos.textColor = UIColor.lightGray
        print("완료 버튼 눌림 -", #fileID, #function, #line)
        
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
}


