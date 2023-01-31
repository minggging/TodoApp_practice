//
//  ApiCodable.swift
//  TodoApp_practice
//
//  Created by 정민경 on 2023/01/26.
//

import Foundation

// MARK: - TodosResponse
struct BaseListResponse<T:Codable>: Codable {
    let data: [T]?
    let meta: Meta?
    let message: String?
}


// MARK: - TodosResponse
struct TodosResponse: Codable {
    let data: [Todo]?
    let meta: Meta?
    let message: String?
}

// MARK: - Todo
struct Todo: Codable {
    let id: Int?
    let title: String?
    let isDone: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Meta
struct Meta: Codable {
    let currentPage, from, lastPage, perPage: Int?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }
}

// MARK: - AddTodos
struct AddTodos: Codable {
    let title: String?
    let isDone: Bool?

    enum CodingKeys: String, CodingKey {
        case title
        case isDone = "is_done"
    }
}

