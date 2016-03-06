//
//  LanguageDefinition.swift
//  TastyImitationKeyboard
//
//  Created by Simon Corston-Oliver on 7/11/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation

// The housekeeping information that defines a language:
// the name of the language, the characters required to type that language etc.
//
// Note that the language information says nothing about keyboard layout and doesn't attempt an exhaustive listing of the kbds that
// could be used to type the language. We can determine programmatically elsewhere if a kbd contains all the necessary chars.
public class LanguageDefinition {

    // The ISO 639-1 language code.
    // REVIEW What to do about languages that don't have an ISO 639-1 code?
    private let _langCode : String

    // Name of the language in English
    private let _englishName : String

    // Name of the language in that language's native script
    private let _nativeName : String

    // Chars that a keyboard must contain for you to be able to type this language
    private let _requiredChars : Set<String>

    // The name of the JSON keyboard definition file for the default keyboard for this language
    private let _defaultKbd : String

    init(langCode: String,
        englishName: String, nativeName: String, requiredChars: [String], defaultKbd: String)
    {
        self._langCode = langCode
        self._englishName = englishName
        self._nativeName = nativeName
        self._requiredChars = Set<String>(requiredChars)
        self._defaultKbd = defaultKbd

    }

    var LangCode : String {
        get {
            return self._langCode
        }
    }

    var EnglishName : String {
        get {
            return self._englishName
        }
    }

    var NativeName : String {
        get {
            return self._nativeName
        }
    }

    var RequiredChars : Set<String> {
        get {
            return self._requiredChars
        }
    }

    var DefaultKbdName : String {
        get {
            return self._defaultKbd
        }
    }

    var DescriptiveName : String {
        get {
            return EnglishName + "/" + NativeName
        }
    }

    // Default English language definition to be used in case of an emergency
    // e.g. failing to load language definitions from the JSON language definition file.
    class private func EnglishLanguageDefinition() -> LanguageDefinition {
        return LanguageDefinition(
            langCode: "EN",
            englishName: "English",
            nativeName: "English",
            requiredChars: [
                "a", "b", "c", "d",
                "e", "f", "g", "h",
                "i", "j", "k", "l",
                "m", "n", "o", "p",
                "q", "r", "s", "t",
                "u", "v", "w", "x",
                "y", "z", "'",
                "A", "B", "C", "D",
                "E", "F", "G", "H",
                "I", "J", "K", "L",
                "M", "N", "O", "P",
                "Q", "R", "S", "T",
                "U", "V", "W", "X",
                "Y", "Z"
            ],
            defaultKbd: "QWERTY")
    }
}

// Get and validate the current language to use
// If what we think is the current language has been disabled in settings, we need to pick another language
func CurrentLanguageCode() -> String {
    return NSUserDefaults.standardUserDefaults().stringForKey(kActiveLanguageCode) ?? EnabledLanguageCodes()[0]
}

func CurrentLanguageDefinition() -> LanguageDefinition? {
    return LanguageDefinitions.Singleton().langCodeToDefinition[CurrentLanguageCode()]
}


// Make the look up key for checking in user defaults which layout to use for language
func languageKeyboardLayout(langCode: String) -> String
{
    return langCode + "_layout"
}

func getKeyboardLayoutNameForLanguageCode(langCode: String) -> String
{
    let lookUpKey = languageKeyboardLayout(langCode)
    return NSUserDefaults.standardUserDefaults().stringForKey(lookUpKey) ?? LanguageDefinitions.Singleton().KeyboardFileForLanguageCode(langCode) ?? "QWERTY"
}

func setKeyboardLayoutNameForLanguageCode(langCode: String, layout: String)
{
    let lookUpKey = languageKeyboardLayout(langCode)
    return NSUserDefaults.standardUserDefaults().setObject(layout, forKey: lookUpKey)
}

