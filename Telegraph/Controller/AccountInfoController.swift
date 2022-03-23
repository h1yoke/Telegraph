import UIKit
import PhotosUI
import SwiftUI

/// Account info controller. Holds all aditional info about account.
class AccountInfoController: UIViewController, PHPickerViewControllerDelegate {
    /// Account profile button with image
    @IBOutlet weak var accountImage: UIImageView!
    /// Account short name field
    @IBOutlet weak var shortNameField: UITextField!
    /// Account author name field
    @IBOutlet weak var authorNameField: UITextField!
    /// Account url field
    @IBOutlet weak var authorUrlField: UITextField!
    /// Account token field
    @IBOutlet weak var tokenField: UITextField!
    /// Controller bar title
    @IBOutlet weak var barTitle: UINavigationItem!
    /// Image picker controller
    var imagePicker: PHPickerViewController = {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        return PHPickerViewController(configuration: config)
    }()

    /// Selected account id in `AccountManager.shared`
    var accountId: Int!
    /// Edit flag
    var isEditMode = false

    /// Start image-picker for account profile image.
    /// - parameter sender: image button
    @objc func accountButtonPressed(_ gesture: UITapGestureRecognizer) {
        self.present(imagePicker, animated: true, completion: nil)
    }

    /// Revokes account acess token.
    /// - parameter sender: update button
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Warning",
            message: "You are about to revoke access token. " +
                "This action will untie all logined devices except this. Continue?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Revoke", style: .destructive, handler: { _ in
            guard let token = AccountManager.shared.get(by: self.accountId)?.accessToken else { return }
            let method = Telegraph.Method.revokeAccessToken(accessToken: token)
            try? Telegraph.query(method: method, completion: { (response: Telegraph.Response<Telegraph.Account>) in
                if let result = response.result {
                    AccountManager.shared.edit(by: self.accountId, newAccount: result)
                }
            })
        }))
        present(alert, animated: true)
    }

    /// Copies account token to clipboard.
    /// - parameter sender: copy button
    @IBAction func copyButtonPressed(_ sender: UIButton) {
        if let token = AccountManager.shared.get(by: accountId)?.accessToken {
            UIPasteboard.general.string = token
        }
    }

    /// Enables or disables edit mode.
    /// - parameter sender: edit button
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if !isEditMode {
            sender.title = "Done"
            isEditMode = true
            enable()
        } else {
            sender.title = "Edit"
            isEditMode = false
            disable()
        }
    }

    /// Deletes account.
    /// - parameter sender: delete button
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        AccountManager.shared.delete(by: accountId)

        if let accountManagerVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "AccountManagerControllerID") as? AccountManagerController {
            accountManagerVC.modalPresentationStyle = .fullScreen
            present(accountManagerVC, animated: false) {
                accountManagerVC.accountTableView?.reloadData()
            }
        }
    }

    /// Enables all editable fields.
    func enable() {
        shortNameField.isEnabled = true
        authorNameField.isEnabled = true
        authorUrlField.isEnabled = true
    }

    /// Disables all editable fields.
    func disable() {
        shortNameField.isEnabled = false
        authorNameField.isEnabled = false
        authorUrlField.isEnabled = false
        tokenField.isEnabled = false
    }

    /// Initializes controller.
    /// - parameter account: telegraph account
    func commonInit(account: Telegraph.Account) {
        imagePicker.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(accountButtonPressed(_:)))
        accountImage.addGestureRecognizer(tap)
        accountImage.isUserInteractionEnabled = true

        barTitle.title = account.shortName ?? "Account" + " Info"
        shortNameField.changeAttributedText(string: account.shortName ?? "")
        authorNameField.changeAttributedText(string: account.authorName ?? "")
        authorUrlField.changeAttributedText(string: account.authorUrl ?? "")
        tokenField.changeAttributedText(string: account.accessToken ?? "")
        disable()
    }

    /// Called after the controller's view is loaded into memory.
    /// Set-ups all text fields by given account.
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let account = AccountManager.shared.get(by: accountId) else { return }
        commonInit(account: account)
    }

    ///
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, _) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.accountImage.image = image
                    }
                }
            })
        }
    }
}
