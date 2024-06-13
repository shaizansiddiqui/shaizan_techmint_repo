//
//  RepoModel.swift
//  techmintAssignment
//
//  Created by Shaizan on 13/06/24.
//

import Foundation

struct Repository: Codable {
    let name: String
    let fullName: String
    let description: String?
    let stargazersCount: Int
    let htmlUrl: String
    let owner: Owner
}
struct Owner: Codable {
    let avatarUrl: String
}

struct SearchResult: Codable {
    let items: [Repository]
}
