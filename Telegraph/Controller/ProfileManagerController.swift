import UIKit

/// `present` function extension.
extension UIViewController {
    /// Presents new `ViewController` with given parameters.
    /// - parameter withIdentifier: Storyboard ViewController id
    /// - parameter transition: presetation transition
    /// - parameter presentation: presetation type
    /// - parameter animated: if transition is animated
    func present(withIdentifier: String, transition: UIModalTransitionStyle = .coverVertical,
                 presentation: UIModalPresentationStyle = .fullScreen, animated: Bool) {
        let presented = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: withIdentifier)
        presented.modalPresentationStyle = presentation
        presented.modalTransitionStyle = transition
        present(presented, animated: animated)
    }
}

/// Profile manager controller. Contains table with all loaded
/// profiles and buttons for switching to other controllers.
class ProfileManagerController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    /// Table with all appliaction profiels
    @IBOutlet weak var profileTableView: UITableView!
    /// Search tool for profile filtering
    @IBOutlet weak var searchBar: UISearchBar!
    /// Loading indicator for all Telegraph API interactions
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    /// New profile button
    @IBOutlet weak var addButton: UIButton!

    /// Switches controller to `Login Controller`
    /// - parameter sender: add button.
    @IBAction func addButtonPressed(_ sender: UIButton) {
        present(withIdentifier: "LoginControllerID", animated: false)
    }

    /// Called after the controller's view is loaded into memory.
    /// Set-ups profile table and all buttons.
    override func viewDidLoad() {
        super.viewDidLoad()

        profileTableView.delegate = self
        profileTableView.dataSource = self

        let size = min(min(view.frame.width, view.frame.height) / 4.0, 75)
        addButton.frame = CGRect(x: view.frame.width - size - 15, y: view.frame.height - size - 25, width: size, height: size)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    /// Notifies the view controller that its view was added to a view hierarchy.
    /// Reloades table data.
    /// - parameter animated: if transition was animated.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        profileTableView.reloadData()
    }

    /// Disables keyboard after tap action.
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }

    /// Table view number of rows function.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileManager.shared.count
    }

    /// Table view cell by row function.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileManagerCellID", for: indexPath) as? ProfileManagerCell else {
            return UITableViewCell()
        }

        cell.setCell(by: indexPath.row)
        cell.pressAction = { [unowned self] in
            guard let infoVC = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "ProfileInfoControllerID") as? ProfileInfoController else {
                return
            }
            if UIDevice.current.userInterfaceIdiom != .pad {
                infoVC.modalPresentationStyle = .popover
            }
            infoVC.modalTransitionStyle = .coverVertical
            infoVC.profileId = indexPath.row
            self.present(infoVC, animated: true)
        }
        cell.tapAction = { [unowned self] in
            self.present(withIdentifier: "PageManagerControllerID", animated: true)
        }
        return cell
    }
}
