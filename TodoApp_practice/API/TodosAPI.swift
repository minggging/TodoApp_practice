//
//  TodosAPI.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/27.
//

import Foundation
import Alamofire
import MultipartForm

enum TodosAPI {
    static let version = "v1"
    
#if DEBUG // 디버그
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/" + version
#else // 릴리즈
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/" + version
#endif
    
    
    
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
}
