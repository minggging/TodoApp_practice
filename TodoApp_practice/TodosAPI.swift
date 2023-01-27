//
//  TodosAPI.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/27.
//

import Foundation
import Alamofire

enum TodosAPI {
    
    // 모든 할 일 목록 가져오기 api 호출
    static func fetchTodos(page : Int = 1,
                           orderby : String = "desc",
                           perpage : Int = 10
    ) {
                print(" -", #fileID, #function, #line)
        
        let parameters = ["page": "\(page)",
                          "orderby": "\(orderby)",
                          "perpage" : "\(perpage)"]

        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]

        AF.request("https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos?page=1&order_by=desc&per_page=10",
                   parameters: parameters,
                   encoder: URLEncodedFormParameterEncoder.default,
                   headers: headers)
        .validate().responseData { response in
            debugPrint(response)
        }
        .responseDecodable(of: TodosResponse.self) { response in
            debugPrint(response)
            
        }


        
        
        
    }
    
    
    /// 할 일 목록 추가 api 호출
    /// - Parameter todoInput: 추가할 할 일
    static func addApiCall(todoInput : String) {
                print(" -", #fileID, #function, #line)
        
        let parameters: [String: String] = [
            "title": todoInput,
            "is_done": "false"
        ]
        
        let headers: HTTPHeaders = [
            "AContent-Type": "multipart/form-data",
            "Accept": "application/json"
        ]


        AF.request("https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos",
                   method: .post,
                   parameters: parameters,
                    headers: headers)
        .responseDecodable(of: AddTodos.self) { response in
            debugPrint(response)
            
        }
    }

}