func setDefaultKeyboardLayoutNameForLanguageCode(langCode: String, layout: String)
{
    let lookUpKey = languageKeyboardLayout(langCode)

    let currentValue = NSUserDefaults.standardUserDefaults().stringForKey(lookUpKey)
    if currentValue == nil {
        setKeyboardLayoutNameForLanguageCode(langCode, layout: layout)
    }
}

func langCodeEnabledKey (langCode: String) -> String
{
    return langCode + "_Enabled"
}

func getLanguageCodeEnabled(langCode: String) -> Bool
{
    return NSUserDefaults.standardUserDefaults().boolForKey(langCodeEnabledKey(langCode))
}

func setLanguageCodeEnabled(langCode: String, value: Bool)
{
    return NSUserDefaults.standardUserDefaults().setObject(value, forKey: langCodeEnabledKey(langCode))
}

func EnabledLanguageCodes() -> [String]
{
    var enabledCodes: [String] = []

    let defs = LanguageDefinitions.Singleton().definitions

    for definition in defs {
        let key = definition.LangCode

        if getLanguageCodeEnabled(key) {
            enabledCodes.append(key)
        }
    }

    // Make sure at least one language is always enabled
    if enabledCodes.count == 0 {
        enabledCodes.append("EN")
    }

    return enabledCodes
}


// class var not yet supported so make it global
private var _Singleton: LanguageDefinitions? = nil

// Define the set of languages currently supported
public class LanguageDefinitions {
    public var definitions : [LanguageDefinition] = []
    public var langCodeToDefinition: [String : LanguageDefinition] = [:]


    private func extractLanguageDefinitions(allDefinitions: NSDictionary)
    {
        if let languages = allDefinitions["languages"] as? NSArray {

            for language in languages {

                if let languageProperties = language["language"] as? NSDictionary {


                    if let englishName = languageProperties["englishName"] as? String,
                        let nativeName = languageProperties["nativeName"] as? String,
                        let defaultKbd = languageProperties["defaultKbd"] as? String,
                        let requiredChars = languageProperties["requiredCharacters"] as? [String],
                        let langCode = languageProperties["langCode"] as? String {

                            let definition = LanguageDefinition(
                                langCode: langCode,
                                englishName: englishName,
                                nativeName: nativeName,
                                requiredChars: requiredChars,
                                defaultKbd: defaultKbd)

                            self.definitions.append(definition)
                            self.langCodeToDefinition[definition.LangCode] = definition

                            setDefaultKeyboardLayoutNameForLanguageCode(definition.LangCode, layout: definition.DefaultKbdName)
                    }
                }

                
            }
        }
        else {
            makeDefaultLangDefinitions()
        }
    }

    // If we can't process the langauge definition file for some reason make sure we at least define English
    private func makeDefaultLangDefinitions()
    {
        definitions = [LanguageDefinition.EnglishLanguageDefinition()]
        langCodeToDefinition["EN"] = definitions[0]
    }

    init(jsonFileName : String)
    {
        if let languageDefinitions = loadJSON("LanguageDefinitions") {

            self.extractLanguageDefinitions(languageDefinitions)
        }
        else {

            makeDefaultLangDefinitions()
        }
    }

    func LanguageNames() -> [String]
    {
        var names : [String] = []

        for languageDefinition in definitions {
            names.append(languageDefinition.DescriptiveName)
        }

        return names
    }

    func LangCodes() -> [String]
    {
        return langCodeToDefinition.keys.sort()
    }

    func DescriptiveNameForLangCode(langCode: String) -> String {
        return self.langCodeToDefinition[langCode]?.DescriptiveName ?? "UNKNOWN"
    }

    func KeyboardFileForLanguageCode(langCode: String) -> String? {
        for lang in self.definitions {
            if lang.LangCode == langCode {
                return lang.DefaultKbdName
            }
        }

        return nil
    }

    class func Singleton() -> LanguageDefinitions {
        if _Singleton == nil {
            _Singleton = LanguageDefinitions(jsonFileName: "LanguageDefinitions")
        }

        return _Singleton!
    }
}