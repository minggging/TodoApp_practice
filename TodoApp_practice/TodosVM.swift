//
//  todosVM.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/27.
//

import Foundation
import Combine

class TodosVM : ObservableObject {
    
    @Published var todoList : [Todo] = [] {
        didSet {
            print(#fileID, #function, #line, "- ")
            self.notifyTodosChanged?(todoList)
        }
    }
    @Published var isLoading : Bool = false
    
    var pageInfo : Meta? = nil {
        didSet {
            print(#fileID, #function, #line, "- pageInfo: \(pageInfo)")
            
            // 다음페이지 있는지 여부 이벤트
            self.notifyHasNextPage?(pageInfo?.hasNext() ?? true)
            
            // 현재 페이지 변경 이벤트
            self.notifyCurrentPageChanged?(currentPage)
        }
    }
    
    var currentPage: Int {
        get {
            if let pageInfo = self.pageInfo,
               let currentPage = pageInfo.currentPage {
                return currentPage
            } else {
                return 1
            }
        }
    }

    /// 다음페이지 있는지  이벤트
    var notifyHasNextPage : ((_ hasNext: Bool) -> Void)? = nil

    /// 현재페이지 변경 이벤트
    var notifyCurrentPageChanged : ((Int) -> Void)? = nil

    /// 검색결과 없음 여부 이벤트
    var notifySearchDataNotFound : ((_ noContent: Bool) -> Void)? = nil

    /// 서치바 관련 DispatchWorkItem
    var searchTermInputWorkItem : DispatchWorkItem? = nil

    /// 데이터 변경 이벤트
    var notifyTodosChanged : (([Todo]) -> Void)? = nil

    /// 검색어
    var searchTerm: String = "" {
        didSet {
            print(#fileID, #function, #line, "- searchTerm: \(searchTerm)")
            if searchTerm.count > 0 {
                self.searchTodos(searchTerm: searchTerm)
            } else {
                self.fetchTodos()
            }
        }
    }

    
    //MARK: - init
    init(){
        print(" -", #fileID, #function, #line)
        fetchTodos()
    }// init.
    
    /// 할 일 가져오기
    func fetchTodos(page : Int = 1) {
        print(" -", #fileID, #function, #line)
        
        if isLoading {
            print("로딩 중입니다.")
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            
            TodosAPI.fetchTodos(page: page, completion: { [weak self] (result: Result) in
                guard let self = self else { return }
                
                switch result {
                case .success(let todosResponse):
                    self.isLoading = false

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
                    
                case .failure(let failure):
                    print("failure: \(failure)")
                    TodosAPI.handleError(failure)
                    self.isLoading = false
                }
                
            })
        }
                                      
                                      
        )}
    
    /// 할 일 더 가져오기
    func fetchMore() {
        print(" -", #fileID, #function, #line)
        guard let pageInfo = self.pageInfo,
              pageInfo.hasNext(),
              !isLoading else {
            return print("다음페이지가 없다")
        }

        if searchTerm.count > 0 {
            self.searchTodos(searchTerm: searchTerm, page: self.currentPage + 1)
        } else {
            self.fetchTodos(page: currentPage + 1)
        }
    }
    
    /// 할 일 새로고침
    func fetchRefresh(){
        print(#fileID, #function, #line, "- ")
        self.fetchTodos(page: 1)
    }

    
    /// VM - addATodo
    /// : 할 일 추가 API 호출 + todoList에 데이터 추가
    func addATodo(todoInput : String) {
        print(" -", #fileID, #function, #line)
        TodosAPI.addApiCall(todoInput: todoInput,
                            completion: { (result : Result) in
            switch result {
            case .success(let addedTodo):
                print("success -", #fileID, #function, #line)
                
                self.todoList.append(addedTodo)
                
            case .failure(let failure):
                print("addApi Called : Failure : \(failure) ")
            }
        })
    }
    
    /// 할일 검색하기
    /// - Parameters:
    ///   - searchTerm: 검색어
    ///   - page: 페이지
    func searchTodos(searchTerm: String, page: Int = 1){
        print(#fileID, #function, #line, "- ")
        
        if searchTerm.count < 1 {
            print("검색어가 없습니다")
            return
        }
        
        if isLoading {
            print("로딩중입니다...")
            return
        }
        
        self.notifySearchDataNotFound?(false)
        
        if page == 1 {
            self.todoList = []
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            // 서비스 로직
            TodosAPI.searchTodos(searchTerm: searchTerm,
                                 page: page,
                                 completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
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

                case .failure(let failure):
                    print("failure: \(failure)")
                    TodosAPI.handleError(failure)
                    self.notifySearchDataNotFound?(true)
                    self.isLoading = false
                }
//                self.notifyRefreshEnded?()
            })
        })
    }

}
