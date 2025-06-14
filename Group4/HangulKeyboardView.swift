import SwiftUI
import UIKit

struct HangulKeyboardView: UIViewControllerRepresentable {
    @Binding var text: String

    func makeUIViewController(context: Context) -> KeyboardContainerController {
        let controller = KeyboardContainerController()
        controller.onTextUpdate = { newText in
            text = newText
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: KeyboardContainerController, context: Context) {
        uiViewController.updateText(text)
    }
}

class KeyboardContainerController: UIViewController {
    var keyboardVC: KeyboardViewController!
    var onTextUpdate: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardVC = KeyboardViewController()
        addChild(keyboardVC)
        view.addSubview(keyboardVC.view)
        keyboardVC.view.frame = view.bounds
        keyboardVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        keyboardVC.didMove(toParent: self)

        // Bridge keyboard output to text field
        keyboardVC.textOutputHandler = { [weak self] composedText in
            self?.onTextUpdate?(composedText)
        }
    }

    func updateText(_ text: String) {
        keyboardVC.externalText = text
    }
}
