//
//  ViewController.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/26.
//

import UIKit
import Alamofire


class Main: UIViewController {
    
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var todoTextField: UITextField!
    
    
    var todoList : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(" -", #fileID, #function, #line)
        
        
        todoTableView.dataSource = self
        todoTableView.delegate = self
        
        //Nib 등록
        let todoCellNib = UINib(nibName: "TodoCell", bundle: .main)
        self.todoTableView.register(todoCellNib, forCellReuseIdentifier: "TodoCell")
        
        TodosAPI.fetchTodos()
        
    } //viewDidLoad.
    
    @IBAction func addTodo(_ sender: UIButton) {
        print(" -", #fileID, #function, #line)
        
        guard let todoInput = self.todoTextField.text else { return }
        
        self.todoList.append(todoInput)
        
        self.todoTableView.reloadData()
        
        TodosAPI.addApiCall(todoInput: todoInput)
        
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
    
    
}
