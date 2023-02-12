//
//  TodosAPI+Closure.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/02/11.
//

import Foundation
import UIKit
import Alamofire

extension TodosAPI {
    
    /// 모든 할 일 목록 가져오기 api
    static func fetchTodos(page : Int = 1,
                           completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void){
        print(" -", #fileID, #function, #line)
        
        var urlComponents = URLComponents(string: baseURL + "/todos?" )!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = urlComponents.url else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        
        let parameters = ["page": "\(page)"]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   encoder: URLEncodedFormParameterEncoder.default,
                   headers: headers)
        .responseDecodable(of: BaseListResponse<Todo>.self) { response in
            debugPrint(response)
            let statusCode = response.response?.statusCode ?? 0
            print("statusCode : \(statusCode) - #fileID, #function, #line")
            
            switch response.result {
            case .success(let baseListResponse):
                if baseListResponse.data == nil {
                    completion(.failure(.noContent))
                } else {
                    completion(.success(baseListResponse))
                }
            case .failure(let err):
                completion(.failure(.unknownError(err)))
                handleError(err)
                
            }
                        
        }
        
    }
    
    
    /// 할 일 추가 api
    /// - Parameters:
    ///   - todoInput: 할 일
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func addApiCall(todoInput : String,
                           isDone: Bool = false,
                           completion: @escaping (Result<Todo,ApiError>) -> Void) {
        print(" -", #fileID, #function, #line)
        
        var urlComponents = URLComponents(string: baseURL + "/todos-json" )!
        
        guard let url = urlComponents.url else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        let parameters: [String: String] = [
            "title": todoInput,
            "is_done" : "\(isDone)"
        ]

        let headers: HTTPHeaders = [
            "AContent-Type": "application/json",
            "Accept": "application/json"
        ]
         
        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.prettyPrinted,
                   headers: headers)
        //        .validate(statusCode: 200..<300)
        .responseDecodable(of: BaseResponse<Todo>.self) { response in
            debugPrint(response)
            
            print(" -", #fileID, #function, #line)
            
            let statusCode = response.response?.statusCode ?? 0
            print("statusCode : \(statusCode) - #fileID, #function, #line")
            
            switch response.result {
                
            case .success(let baseResponse):
                
                if let addedData = baseResponse.data {
                    completion(.success(addedData))
                    print("addedData : \(addedData)")
                } else {
                    completion(.failure(.noContent))
                }
            case .failure(let err):
                handleError(err)
                completion(.failure(.unknownError(err))
                           
                           
                )}
            
        }
    }
    
    /// 특정 할 일 가져오기 api
    static func fetchATodo(id : Int,
                           completion: @escaping (Result<Todo, ApiError>) -> Void)
    {
        print(" -", #fileID, #function, #line)
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        let parameters = ["id": "\(id)"]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        
        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   encoder: URLEncodedFormParameterEncoder.default,
                   headers: headers)
        //        .validate(statusCode: 200..<300)
        .validate().responseData { response in
            debugPrint(response)
            
            // responseData의 response = 성공 여부
            print("responseData : response : \(response)")
            
        }
        .responseDecodable(of: BaseResponse<Todo>.self) { response in
            
            debugPrint(response)
            
            print(" -", #fileID, #function, #line)
            
            
            let statusCode = response.response?.statusCode ?? 0
            print("statusCode : \(statusCode) - #fileID, #function, #line")
            
            //MARK: - 에러처리
            switch response.result {
                
            case .success(let baseResponse):
                if let fetchaData = baseResponse.data {
                    completion(.success(fetchaData))
                    print("fetchaData : \(fetchaData)")
                } else {
                    completion(.failure(.noContent))
                }
                
            case .failure(let err):
                handleError(err)
                completion(.failure(.unknownError(err))
                           
                           
                )}
            
        }
        
    }
    
    
    /// 할 일 검색하기 api
    static func searchTodos(searchTerm : String,
                            page : Int = 1,
                            completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void)
    {
        print(" -", #fileID, #function, #line)
        
        let urlString = baseURL + "/todos?" + "page=\(page)"
        
        var urlComponents = URL(baseUrl: baseURL + "/todos" + "/search?" ,
                                queryItems: ["query" : searchTerm,
                                             "page" :"\(page)"])
        
        guard let url = urlComponents else { return completion(.failure(ApiError.notAllowedUrl))}
        
        let parameters = ["query" : searchTerm,
                          "page": "\(page)"
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   encoder: URLEncodedFormParameterEncoder.default,
                   headers: headers)
        .responseDecodable(of: BaseListResponse<Todo>.self) { response in
            
            debugPrint(response)
            
            let statusCode = response.response?.statusCode ?? 0
            print("statusCode : \(statusCode) -", #fileID, #function, #line)
            
            switch statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(ApiError.noContent))
                
            default: print("default")
            }
            
            switch response.result {
            case .success(let searchDataResponse):
                if searchDataResponse.data == nil {
                    completion(.failure(.noContent))
                } else {
                    completion(.success(searchDataResponse))
                }
            case .failure(let err):
                handleError(err)
                completion(.failure(.unknownError(err)))
                
            }
            
        }
        
    }
    
    
    
    
    /// 할 일 수정하기 - JSON
    /// - Parameters:
    ///   - id: 수정할 id
    ///   - todoInput: 수정할 할 일
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editApiCall(id: Int,
                            todoInput : String,
                            isDone: Bool = false,
                            completion: @escaping (Result<Todo,ApiError>) -> Void) {
        print(" -", #fileID, #function, #line)
        
        var urlComponents = URLComponents(string: baseURL + "/todos-json" + "/\(id)" )!
        
        guard let url = urlComponents.url else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        let parameters: [String: String] = [
            "id" : "\(id)",
            "title": todoInput,
            "is_done" : "\(isDone)"
        ]
        
        let headers: HTTPHeaders = [
            "AContent-Type": "application/json",
            "Accept": "application/json"
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default,
                   headers: headers)
        //        .validate(statusCode: 200..<300)
        .responseDecodable(of: BaseResponse<Todo>.self) { response in
            debugPrint(response)
            
            print(" -", #fileID, #function, #line)
            
            let statusCode = response.response?.statusCode ?? 0
            print("statusCode : \(statusCode) - #fileID, #function, #line")
            
            switch response.result {
                
            case .success(let baseResponse):
                
                if let editData = baseResponse.data {
                    completion(.success(editData))
                    print("editData : \(editData)")
                } else {
                    completion(.failure(.noContent))
                }
                
            case .failure(let err):
                handleError(err)
                completion(.failure(.unknownError(err))
                           
                           
                )}
            
            
        }
    }
    
    
    /// 특정 할 일 삭제하기 api
    static func deleteATodos(id : Int,
                             completion: @escaping (Result<Todo, ApiError>) -> Void)
    {
        print(" -", #fileID, #function, #line)
        
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        let parameters = ["id": "\(id)"]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        
        AF.request(url,
                   method: .delete,
                   parameters: parameters,
                   encoder: URLEncodedFormParameterEncoder.default,
                   headers: headers)
        //        .validate(statusCode: 200..<300)
        .validate().responseData { response in
            debugPrint(response)
            
            // responseData의 response = 성공 여부
            print("responseData : response : \(response)")
            
        }
        .responseDecodable(of: BaseResponse<Todo>.self) { response in
            
            debugPrint(response)
            
            let statusCode = response.response?.statusCode ?? 0
            print("statusCode : \(statusCode) - #fileID, #function, #line")
            
            switch response.result {
                
            case .success(let baseResponse):
                if let deleteData = baseResponse.data {
                    completion(.success(deleteData))
                    print("deleteData : \(deleteData)")
                } else {
                    completion(.failure(.noContent))
                }
                
            case .failure(let err):
                handleError(err)
                completion(.failure(.unknownError(err))
                           
                )}
            
        }
        
    }
    
    
    
    /// 할 일 추가 후, 모든 할 일 가져오기
    static func addATodoAndFetchTodos(todoInput : String,
                                      isDone: Bool = false,
                                      completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void){
        
        self.addApiCall(todoInput: todoInput, completion: { result in
            switch result {
            case .success(_):
                
                self.fetchTodos(completion: {
                    switch $0 {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                })
                
            case .failure(let failure):
                completion(.failure(failure))
            }
        })
    }
    
    /// 클로저 기반 api 동시 처리 ( DispatchGroup을 활용)
    /// 선택된 할 일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일들 ID
    ///   - completion: 삭제 완료된 할 일 ID
    static func deleteSelectedTodos(selectedTodoIds : [Int],
                                    completion : @escaping ([Int]) -> Void) {
        
        let group = DispatchGroup()
        
        /// 성공적으로 삭제된 할 일들
        var deletedTodoIds : [Int] = []
        
        selectedTodoIds.forEach { aTodoId in
            
            // 디스패치 그룹에 넣음
            group.enter()
            
            self.deleteATodos(id: aTodoId,
                              completion: { result in
                switch result {
                case .success(let response):
                    
                    if let todoId = response.id {
                        deletedTodoIds.append(todoId)
                        print("success : delete Todo Id : \(aTodoId) -", #fileID, #function, #line)

                    }
                case .failure(let failure):
                    print("inner delete failure : \(failure) -", #fileID, #function, #line)
                }
                // 그룹에서 나감
                group.leave()
                
            }) // 단일 삭제 API 호출
        }
        
        group.notify(queue: .main) {
            print("Delete And Seleted API 완료 -", #fileID, #function, #line)
            completion(deletedTodoIds)

        }
    }
    
    
    /// 클로저 기반 api 동시 처리 ( DispatchGroup을 활용)
    /// 선택된 할 일들 가져하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일들 ID
    ///   - completion: 응답 결과
    static func fetchSelectedTodos(selectedTodoIds : [Int],
                                   completion : @escaping (Result<([Todo]), ApiError>) -> Void) {
        
        let group = DispatchGroup()
        
        /// 가져 온 할 일들
        var fetchTodos : [Todo] = []
        
        /// 에러들
        var apiError : [ApiError] = []
        
        /// 응답 결과들
        var apiResults = [Int : Result<BaseResponse<Todo>,ApiError>]()
        
        selectedTodoIds.forEach { aTodoId in
            
            // 디스패치 그룹에 넣음
            group.enter()
            
            self.fetchATodo(id: aTodoId,
                            completion: { result in
                switch result {
                case .success(let response):
                    fetchTodos.append(response)
                    print("success : fetch Todo Id : \(response) -", #fileID, #function, #line)

                case .failure(let failure):
                    apiError.append(failure)
                    completion(.failure(failure))
                    print("fetchSelected api called failure : \(failure) -", #fileID, #function, #line)
                }
                // 그룹에서 나감
                group.leave()
                
            }) // 단일 삭제 API 호출
        }
        
        group.notify(queue: .main) {
            print("Fetch And Seleted API 완료 -", #fileID, #function, #line)

            if !apiError.isEmpty {
                if let firstError = apiError.first {
                    completion(.failure(firstError))
                    return
                }
            }
            completion(.success(fetchTodos))

        }
    }

}
