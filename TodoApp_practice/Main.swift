//
//  ViewController.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/26.
//

import UIKit
import Alamofire
import Combine

class Main: UIViewController {
    
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var todoTextField: UITextField!
    
    @IBOutlet weak var myTodos: UILabel!
    var subscriptions = Set<AnyCancellable>()
    
    var viewModel : TodosVM = TodosVM()
    
    var todoList : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(" -", #fileID, #function, #line)
        
        todoTableView.dataSource = self
        todoTableView.delegate = self
        
        //Nib 등록
        let todoCellNib = UINib(nibName: "TodoCell", bundle: .main)
        self.todoTableView.register(todoCellNib, forCellReuseIdentifier: "TodoCell")
        
    } //viewDidLoad.
    
    @IBAction func addTodo(_ sender: UIButton) {
        print(" -", #fileID, #function, #line)
        
        guard let todoInput = self.todoTextField.text else { return }
        
        TodosAPI.addApiCall(todoInput: todoInput, completion: { (result : Result) in
            switch result {
            case .failure(let failure):
                print("addApi Called : Failure : \(failure) ")
            case .success(_):
                print("success -", #fileID, #function, #line)
                self.myTodos.isHidden = false
                self.todoList.append(todoInput)
                self.todoTableView.reloadData()
                
            }
        })
        
        
        self.todoTextField.text = nil
    } // addTodo.
    
}

extension Main : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(" -", #fileID, #function, #line)
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(" -", #fileID, #function, #line)
        let cellData = todoList[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoCell else { return UITableViewCell() }
        
        cell.todos.text = cellData
        
        return cell
    }
}

extension Main : UITableViewDelegate {
    
    //MARK: - 쎌 스와이프 버튼
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "수정") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print("수정버튼 클릭됨 -", #fileID, #function, #line)
            success(true)
        }
        
        let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print("삭제버튼 클릭됨 -", #fileID, #function, #line)
            success(true)
        }
        
        edit.backgroundColor = .systemBlue
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions:[delete,edit])

    }
    

}
