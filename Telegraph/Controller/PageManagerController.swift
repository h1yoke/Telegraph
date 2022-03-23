import UIKit

/// Present alert controller function extension
extension UIViewController {
    /// Presents alert with given parameters.
    @discardableResult
    func presentAlert(title: String, message: String, actions: [UIAlertAction],
                      animated: Bool, textFields: [(UITextField) -> Void] = [], presenting: Bool = true) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        textFields.forEach { alert.addTextField(configurationHandler: $0) }
        actions.forEach { alert.addAction($0) }
        if presenting { present(alert, animated: animated) }
        return alert
    }
}

/// Page manager controller. Contains table with all account pages and buttons.
class PageManagerController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    /// Page table
    @IBOutlet weak var pageTableView: UITableView!
    /// Page search filter
    @IBOutlet weak var searchBar: UISearchBar!
    /// Loading indicator for Telegraph API interactions
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    /// New page button
    @IBOutlet weak var addButton: UIButton!

    /// Account pages
    var pages = [Telegraph.Page]()
    /// Refresh pages controller
    let refreshControl = UIRefreshControl()

    /// Dismisses page manager controller.
    /// - parameter sender: back button
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    /// Creates a new page.
    /// - parameter sender: add button
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let alert = presentAlert(
            title: "New Page",
            message: "",
            actions: [
                UIAlertAction(title: "Cancel", style: .cancel) { (_: UIAlertAction) in return }
            ],
            animated: true,
            textFields: [ { $0.placeholder = "Title" }
            ],
            presenting: false
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_: UIAlertAction) in
            self.createPage(alert.textFields?[0])
        })
        present(alert, animated: true)
    }

    /// Refreshes pages.
    /// - parameter sender: refresh controller
    @objc func refresh(_ sender: AnyObject) {
        /// TODO: Refreshing
    }

    /// Called after the controller's view is loaded into memory.
    /// Set-ups page table and buttons.
    override func viewDidLoad() {
        super.viewDidLoad()

        pageTableView.delegate = self
        pageTableView.dataSource = self

        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        pageTableView.addSubview(refreshControl)

        let size = min(min(view.frame.width, view.frame.height) / 4.0, 75)
        addButton.frame = CGRect(x: view.frame.width - size - 15, y: view.frame.height - size - 25, width: size, height: size)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    /// Notifies the view controller that its view was added to a view hierarchy.
    /// Checks if account is valid to load pages.
    /// - parameter animated: if transition was animated.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let token = AccountManager.shared.current?.accessToken else {
            presentAlert(
                title: "Warning",
                message: "Account info corrupted. No access token found.",
                actions: [
                    UIAlertAction(title: "OK", style: .default) { (_: UIAlertAction) in self.dismiss(animated: true) }],
                animated: true
            )
            return
        }

        loadingIndicator.isHidden = false
        try? Telegraph.query(
            method: Telegraph.Method.getPageList(accessToken: token),
            completion: parseQuery
        )
    }

    /// Disables keyboard after tap action.
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }

    /// Table view number of rows function.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }

    /// Table view cell by row function.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PageManagerCellID", for: indexPath) as? PageManagerCell else {
            return UITableViewCell()
        }

        cell.setCell(by: pages[indexPath.row])
        cell.tapAction = {
            if let presented = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "EditorControllerID") as? EditorController {
                presented.page = self.pages[indexPath.row]
                presented.token = AccountManager.shared.current?.accessToken
                presented.readonly = false
                presented.modalPresentationStyle = .fullScreen
                self.present(presented, animated: true)
            }
        }
        /// TODO: Loading portion of pages if quantity exceeds 50.
        return cell
    }

    /// Parses Telegraph API response.
    /// - parameter response: PageList if success
    func parseQuery(response: Telegraph.Response<Telegraph.PageList>) {
        if response.ok, let result = response.result {
            self.pages = result.pages
            self.loadingIndicator.isHidden = true
            self.pageTableView.reloadData()
        } else if let error = response.error {
        }
    }

    /// Creates a new page.
    /// - parameter textField: user entered text field.
    func createPage(_ textField: UITextField?) {
        guard let account = AccountManager.shared.current,
              let token = account.accessToken,
              let title = textField?.text else {
            return
        }

        let node = Telegraph.Node(textNode: "Untitled", object: nil)
        let method = Telegraph.Method.createPage(accessToken: token, title: title, authorName: account.authorName,
            authorUrl: account.authorUrl, content: [node], returnContent: true)

        try? Telegraph.query(method: method, completion: { (response: Telegraph.Response<Telegraph.Page>) in
            if response.ok, let page = response.result {
                self.pages.append(page)
                self.pageTableView.reloadData()

                let presented = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "EditorControllerID") as? EditorController
                presented?.page = page
                presented?.token = AccountManager.shared.current?.accessToken
                presented?.readonly = false
                presented?.modalPresentationStyle = .fullScreen
                self.present(presented!, animated: true)
            } else {
            }
        })
    }
}
