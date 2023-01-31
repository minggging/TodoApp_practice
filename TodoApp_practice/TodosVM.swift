//
//  todosVM.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/27.
//

import Foundation
import Combine

class TodosVM : ObservableObject {
    
    init(){
        print(" -", #fileID, #function, #line)
        TodosAPI.fetchTodos { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let todosResponse):
                print("TodosVM - todosResponse : \(todosResponse)")
            case .failure(let failure):
                print("TodosVM - failure : \(failure)")
                self.handleError(failure)
            }
        }
    }// init.
    
    /// API 에러처리
    /// - Parameter err: API 에러
    fileprivate func handleError(_ err: Error) {
        
        if err is TodosAPI.ApiError {
            
            let apiError = err as! TodosAPI.ApiError
            
            print("handleError : err : \(apiError.info)", #function, #line)
            
            switch apiError {
            case .unknownError(let err) : print ("알 수 없는 에러입니다 : \(err)")
            case .noContent : print("데이터가 없습니다")
            case .decodingError : print("디코딩 에러입니다")
            case let .badStatus(code) : print("에러 상태코드 : \(code)")
            case .unauthorized : print("인증되지 않은 사용자입니다")
            }
        }
        
    }
    
    
}
