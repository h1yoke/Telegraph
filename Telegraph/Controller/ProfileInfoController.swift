import UIKit
import PhotosUI
import SwiftUI

/// Profile info controller. Holds all aditional info about profile.
class ProfileInfoController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// Profile profile button with image
    @IBOutlet weak var profileImage: UIImageView!
    /// Profile short name field
    @IBOutlet weak var shortNameField: UITextField!
    /// Profile author name field
    @IBOutlet weak var authorNameField: UITextField!
    /// Profile url field
    @IBOutlet weak var authorUrlField: UITextField!
    /// Profile token field
    @IBOutlet weak var tokenField: UITextField!
    /// Controller bar title
    @IBOutlet weak var barTitle: UINavigationItem!
    /// Image picker controller
    var imagePicker: UIImagePickerController = {
        var pickerController = UIImagePickerController()
        pickerController.allowsEditing = true
        pickerController.sourceType = .photoLibrary
        return pickerController
    }()

    /// Selected profile id in `ProfileManager.shared`
    var profileId: Int!
    /// Edit flag
    var isEditMode = false

    /// Start image-picker for profile profile image.
    /// - parameter sender: image button
    @objc func profileButtonPressed(_ gesture: UITapGestureRecognizer) {
        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        self.profileImage.image = image
        ProfileManager.shared.get(id: profileId).updateImage(image: image)
        dismiss(animated: true)
    }

    /// Revokes profile acess token.
    /// - parameter sender: update button
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Warning",
            message: "You are about to revoke access token. " +
                "This action will untie all logined devices except this. Continue?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Revoke", style: .destructive, handler: { _ in
            let token = ProfileManager.shared.get(id: self.profileId).accessToken
            let method = Telegraph.Method.revokeAccessToken(accessToken: token)
            try? Telegraph.query(method: method, completion: { (response: Telegraph.Response<Telegraph.Account>) in
                if let result = response.result,
                   let profile = Profile(newAccount: result) {
                    ProfileManager.shared.edit(id: self.profileId, newProfile: profile)
                }
            })
        }))
        present(alert, animated: true)
    }

    /// Copies profile token to clipboard.
    /// - parameter sender: copy button
    @IBAction func copyButtonPressed(_ sender: UIButton) {
        UIPasteboard.general.string = ProfileManager.shared.get(id: profileId).accessToken
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

    /// Deletes profile.
    /// - parameter sender: delete button
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        ProfileManager.shared.delete(id: profileId)

        if let profileManagerVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ProfileManagerControllerID") as? ProfileManagerController {
            profileManagerVC.modalPresentationStyle = .fullScreen
            present(profileManagerVC, animated: false) {
                profileManagerVC.profileTableView?.reloadData()
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
    /// - parameter profile: telegraph profile
    func commonInit(profile: Profile) {
        imagePicker.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(profileButtonPressed(_:)))
        profileImage.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true
        if let image = profile.profileImage {
            profileImage.image = image
        }

        barTitle.title = profile.shortName ?? "Profile" + " Info"
        shortNameField.changeAttributedText(string: profile.shortName ?? "")
        authorNameField.changeAttributedText(string: profile.authorName ?? "")
        authorUrlField.changeAttributedText(string: profile.authorUrl ?? "")
        tokenField.changeAttributedText(string: profile.accessToken)
        disable()
    }

    /// Called after the controller's view is loaded into memory.
    /// Set-ups all text fields by given profile.
    override func viewDidLoad() {
        super.viewDidLoad()

        let profile = ProfileManager.shared.get(id: profileId)
        commonInit(profile: profile)
    }
}
