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
    
    
}
