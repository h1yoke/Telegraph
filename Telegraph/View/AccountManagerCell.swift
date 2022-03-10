import UIKit

/// Cell view in Account Manager  table.
class AccountManagerCell: UITableViewCell {
    /// Left label in cell
    @IBOutlet weak var accountDetails: UILabel!
    /// Right lavel in cell
    @IBOutlet weak var accountTitle: UILabel!
    /// Cell account id in `AccountManager.shared`
    var accountId: Int!

    /// Closures for press and tab actions
    var pressAction: () -> Void = {}
    var tapAction: () -> Void = {}

    /// Set-ups tap and press actions.
    func setupGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(longPress)
        addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }

    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// Set-ups all gestures.
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGestures()
    }

    /// Handles press action and executes closure if all requirements met.
    /// - parameter gesture: long press gesture.
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            pressAction()
        }
    }

    /// Handles tap action and executes closure if all requirements met.
    /// - parameter gesture: tap gesture.
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            AccountManager.shared.select(by: accountId)
            tapAction()
        }
    }

    /// Set-ups cell by account id in `AccountManager.shared`
    /// - parameter id: account id.
    func setCell(by id: Int) {
        self.accountId = id
        let account = AccountManager.shared.get(by: id)

        self.accountTitle.text = account?.shortName
        self.accountTitle.textColor = UIColor(named: "AccentColor")

        self.accountDetails.text = ""
    }
}
