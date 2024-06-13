//
//  ViewController.swift
//  techmintAssignment
//
//  Created by Shaizan on 13/06/24.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var repositories = [Repository]()
    let api = GitHubAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        api.searchRepositories(query: query) { repositories in
            DispatchQueue.main.async {
                self.repositories = repositories
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath)
        cell.textLabel?.text = repositories[indexPath.row].name
        cell.detailTextLabel?.text = repositories[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        performSegue(withIdentifier: "showRepoDetails", sender: repository)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRepoDetails" {
            let detailsVC = segue.destination as! RepoDetailsViewController
            detailsVC.repository = sender as? Repository
        }
    }

}

