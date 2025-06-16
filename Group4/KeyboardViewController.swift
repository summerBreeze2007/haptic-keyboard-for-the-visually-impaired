import UIKit
import CoreHaptics


// MARK: - KeyboardViewController
class KeyboardViewController: UIInputViewController {
    
    var textOutputHandler: ((String) -> Void)?
    var externalText: String = ""
    var pendingDecomposedFlushInsert = false
    
    private var engine: CHHapticEngine?


    
    let composer = SimpleHangulComposer()
    var isShiftEnabled = false
    var hasComposed = false
    var hapticMapping: [[(UIButton) -> Void]] = []
//    let generatorSoft = UIImpactFeedbackGenerator(style: .soft)
//    let generatorMedium = UIImpactFeedbackGenerator(style: .medium)
//    let generatorHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    
    private func setupEngine() {
        do{
            engine = try CHHapticEngine()
            try engine?.start()
            
        } catch {
            print("Haptic engine failed to start: \(error.localizedDescription)")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hapticMapping = [
            [keyTappedH, keyTappedS, keyTappedM],
            [keyTappedM, keyTappedH, keyTappedS],
            [keyTappedS, keyTappedM, keyTappedH]
        ]
//        generatorSoft.prepare()
//        generatorMedium.prepare()
//        generatorHeavy.prepare()
        setupEngine()
        

        view.backgroundColor = .systemGray4
        setupKeyboard()
    }
    

    
    func setupKeyboard() {
        let normalKeys: [[String]] = [
            ["ㅂ", "ㅈ", "ㄷ", "ㄱ", "ㅅ", "ㅛ", "ㅕ", "ㅑ", "ㅐ", "ㅔ"],
            ["ㅁ", "ㄴ", "ㅇ", "ㄹ", "ㅎ", "ㅗ", "ㅓ", "ㅏ", "ㅣ"],
            ["⇧", "ㅋ", "ㅌ", "ㅊ", "ㅍ", "ㅠ", "ㅜ", "ㅡ", "⌫"],
            ["띄어쓰기", ".", "⏎"]
        ]
        
        let shiftKeys: [[String]] = [
            ["ㅃ", "ㅉ", "ㄸ", "ㄲ", "ㅆ", "ㅛ", "ㅕ", "ㅑ", "ㅒ", "ㅖ"],
            ["ㅁ", "ㄴ", "ㅇ", "ㄹ", "ㅎ", "ㅗ", "ㅓ", "ㅏ", "ㅣ"],
            ["⇧", "ㅋ", "ㅌ", "ㅊ", "ㅍ", "ㅠ", "ㅜ", "ㅡ", "⌫"],
            ["띄어쓰기", ".", "⏎"]
        ]
        
        let keyboardStack = UIStackView()
        keyboardStack.axis = .vertical
        keyboardStack.spacing = 10
        keyboardStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardStack)
        
        NSLayoutConstraint.activate([
            keyboardStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            keyboardStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            keyboardStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            keyboardStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        
        let keys = isShiftEnabled ? shiftKeys : normalKeys
        
        for (rowIndex, row) in keys.enumerated() {
            let isLastRow = (row == keys.last)
            let isFirstRow = (row == keys.first)
            let rowHeight: CGFloat = isLastRow ? 50 : 54
            
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fill
            rowStack.alignment = .center
            rowStack.spacing = isFirstRow || isLastRow ? 6 : 7
            if rowIndex == 2 {
                rowStack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            } else {
                rowStack.layoutMargins = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
            }
            rowStack.isLayoutMarginsRelativeArrangement = true
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            rowStack.setContentHuggingPriority(.required, for: .horizontal)
            rowStack.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            for (index, key) in row.enumerated() {
                let button = UIButton(type: .system)
                button.setTitle(key, for: .normal)
                

                
                button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
                
                button.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
                
                if key == "⇧" || key == "⌫" {
                    button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
                }
                
                button.setTitleColor(.black, for: .normal)
                button.layer.cornerRadius = 6
                button.layer.borderColor = UIColor.systemGray4.cgColor
                button.layer.borderWidth = 0.5
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOffset = CGSize(width: 0, height: 1)
                button.layer.shadowOpacity = 0.1
                button.layer.shadowRadius = 1
                button.layer.masksToBounds = false
                
                if key == "⇧" {
                    button.widthAnchor.constraint(equalToConstant: 31).isActive = true
                } else if key == "⌫" {
                    button.widthAnchor.constraint(equalToConstant: 49).isActive = true
                }else if isLastRow {
                    switch key {
                    case "띄어쓰기":
                        button.widthAnchor.constraint(equalToConstant: 275).isActive = true
                    case "⏎":
                        button.widthAnchor.constraint(equalToConstant: 45).isActive = true
                    default:
                        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
                    }
                } else if isFirstRow {
                    button.widthAnchor.constraint(equalToConstant: 32).isActive = true
                } else if rowIndex == 1 {
                    button.widthAnchor.constraint(equalToConstant: 34).isActive = true
                }else {
                    button.widthAnchor.constraint(equalToConstant: 33).isActive = true
                }
                
                button.heightAnchor.constraint(equalToConstant: rowHeight - 5).isActive = true
                
                switch key {
                case "띄어쓰기", "⌫", "⇧", "⏎", ".":
                    button.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
                default:
                    let tag = (rowIndex != 2) ? (rowIndex + 1) * 10 + (index % 3) : (rowIndex + 1) * 10 + ((index - 1) % 3)
                    button.tag = tag
                    button.addTarget(self, action: #selector(keyHandler(_:)), for: .touchUpInside)
                }
                
                rowStack.addArrangedSubview(button)
            }
            
            // Wrap in container and fix height
            let rowContainer = UIView()
            rowContainer.translatesAutoresizingMaskIntoConstraints = false
            rowContainer.addSubview(rowStack)
            
            var constraints: [NSLayoutConstraint] = [
                rowStack.topAnchor.constraint(equalTo: rowContainer.topAnchor),
                rowStack.bottomAnchor.constraint(equalTo: rowContainer.bottomAnchor),
                rowContainer.heightAnchor.constraint(equalToConstant: rowHeight)
            ]

            if rowIndex == 2 {
                constraints.append(rowStack.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor, constant: 0))
            } else {
                constraints.append(rowStack.centerXAnchor.constraint(equalTo: rowContainer.centerXAnchor))
            }

            NSLayoutConstraint.activate(constraints)
            
            keyboardStack.addArrangedSubview(rowContainer)
        }
    }

    
    func composerNeedsFlushingBeforeInsertNew(char: Character) -> Bool {
        return composer.jung == nil && composer.cho != nil && composer.jong == nil && composer.jungMap.keys.contains(char)
    }
    
    @objc func tap(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
        
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.16)
        
        
        do {
            let pattern = try CHHapticPattern(events: [event1, event2], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic Play Error: \(error.localizedDescription)")
        }
        
        switch title {
        case "띄어쓰기":
            if hasComposed {
                textDocumentProxy.deleteBackward()
                textDocumentProxy.insertText(composer.flush())
                textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
            }
            textDocumentProxy.insertText(" ")
            textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
            composer.reset()
            hasComposed = false
            
        case "⌫":
            if hasComposed {
                textDocumentProxy.deleteBackward()
                composer.reset()
                textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
                hasComposed = false
            } else {
                textDocumentProxy.deleteBackward()
                textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
            }

            
        case "⇧":
            isShiftEnabled.toggle()
            view.subviews.forEach { $0.removeFromSuperview() }
            setupKeyboard()
            
        case "⏎":
            if hasComposed {
                textDocumentProxy.deleteBackward()
                textDocumentProxy.insertText(composer.flush())
                textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
            }
            textDocumentProxy.insertText("\n")
            textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
            composer.reset()
            hasComposed = false
            
        case ".":
            if hasComposed {
                textDocumentProxy.deleteBackward()
                textDocumentProxy.insertText(composer.flush())
                textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
            }
            textDocumentProxy.insertText(".")
            textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
            composer.reset()
            hasComposed = false
        default:
            break
        }
    }
    
    @objc func keyHandler(_ sender: UIButton) {
        let tag = sender.tag
        let row = tag / 10 - 1
        let col = tag % 10
        
        let action = hapticMapping[row][col]
        action(sender)
    }
    
    func keyTappedS(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }

//        generatorSoft.impactOccurred()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.05)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.06)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic Play Error: \(error.localizedDescription)")
        }
        
        if hasComposed {
            textDocumentProxy.deleteBackward()
        } else if composerNeedsFlushingBeforeInsertNew(char: title.first!) {
            textDocumentProxy.deleteBackward()
        }
        let (output, composed) = composer.input(char: title.first!)
        textDocumentProxy.insertText(output)
        textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
        hasComposed = composed
        if isShiftEnabled {
            isShiftEnabled = false
            view.subviews.forEach { $0.removeFromSuperview() }
            setupKeyboard()
        }

    }
    
    
    
