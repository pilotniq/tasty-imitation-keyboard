//
//  KeyboardModel.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/10/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import Foundation

var counter = 0

enum ShiftState {
    case Disabled
    case Enabled
    case Locked
    
    func uppercase() -> Bool {
        switch self {
        case Disabled:
            return false
        case Enabled:
            return true
        case Locked:
            return true
        }
    }
}

class Keyboard {
    var pages: [Page]
    
    init() {
        self.pages = []
    }
    
    func addKey(key: Key, row: Int, page: Int) {
        if self.pages.count <= page {
            for _ in self.pages.count...page {
                self.pages.append(Page())
            }
        }
        
        self.pages[page].addKey(key, row: row)
    }
}

class Page {
    var rows: [[Key]]
    
    init() {
        self.rows = []
    }
    
    func addKey(key: Key, row: Int) {
        if self.rows.count <= row {
            for _ in self.rows.count...row {
                self.rows.append([])
            }
        }

        self.rows[row].append(key)
    }
}

class SpecialUnicodeSymbols {

    class var ReturnSymbol : String {
        get {
            return "\u{21B2}" // DOWNWARDS ARROW WITH TIP LEFTWARDS
        }
    }

    class var NextKeyboardSymbol : String {
        get {
            // 🌐= GLOBE WITH MERIDIANS
            // Looks all blue on iOS :(
            return "\u{1F310}"

            // Symbol not supported on iOS
            // "\u{1F5A6}" // ⌨ KEYBOARD
        }
    }

    class var SmilingFace : String {
        get {
            return "\u{263A}" // WHITE SMILING FACE
        }
    }

    class var GearSymbol : String {
        get {
            return "\u{2699}" // ⚙ GEAR
        }
    }
}
class Key: Hashable {
    enum KeyType {
        case Character
        case SpecialCharacter
        case Shift
        case Backspace
        case ModeChange
        case KeyboardChange
        case Period
        case Space
        case Return
        case Settings
        case Other
    }
    
    var isTopRow: Bool
    var type: KeyType
    var uppercaseKeyCap: String?
    var lowercaseKeyCap: String?
    var uppercaseOutput: String?
    var lowercaseOutput: String?
    var toMode: Int? //if the key is a mode button, this indicates which page it links to
    
    var isCharacter: Bool {
        get {
            switch self.type {
            case
            .Character,
            .SpecialCharacter,
            .Period:
                return true
            default:
                return false
            }
        }
    }
    
    var isSpecial: Bool {
        get {
            return self.type == .Shift
            || self.type == .Backspace
            || self.type == .ModeChange
            || self.type == .KeyboardChange
            || self.type == .Return
            || self.type == .Settings
        }
    }
    
    var hasOutput: Bool {
        get {
            return (self.uppercaseOutput != nil) || (self.lowercaseOutput != nil)
        }
    }
    
    // TODO: this is kind of a hack
    var hashValue: Int
    
    init(_ type: KeyType) {
        self.type = type
        self.isTopRow = false
        self.hashValue = counter
        counter += 1
    }
    
    convenience init(_ key: Key) {
        self.init(key.type)
        
        self.uppercaseKeyCap = key.uppercaseKeyCap
        self.lowercaseKeyCap = key.lowercaseKeyCap
        self.uppercaseOutput = key.uppercaseOutput
        self.lowercaseOutput = key.lowercaseOutput
        self.toMode = key.toMode
    }
    
    func setLetter(letter: String) {
        self.lowercaseOutput = (letter as NSString).lowercaseString
        self.uppercaseOutput = (letter as NSString).uppercaseString
        self.lowercaseKeyCap = self.lowercaseOutput
        self.uppercaseKeyCap = self.uppercaseOutput
    }
    
    func outputForCase(uppercase: Bool) -> String {
        if uppercase {
            return self.uppercaseOutput ?? self.lowercaseOutput ?? ""
        }
        else {
            return self.lowercaseOutput ?? self.uppercaseOutput ?? ""
        }
    }
    
    func keyCapForCase(uppercase: Bool) -> String {
        if uppercase {
            return self.uppercaseKeyCap ?? self.lowercaseKeyCap ?? ""
        }
        else {
            return self.lowercaseKeyCap ?? self.uppercaseKeyCap ?? ""
        }
    }
    
    class func SlashKey() -> Key
    {
        let slashModel = Key(.Character)
        slashModel.setLetter("/")
        
        return slashModel
    }
    
    class func AtKey() -> Key
    {
        let atModel = Key(.Character)
        atModel.setLetter("@")
        
        return atModel
    }
    
    class func PeriodKey() -> Key
    {
        let dotModel = Key(.Character)
        dotModel.setLetter(".")
        
        return dotModel
    }
    
    class func SpaceKey() -> Key
    {
        let space = Key(.Space)
        space.uppercaseKeyCap = "space"
        space.uppercaseOutput = " "
        space.lowercaseOutput = " "
        return space
    }
    
    class func ReturnKey() -> Key
    {
        let returnKey = Key(.Return)
        returnKey.uppercaseKeyCap = SpecialUnicodeSymbols.ReturnSymbol
        returnKey.uppercaseOutput = "\n"
        returnKey.lowercaseOutput = "\n"
        return returnKey
    }
    
    class func ModeChangeNumbersKey() -> Key
    {
        let keyModeChangeNumbers = Key(.ModeChange)
        keyModeChangeNumbers.uppercaseKeyCap = "123"
        keyModeChangeNumbers.toMode = 1
        return keyModeChangeNumbers
        
    }
    
    class func ModeChangeLettersKey() -> Key
    {
        let keyModeChangeLetters = Key(.ModeChange)
        keyModeChangeLetters.uppercaseKeyCap = "ABC"
        keyModeChangeLetters.toMode = 0
        return keyModeChangeLetters
    }

    class func NextKbdKey() -> Key
    {
        let nextKbdKey = Key(.KeyboardChange)

        return nextKbdKey
    }


}

func ==(lhs: Key, rhs: Key) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
