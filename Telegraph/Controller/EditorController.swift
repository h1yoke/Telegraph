import UIKit

/// Page editor controller. Contains editor text field and buttons.
class EditorController: UIViewController {
    /// Text editor
    @IBOutlet weak var editorController: UITextView!

    /// Account token
    var token: String!
    /// Editing page
    var page: Telegraph.Page!

    /// Called after the controller's view is loaded into memory.
    /// Set-ups page.
    override func viewDidLoad() {
        super.viewDidLoad()

        if page.content == nil {
            let method = Telegraph.Method.getPage(path: page.path, returnContent: true)
            try? Telegraph.query(method: method, completion: { (response: Telegraph.Response<Telegraph.Page>) in
                DispatchQueue.main.async {
                    if let result = response.result {
                        self.editorController.text = result.content?.reduce(into: "", { (partialResult: inout String, next: Telegraph.Node) in
                            partialResult += next.flatUnwrap()
                        })
                    }
                }
            })
        } else {
            editorController.text = page.content!.reduce(into: "", { (partialResult: inout String, next: Telegraph.Node) in
                partialResult += next.flatUnwrap()
            })
        }
    }

    /// Prompts if page need to be saved and exits editor.
    /// - parameter sender: back button
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Warning", message: "You are about to leave edited page. Save changes?", preferredStyle: .alert)

        let actions = [UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.page.content = [Telegraph.Node(textNode: self.editorController.text, object: nil)]

            let method = Telegraph.Method.editPage(accessToken: self.token, path: self.page.path, title: self.page.title, content: self.page.content!)

            try? Telegraph.query(method: method, completion: { (_: Telegraph.Response<Telegraph.Page>) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            })
        }),
        UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }),
        UIAlertAction(title: "Don't save", style: .destructive, handler: { _ in self.dismiss(animated: true) })
        ]

        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }

    /// Presents settings controller.
    /// - parameter sender: settings button.
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        /// TODO: Settings.
    }
}
