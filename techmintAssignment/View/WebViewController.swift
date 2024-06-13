import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var url: URL?
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            webView.load(URLRequest(url: url))
        }
    }
}
