//
//  todosVM.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/27.
//

import Foundation

class todosVM : NSObject {
    
    private var todosAPI : TodosAPI!
    
    override init() {
        super .init()
        TodosAPI.fetchTodos()
    }
    
}

// 미완성. 뷰모델 공부 후 재도전
