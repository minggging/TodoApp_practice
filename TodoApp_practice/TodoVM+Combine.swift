//
//  TodoVM+Combine.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/02/12.
//

import Foundation
import UIKit
import Combine

extension TodosVM {

    /// 할 일 가져오기 - Combine
    func fetchTodosWithCombine(page : Int = 1) {
        print(" -", #fileID, #function, #line)
        
        if isLoading {
            print("로딩 중입니다.")
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            
            TodosAPI.fetchTodosWithCombine(page: page)
                .sink { result in
                    switch result {
                    case .finished:
                        self.isLoading = false
                        print("fetchTodosWithCombine : finished")
                        
                        
                    case .failure(let failure):
                        print("failure: \(failure)")
                        TodosAPI.handleError(failure)
                        self.isLoading = false
                        
                    }
                    
                } receiveValue: { todosResponse in
                    print("fetchTodos success -", #fileID, #function, #line)
                    
                    if let fetchTodos : [Todo] = todosResponse.data,
                       let pageInfo : Meta = todosResponse.meta {
                        if page == 1 {
                            self.todoList = fetchTodos
                        } else {
                            self.todoList.append(contentsOf: fetchTodos)
                        }
                        self.pageInfo = pageInfo
                    }
                    
                }
                .store(in: &self.subscriptions)
        })
    }
    
    /// 할 일 더 가져오기 - Combine
    func fetchMoreWithCombine() {
        print(" -", #fileID, #function, #line)
        guard let pageInfo = self.pageInfo,
              pageInfo.hasNext(),
              !isLoading else {
            return print("다음페이지가 없다")
        }
                
                if searchTerm.count > 0 {
                    self.searchTodosWithCombine(searchTerm: searchTerm, page: self.currentPage + 1)
                } else {
                    self.fetchTodosWithCombine(page: currentPage + 1)
                }
    }
    
    /// 할 일 새로고침 - Combine
    func fetchRefreshWithCombine(){
        print(#fileID, #function, #line, "- ")
        self.fetchTodosWithCombine(page: 1)
    }
    
    
    /// : 할 일 추가 - Combine
    func addATodoWithCombine(todoInput : String) {
        print(" -", #fileID, #function, #line)
        TodosAPI.addApiCallWithCombine(todoInput: todoInput)
            .sink { result in
                switch result {
                case .finished:
                    print("addATodoWithCombine Called : Finishid")
                case .failure(let failure):
                    print("addATodoWithCombine Called : Failure \(failure)")
                        TodosAPI.handleError(failure)
                }
            } receiveValue: { todoResponse in
                self.isLoading = false
                if let addedTodo = todoResponse.data {
                    self.todoList.insert(addedTodo, at: 0)
                }
            }
            .store(in: &subscriptions)
    }
    
    /// 할일 검색하기 - Combine
    /// - Parameters:
    ///   - searchTerm: 검색어
    ///   - page: 페이지
    func searchTodosWithCombine(searchTerm: String, page: Int = 1){
        print(#fileID, #function, #line, "- ")
        
        if searchTerm.count < 1 {
            print("검색어가 없습니다")
            return
        }
        
        if isLoading {
            print("로딩중입니다...")
            return
        }
        
#warning("TODO : -notifySearchDataNotFound 이벤트 콤바인으로 바꿔보기")
        self.notifySearchDataNotFound?(false)
        
        if page == 1 {
            self.todoList = []
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            // 서비스 로직
            TodosAPI.searchTodosWithCombine(searchTerm: searchTerm)
                .sink(receiveCompletion: { result in
                    switch result {
                    case .finished:
                        print("searchTodosWithCombine Called : Finishid")
                    case .failure(let failure):
                        print("failure: \(failure)")
                        TodosAPI.handleError(failure)
                        self.notifySearchDataNotFound?(true)
                        self.isLoading = false
                        
                    }
                }, receiveValue: { response in
                    self.isLoading = false
                    
                    if let searchedTodos : [Todo] = response.data,
                       let pageInfo : Meta = response.meta{
                        if page == 1 {
                            self.todoList = searchedTodos
                        } else {
                            self.todoList.append(contentsOf: searchedTodos)
                        }
                        self.pageInfo = pageInfo
                    }
                    
                })
                .store(in: &self.subscriptions)
        })
    }
    
    
} //TodoVM
