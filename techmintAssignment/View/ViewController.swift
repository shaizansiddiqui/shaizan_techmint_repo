//
//  ViewController.swift
//  techmintAssignment
//
//  Created by Shaizan on 13/06/24.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    
    
    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.image = UIImage(named: "appbackground")
        return imgView
    }()
    
    @IBOutlet weak var mytableView: UITableView!
    var searchController: UISearchController!

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
        print("Start.........")
        let searchResultsController = UITableViewController(style: .plain)
        searchController = UISearchController(searchResultsController: searchResultsController)
        
            // Set the search controller's search results updater
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self

            // Add the search bar to the table view's header
        mytableView.tableHeaderView = searchController.searchBar
        mytableView.delegate = self
        mytableView.dataSource = self
        indicator = UIActivityIndicatorView(style: .large)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        self.view.bringSubviewToFront(indicator)
            // Add imageView to the view hierarchy
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
            // Set up constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        indicator.hidesWhenStopped = true
        
        self.fetchSavedRepositories()
    }
    
    
    func loadRepositories(query: String, page: Int) {
        guard !isLoading else { return }
        isLoading = true
        DispatchQueue.main.async { [self] in
            indicator.startAnimating()
        }
        api.searchRepositories(query: query, page: page) { repositories in
            DispatchQueue.main.async {
                self.repositories.append(contentsOf: repositories)
                self.isLoading = false
                self.mytableView.reloadData()
                self.indicator.stopAnimating()
                self.deleteAllRepositories()
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
    
    func deleteAllRepositories() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RepositoryEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete repositories: \(error)")
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
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }

}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            // Trigger search logic when the Enter key is pressed
        if let searchText = searchBar.text, !searchText.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                
                print("text: \(searchText)")
                self.query = searchText
                self.currentPage = 1
                self.repositories = []
                isSearching = true
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


