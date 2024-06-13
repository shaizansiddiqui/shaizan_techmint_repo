//
//  Repository.swift
//  techmintAssignment
//
//  Created by Shaizan on 13/06/24.
//

import Foundation


class GitHubAPI {
    private let baseURL = "https://api.github.com"
    
    func searchRepositories(query: String, completion: @escaping ([Repository]) -> Void) {
        let urlString = "\(baseURL)/search/repositories?q=\(query)&per_page=10"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(result.items)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getContributors(fullName: String, completion: @escaping ([Contributor]) -> Void) {
        let urlString = "\(baseURL)/repos/\(fullName)/contributors"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let contributors = try JSONDecoder().decode([Contributor].self, from: data)
                completion(contributors)
            } catch {
                print(error)
            }
        }.resume()
    }
}

