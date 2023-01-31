//
//  TodosAPI.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/27.
//

import Foundation
import Alamofire

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
        
        var info : String {
            switch self {
            case .unknownError(let err) : return "알 수 없는 에러입니다 : \(err)"
            case .noContent : return "데이터가 없습니다"
            case .decodingError : return "디코딩 에러입니다"
            case let .badStatus(code) : return "에러 상태코드 : \(code)"
            case .unauthorized : return "인증되지 않은 사용자입니다"
            }
        }
        
    }
    
    
    /// 모든 할 일 목록 가져오기 api
    /// - Parameters:
    ///   - page: page
    ///   - orderby: desc
    ///   - perpage: 한 페이지에 할 일
    static func fetchTodos(page : Int = 1,
                           orderby : String = "desc",
                           perpage : Int = 10,
                           completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void)
    {
        print(" -", #fileID, #function, #line)
        
        let urlString = baseURL + "/todos?" + "page=\(page)"
        
        let parameters = ["page": "\(page)",
                          "orderby": "\(orderby)",
                          "perpage" : "\(perpage)"]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        AF.request(urlString,
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
    
    
    /// 할 일 목록 추가 api 호출
    /// - Parameter todoInput: 추가할 할 일
    static func addApiCall(todoInput : String,
                           completion: @escaping (Result<Any,ApiError>) -> Void) {
        print(" -", #fileID, #function, #line)
        let urlString = baseURL + "/todos"
        
        
        let parameters: [String: String] = [
            "title": todoInput,
            "is_done": "false"
        ]
        
        let headers: HTTPHeaders = [
            "AContent-Type": "multipart/form-data",
            "Accept": "application/json"
        ]
        
        
        AF.request(urlString,
                   method: .post,
                   parameters: parameters,
                   headers: headers)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: AddTodos.self) { response in
            debugPrint(response)
            
            print(" -", #fileID, #function, #line)
            print("resonseDecodable : response.result : \(response.result)")
            
            switch response.result {
            case .success(let response):
                completion(.success(response))
                print(" -", #fileID, #function, #line)
            case .failure(let error):
                completion(.failure(ApiError.noContent))
                    print(" error : \(error)-", #fileID, #function, #line)
            }

            
        }
    }
    
}
