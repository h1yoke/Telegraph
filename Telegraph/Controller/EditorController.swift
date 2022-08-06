import UIKit
import RichEditorView

/// Page editor controller. Contains editor text field and buttons.
class EditorController: UIViewController, RichEditorToolbarDelegate {
    /// Text editor
    @IBOutlet weak var editorView: UIView!
    var editor: RichEditorView!
    var toolbar: RichEditorToolbar!

    /// Account token
    var token: String!
    /// Shown page
    var page: Telegraph.Page!

    /// Loades page content.
    func loadPage() {
        editor = RichEditorView(frame: editorView.bounds)
        editorView.addSubview(editor)

        toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        toolbar.editor = editor
        editor.inputAccessoryView = toolbar

        if page.content == nil {
            let method = Telegraph.Method.getPage(path: page.path, returnContent: true)
            try? Telegraph.query(method: method, completion: { (response: Telegraph.Response<Telegraph.Page>) in
                if let result = response.result {
                    let html = result.content?.reduce(into: "", { (partialResult: inout String, next: Telegraph.Node) in
                        partialResult += next.flatUnwrap()
                    })
                    self.editor.html = html ?? ""
                }
            })
        }
    }

    /// Called after the controller's view is loaded into memory.
    /// Set-ups page.
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPage()
        if !(page.canEdit ?? false) {
            editor.isEditingEnabled = false
        }
    }

    /// Prompts if page need to be saved and exits editor.
    /// - parameter sender: back button
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Warning", message: "You are about to leave edited page. Save changes?", preferredStyle: .alert)

        let actions = [UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.page.content = [Telegraph.Node(textNode: self.editor.html, object: nil)]

            let method = Telegraph.Method.editPage(accessToken: self.token, path: self.page.path, title: self.page.title, content: self.page.content!)

            try? Telegraph.query(method: method, completion: { (_: Telegraph.Response<Telegraph.Page>) in
                self.dismiss(animated: true)
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
