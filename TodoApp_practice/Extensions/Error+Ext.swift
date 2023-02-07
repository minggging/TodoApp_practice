//
//  Error+Ext.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/02/04.
//

import Foundation
import UIKit

extension TodosAPI {
    
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
    
    
    /// API 에러처리
    /// - Parameter err: API 에러
    static func handleError(_ err: Error) {
        
        if err is TodosAPI.ApiError {
            
            let apiError = err as! TodosAPI.ApiError
            
            print("handleError : err : \(apiError.info)", #function, #line)
            
            switch apiError {
            case .unknownError(let err) : print ("알 수 없는 에러입니다 : \(err)")
            case .noContent : print("데이터가 없습니다")
            case .decodingError : print("디코딩 에러입니다")
            case let .badStatus(code) : print("에러 상태코드 : \(code)")
            case .unauthorized : print("인증되지 않은 사용자입니다")
            case .notAllowedUrl: print("올바른 URL 형식이 아닙니다")
                
            }
        }
    }
}
