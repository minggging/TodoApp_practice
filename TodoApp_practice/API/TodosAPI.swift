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
    
    enum ApiError : Error {
        case unknownError(_ err: Error?)
        case noContent
        case decodingError
        case badStatus(code: Int)
        case unauthorized
        case notAllowedUrl
        
        var info : String {
            switch self {
            case .unknownError(let err) : return "알 수 없는 에러입니다 : \(err)"
            case .noContent : return "데이터가 없습니다"
            case .decodingError : return "디코딩 에러입니다"
            case let .badStatus(code) : return "에러 상태코드 : \(code)"
            case .unauthorized : return "인증되지 않은 사용자입니다"
            case .notAllowedUrl : return "올바른 URL 형식이 아닙니다"
            }
        }
        
    }
    
    
    /// 모든 할 일 목록 가져오기 api
    static func fetchTodos(page : Int = 1,
                           completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void)
    {
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
        .validate().responseData { response in
            debugPrint(response)
            
            // responseData의 response = 성공 여부
            print("responseData : response : \(response)")
            
        }
        .responseDecodable(of: BaseListResponse<Todo>.self) { response in
            
            debugPrint(response)
            
            print("response.result : \(response.result)")
            
            
            switch response.result {
            case .success(let response):
                completion(.success(response))
                print(" -", #fileID, #function, #line)
            case .failure(let error):
                completion(.failure(ApiError.decodingError))
                print("err : decodingError", #function, #line)
            }
            
            // responseDecodable의 response는 response.result와 같음
            // 응답 받은 모든 데이터들
        }
        
    }
    
    
    /// 할 일 추가 api
    /// - Parameters:
    ///   - todoInput: 할 일
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func addApiCall(todoInput : String,
                           isDone: Bool = false,
                           completion: @escaping (Result<BaseResponse<Todo>,ApiError>) -> Void) {
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
        .validate(statusCode: 200..<300)
        .responseDecodable(of: BaseResponse<Todo>.self) { response in
            debugPrint(response)
            
            print(" -", #fileID, #function, #line)
            print("resonseDecodable : response.result : \(response.result)")
            
            switch response.result {
            case .success(let response):
                completion(.success(response))
                print(" -", #fileID, #function, #line)
            case .failure(let error):
                completion(.failure(ApiError.decodingError))
                print(" error : \(error)-", #fileID, #function, #line)

            }
            
            
        }
    }
    
    /// 특정 할 일 가져오기 api
    static func fetchATodos(id : Int,
                            completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void)
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
        .validate(statusCode: 200..<300)
        .validate().responseData { response in
            debugPrint(response)
            
            // responseData의 response = 성공 여부
            print("responseData : response : \(response)")
            
        }
        .responseDecodable(of: BaseResponse<Todo>.self) { response in
            
            debugPrint(response)
            
            print("response.result : \(response.result)")
            
            
            switch response.result {
            case .success(let response):
                completion(.success(response))
                print(" -", #fileID, #function, #line)
            case .failure(let error):
                completion(.failure(ApiError.decodingError))
                print("err : decodingError", #function, #line)
            }
            
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
        .validate().responseData { response in
            debugPrint(response)
            
            // responseData의 response = 성공 여부
            print("responseData : response : \(response)")
            
        }
        .responseDecodable(of: BaseListResponse<Todo>.self) { response in
            
            debugPrint(response)
            
            print("response.result : \(response.result)")
            
            
            switch response.result {
            case .success(let response):
                completion(.success(response))
                print(" -", #fileID, #function, #line)
            case .failure(let error):
                completion(.failure(ApiError.decodingError))
                print("err : decodingError", #function, #line)
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
                           completion: @escaping (Result<BaseResponse<Todo>,ApiError>) -> Void) {
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
        .validate(statusCode: 200..<300)
        .responseDecodable(of: BaseResponse<Todo>.self) { response in
            debugPrint(response)
            
            print(" -", #fileID, #function, #line)
            print("resonseDecodable : response.result : \(response.result)")
            
            switch response.result {
            case .success(let response):
                completion(.success(response))
                print(" -", #fileID, #function, #line)
            case .failure(let error):
                completion(.failure(ApiError.decodingError))
                print(" error : \(error)-", #fileID, #function, #line)

            }
            
            
        }
    }
    
    
    /// 특정 할 일 삭제하기 api
    static func deleteATodos(id : Int,
                            completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void)
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
        .validate(statusCode: 200..<300)
        .validate().responseData { response in
            debugPrint(response)
            
            // responseData의 response = 성공 여부
            print("responseData : response : \(response)")
            
        }
        .responseDecodable(of: BaseResponse<Todo>.self) { response in
            
            debugPrint(response)
            
            print("response.result : \(response.result)")
            
            
            switch response.result {
            case .success(let response):
                completion(.success(response))
                print(" -", #fileID, #function, #line)
            case .failure(let error):
                completion(.failure(ApiError.decodingError))
                print("err : decodingError", #function, #line)
            }
            
        }
        
    }

    
    

}
