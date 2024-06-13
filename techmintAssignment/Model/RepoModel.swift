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
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
        case description
        case stargazersCount = "stargazers_count"
        case htmlUrl = "html_url"
        case owner
    }
}
struct Owner: Codable {
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
    }
}

struct SearchResult: Codable {
    let items: [Repository]
}
