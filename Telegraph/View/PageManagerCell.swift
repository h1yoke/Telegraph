import UIKit

/// Cell view in Page Manager  table.
class PageManagerCell: UITableViewCell {
    /// Left label in cell
    @IBOutlet weak var titleLabel: UILabel!
    /// Right label in cell
    @IBOutlet weak var detailsLabel: UILabel!
    /// Loaded page (with or without actual content) of cell
    var page: Telegraph.Page?

    /// Closure for tap action
    var tapAction: () -> Void = {}

    /// Set-ups tap  action.
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }

    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// Set-ups all gestures.
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGestures()
    }

    /// Handles tap action and executes closure if all requirements met.
    /// - parameter gesture: tap gesture.
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            tapAction()
        }
    }

    /// Set-ups cell by page.
    /// - parameter page: cell page
    func setCell(by page: Telegraph.Page) {
        self.page = page
        self.titleLabel.text = page.title
        self.detailsLabel.text = ""
        self.titleLabel.textColor = UIColor(named: "AccentColor")
    }
}