    func keyTappedM(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }

//        generatorMedium.impactOccurred()
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic Play Error: \(error.localizedDescription)")
        }
        
        if hasComposed {
            textDocumentProxy.deleteBackward()
        } else if composerNeedsFlushingBeforeInsertNew(char: title.first!) {
            textDocumentProxy.deleteBackward()
        }
        let (output, composed) = composer.input(char: title.first!)
        textDocumentProxy.insertText(output)
        textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
        hasComposed = composed
        if isShiftEnabled {
            isShiftEnabled = false
            view.subviews.forEach { $0.removeFromSuperview() }
            setupKeyboard()
        }
    }
    
    func keyTappedH(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }

//        generatorHeavy.impactOccurred()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.06)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic Play Error: \(error.localizedDescription)")
        }
        
        if hasComposed {
            textDocumentProxy.deleteBackward()
        } else if composerNeedsFlushingBeforeInsertNew(char: title.first!) {
            textDocumentProxy.deleteBackward()
        }
        let (output, composed) = composer.input(char: title.first!)
        textDocumentProxy.insertText(output)
        textOutputHandler?(textDocumentProxy.documentContextBeforeInput ?? "")
        hasComposed = composed
        if isShiftEnabled {
            isShiftEnabled = false
            view.subviews.forEach { $0.removeFromSuperview() }
            setupKeyboard()
        }
    }
    

    
    
}
