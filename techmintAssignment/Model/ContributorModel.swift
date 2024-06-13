//
//  ContributorModel.swift
//  techmintAssignment
//
//  Created by Shaizan on 13/06/24.
//

import Foundation


struct Contributor: Codable {
    let login: String
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}


