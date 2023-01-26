//
//  ApiCodable.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/26.
//

import Foundation

// MARK: - AddTodos
struct AddTodos: Codable {
    let title: String?
    let isDone: Bool?

    enum CodingKeys: String, CodingKey {
        case title
        case isDone = "is_done"
    }
}

