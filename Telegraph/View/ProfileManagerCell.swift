import UIKit

/// Cell view in Profile Manager  table.
class ProfileManagerCell: UITableViewCell {
    /// Left label in cell
    @IBOutlet weak var profileDetails: UILabel!
    /// Right label in cell
    @IBOutlet weak var profileTitle: UILabel!
    /// Cell profile id in `ProfileManager.shared`
    var profileId: Int!

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
            ProfileManager.shared.select(id: profileId)
            tapAction()
        }
    }

    /// Set-ups cell by profile id in `ProfileManager.shared`
    /// - parameter id: profile id.
    func setCell(by id: Int) {
        self.profileId = id

        self.profileTitle.text = ProfileManager.shared.get(id: id).shortName
        self.profileTitle.textColor = UIColor(named: "AccentColor")

        self.profileDetails.text = ""
    }
}
