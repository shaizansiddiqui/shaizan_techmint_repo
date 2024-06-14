//
//  ViewController.swift
//  techmintAssignment
//
//  Created by Shaizan on 13/06/24.
//

import UIKit
import CoreData

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mytableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var indicator: UIActivityIndicatorView!
    var repoData:Repository?
    var repositories = [Repository]()
    let api = GitHubAPI()
    var currentPage = 1
    var isLoading = false
    var query = ""
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        mytableView.delegate = self
        mytableView.dataSource = self
        indicator = UIActivityIndicatorView(style: .gray)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        self.view.bringSubviewToFront(indicator)
        indicator.hidesWhenStopped = true
        
        self.fetchSavedRepositories()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        self.query = query
        self.currentPage = 1
        self.repositories = []
        self.mytableView.reloadData()
        isSearching = true
        loadRepositories(query: query, page: currentPage)
    }
    
    func loadRepositories(query: String, page: Int) {
        guard !isLoading else { return }
        isLoading = true
        indicator.startAnimating()
        api.searchRepositories(query: query, page: page) { repositories in
            DispatchQueue.main.async {
                self.repositories.append(contentsOf: repositories)
                self.isLoading = false
                self.mytableView.reloadData()
                self.indicator.stopAnimating()
                self.saveItems()
            }
        }
    }
    
    func saveItems(){
        let items = Array(repositories.prefix(15))
        
        
        
        items.forEach { item in
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let table = NSEntityDescription.insertNewObject(forEntityName: "RepositoryEntity", into: context)
            table.setValue(item.fullName, forKey: "fullName")
            table.setValue(item.name, forKey: "name")
            table.setValue(item.owner.avatarUrl, forKey: "avatarUrl")
            table.setValue(item.htmlUrl, forKey: "htmlUrl")
            table.setValue(item.description, forKey: "repositoryDescription")
            table.setValue("\(item.stargazersCount)", forKey: "stargazersCount")
            
            do{
                try context.save()
            }catch{
                print("There is a problem in saving data")
            }
            
        }
        
    }
    
    func fetchSavedRepositories(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<RepositoryEntity> = RepositoryEntity.fetchRequest()
        
        do {
            let savedRepositories = try context.fetch(fetchRequest)
            repositories = savedRepositories.map { $0.toRepository() }
            mytableView.reloadData()
        } catch {
            print("Failed to fetch repositories: \(error)")
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mytableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath)
        let repo = repositories[indexPath.row]
        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = repo.htmlUrl
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        print("))))) \(repositories)")
        repoData = repository
        performSegue(withIdentifier: "showRepoDetails", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRepoDetails" {
            let detailsVC = segue.destination as! RepoDetailsViewController
            print("Repo data: \(repoData?.fullName)")
            detailsVC.repository = repoData
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = mytableView.contentSize.height
        let tableViewHeight = mytableView.frame.size.height
        
        if position > (contentHeight - 100 - tableViewHeight) {
            guard !isLoading else { return }
            currentPage += 1
            if isSearching{
                loadRepositories(query: query, page: currentPage)
            }
            
        }
    }
    
    

}


extension RepositoryEntity {
    func toRepository() -> Repository {
        let owner = Owner(avatarUrl: self.avatarUrl ?? "")
        let stars = Int(self.stargazersCount ?? "0")
        return Repository(name: self.name ?? "",
                          fullName: self.fullName ?? "",
                          description: self.description,
                          stargazersCount: stars ?? 0,
                          htmlUrl: self.htmlUrl ?? "",
                          owner: owner)
    }
}


