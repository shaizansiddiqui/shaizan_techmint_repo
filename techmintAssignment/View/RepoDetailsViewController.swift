import UIKit

class RepoDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var projectLinkButton: UIButton!
    @IBOutlet weak var contributorsTableView: UITableView!
    
    var repository: Repository?
    var contributors = [Contributor]()
    let api = GitHubAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contributorsTableView.delegate = self
        contributorsTableView.dataSource = self
        if let repository = repository {
            nameLabel.text = repository.name
            descriptionLabel.text = repository.description
            starsLabel.text = "Stars: \(repository.stargazersCount)"
            projectLinkButton.setTitle(repository.htmlUrl, for: .normal)
            if let url = URL(string: repository.owner.avatarUrl) {
                imageView.load(url: url)
            }
            api.getContributors(fullName: repository.fullName) { contributors in
                DispatchQueue.main.async {
                    self.contributors = contributors
                    self.contributorsTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func openProjectLink(_ sender: UIButton) {
        if let url = URL(string: sender.title(for: .normal) ?? "") {
            let webViewController = WebViewController()
            webViewController.url = url
            navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contributors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContributorCell", for: indexPath)
        cell.textLabel?.text = contributors[indexPath.row].login
        return cell
    }
}
