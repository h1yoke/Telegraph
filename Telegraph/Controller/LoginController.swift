import UIKit

/// Edit `Text Field` attributed text function extension.
extension UITextField {
    /// Changes attributed text to a new one.
    /// - parameter string: new text.
    func changeAttributedText(string: String) {
        if let newAttributedText = self.attributedText {
            let mutableAttributedText = newAttributedText.mutableCopy() as? NSMutableAttributedString
            mutableAttributedText?.mutableString.setString(string)
            if let mutableAttributedText = mutableAttributedText {
                self.attributedText = mutableAttributedText as NSAttributedString
            }
        }
    }
}

/// Login controller. Creates a new account with given parameters.
class LoginController: UIViewController {
    /// Account short name
    @IBOutlet weak var shortNameField: UITextField!
    /// Account author name
    @IBOutlet weak var authorNameField: UITextField!
    /// Account url
    @IBOutlet weak var authorUrlField: UITextField!
    /// Loading indicator for Telegraph API interaction
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    /// Called after the controller's view is loaded into memory.
    /// Set-ups tap gesture.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:))))
    }

    /// Creates a new Telegraph account.
    /// - parameter sender: confirm button
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        if shortNameField.hasText {
            loadingIndicator.isHidden = false

            try? Telegraph.query(method:
                Telegraph.Method.createAccount(
                    shortName: shortNameField.attributedText!.string,
                    authorName: authorNameField.attributedText?.string,
                    authorUrl: authorUrlField.attributedText?.string)) { (response: Telegraph.Response<Telegraph.Account>) in
                DispatchQueue.main.async {
                    self.parseResponse(response)
                    self.loadingIndicator.isHidden = true
                }
            }
        }
    }

    /// Dissmisses login controller.
    /// - parameter sender: cancel button
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: false)
    }

    /// Parses Telegraph API response
    /// - parameter response: account if success, failure otherwise
    func parseResponse(_ response: Telegraph.Response<Telegraph.Account>) {
        Telegraph.unwrapResponse(response) { (account: Telegraph.Account) in
                var acc = account
                if acc.pageCount == nil {
                    acc.pageCount = 0
                }
                AccountManager.shared.add(account: acc)
                // print(acc.authUrl)
                self.dismiss(animated: true)
        } failure: { (error: String) in
                clearFields()

                let alert = UIAlertController(title: "Account was not created", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
        }
    }

    /// Disables all keyboards for tap action.
    /// - parameter sender: tap gesture
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        authorUrlField.resignFirstResponder()
        shortNameField.resignFirstResponder()
        authorNameField.resignFirstResponder()
    }

    /// Clears all text fields.
    func clearFields() {
        shortNameField.changeAttributedText(string: "")
        authorNameField.changeAttributedText(string: "")
        authorUrlField.changeAttributedText(string: "")
    }
}
