import UIKit


// MARK: - SimpleHangulComposer
class SimpleHangulComposer {
    var cho: Character?
    var jung: Character?
    var jong: Character?
    var flushedBeforeVowel = false

    let choMap: [Character: Int] = [
        "ㄱ": 0, "ㄲ": 1, "ㄴ": 2, "ㄷ": 3, "ㄸ": 4, "ㄹ": 5, "ㅁ": 6, "ㅂ": 7, "ㅃ": 8, "ㅅ": 9,
        "ㅆ": 10, "ㅇ": 11, "ㅈ": 12, "ㅉ": 13, "ㅊ": 14, "ㅋ": 15, "ㅌ": 16, "ㅍ": 17, "ㅎ": 18
    ]

    let jungMap: [Character: Int] = [
        "ㅏ": 0, "ㅐ": 1, "ㅑ": 2, "ㅒ": 3, "ㅓ": 4, "ㅔ": 5, "ㅕ": 6, "ㅖ": 7,
        "ㅗ": 8, "ㅘ": 9, "ㅙ": 10, "ㅚ": 11, "ㅛ": 12,
        "ㅜ": 13, "ㅝ": 14, "ㅞ": 15, "ㅟ": 16, "ㅠ": 17,
        "ㅡ": 18, "ㅢ": 19, "ㅣ": 20
    ]

    let jongMap: [Character: Int] = [
        "ㄱ": 1, "ㄲ": 2, "ㄳ": 3, "ㄴ": 4, "ㄵ": 5, "ㄶ": 6, "ㄷ": 7, "ㄹ": 8, "ㄺ": 9, "ㄻ": 10,
        "ㄼ": 11, "ㄽ": 12, "ㄾ": 13, "ㄿ": 14, "ㅀ": 15, "ㅁ": 16, "ㅂ": 17, "ㅄ": 18, "ㅅ": 19,
        "ㅆ": 20, "ㅇ": 21, "ㅈ": 22, "ㅊ": 23, "ㅋ": 24, "ㅌ": 25, "ㅍ": 26, "ㅎ": 27
    ]
    let vowelCombinations: [String: Character] = [
        "ㅗㅏ": "ㅘ", "ㅗㅐ": "ㅙ", "ㅗㅣ": "ㅚ",
        "ㅜㅓ": "ㅝ", "ㅜㅔ": "ㅞ", "ㅜㅣ": "ㅟ",
        "ㅡㅣ": "ㅢ"
    ]
    
    let reverseJongMap: [Character: (Character, Character)] = [
        "ㄳ": ("ㄱ", "ㅅ"), "ㄵ": ("ㄴ", "ㅈ"), "ㄶ": ("ㄴ", "ㅎ"),
        "ㄺ": ("ㄹ", "ㄱ"), "ㄻ": ("ㄹ", "ㅁ"), "ㄼ": ("ㄹ", "ㅂ"),
        "ㄽ": ("ㄹ", "ㅅ"), "ㄾ": ("ㄹ", "ㅌ"), "ㄿ": ("ㄹ", "ㅍ"),
        "ㅀ": ("ㄹ", "ㅎ"), "ㅄ": ("ㅂ", "ㅅ")
    ]
    
    let jongCombinations: [String: Character] = [
        "ㄱㅅ": "ㄳ",
        "ㄴㅈ": "ㄵ",
        "ㄴㅎ": "ㄶ",
        "ㄹㄱ": "ㄺ",
        "ㄹㅁ": "ㄻ",
        "ㄹㅂ": "ㄼ",
        "ㄹㅅ": "ㄽ",
        "ㄹㅌ": "ㄾ",
        "ㄹㅍ": "ㄿ",
        "ㄹㅎ": "ㅀ",
        "ㅂㅅ": "ㅄ"
    ]

    func input(char: Character) -> (String, Bool) {
        if jungMap.keys.contains(char) {
            if cho == nil && jung == nil {
                jung = char
                return (String(char), true)
            } else if cho == nil && jung != nil {
                let flushed = flush()
                jung = char
                return (flushed + String(char), true)
            } else if jung == nil {
                jung = char
                flushedBeforeVowel = false
                return (compose(), true)
            } else if let j = jong {
                
                if let (first, second) = reverseJongMap[j] {
                    jong = first
                    let flushed = compose()
                    cho = second
                    jung = char
                    jong = nil
                    flushedBeforeVowel = true
                    return (flushed + compose(), true)
                } else {
                    jong = nil
                    let flushed = compose()
                    cho = j
                    jung = char
                    flushedBeforeVowel = true
                    return (flushed + compose(), true)
                }

            } else if let currentJung = jung {
                let combined = vowelCombinations["\(currentJung)\(char)"]
                if let newVowel = combined {
                    jung = newVowel
                    flushedBeforeVowel = false
                    return (compose(), true)
                } else {
                    let flushed = flush()
                    jung = char
                    return (flushed + String(char), true)
                }
            }else {
                let flushed = flush()
                jung = char
                return (flushed + String(char), true)
            }
        } else if choMap.keys.contains(char) {
            if cho == nil {
                cho = char
                return (String(char), false)
            } else if jung != nil && jong == nil {
                jong = char
                return (compose(), true)
            } else if let currentJong = jong {
                let combined = jongCombinations["\(currentJong)\(char)"]
                if let newJong = combined {
                    jong = newJong
                    return (compose(), true)
                } else {
                    let flushed = flush()
                    cho = char
                    return (flushed + String(char), true)
                }
            }
            
            return (String(char), false)
            
            
        } else {
            return (String(char), false)
        }
    }
    
    func deleteLast() -> (String, Bool) {
        reset()
        return ("", false)
    }

    func flush() -> String {
        let result = compose()
        reset()
        return result
    }

    private func compose() -> String {
        if let c = cho, let v = jung {
            let choIndex = choMap[c] ?? 0
            let jungIndex = jungMap[v] ?? 0
            let jongIndex = jong.flatMap { jongMap[$0] } ?? 0
            let scalar = UnicodeScalar(0xAC00 + choIndex * 21 * 28 + jungIndex * 28 + jongIndex)!
            return String(Character(scalar))
        } else if let v = jung {
            return String(v)
        } else if let c = cho {
            return String(c)
        }
        return ""
    }

    func reset() {
        cho = nil
        jung = nil
        jong = nil
        flushedBeforeVowel = false
    }
}
