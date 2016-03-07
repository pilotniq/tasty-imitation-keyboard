//
//  WordStore.swift
//  TastyImitationKeyboard
//
//  Created by Simon Corston-Oliver on 13/02/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import Foundation

let MaxPersistedWords = 1000

// If the word list is at max size, it would be inefficient to trim it every time we want to add a new word.
// Instead, add a slop factor that we will allow it to grow in memory beyond the max size
let MaxGrowth = 100

// Swift doesn't yet support class vars so create this at file scope
var wordStore : WordStore? = nil

// Letters, combining marks etc.
// Note that if a language uses the number 7 (e.g Squamish) as a letter then it would have to be listed as a word-internal punc
let AllLetters = NSCharacterSet.letterCharacterSet()

class WordStore
{
    private let langCode : String
    private var words : [String : NSDate] = [:]
    private var currentWord = ""

    private func WordStoreKey() -> String {
        return "WordStore_" + self.langCode
    }

    init (langCode: String)
    {
        self.langCode = langCode

        // Load previous words if present
        self.words = (NSUserDefaults.standardUserDefaults().objectForKey(self.WordStoreKey()) as? [String : NSDate]) ?? self.words

        // Whatever the size restrictions when the words were persisted, make sure we trim to max size
        trimWords(MaxPersistedWords)

    }

    // For now the only suggestions are completions.
    // TODO: Also suggest corrections
    func getSuggestions(max: Int) -> [String]
    {
        let completions = self.words.keys.filter({ $0.hasPrefix(self.currentWord) })
            .sort({ self.words[$0]!.compare(self.words[$1]!) == NSComparisonResult.OrderedDescending })
            .prefix(max)

        return Array(completions)
    }

    // Update datetime for existing word or create new entry so we can track most recently used words
    func recordWord(word : String)
    {
        self.words[word] = NSDate()

        // If the user types "t", sees a completion "that" then selects the completion we were seeing
        // ghosts -- "t" would get added to the MRU list as well when the space was inserted.
        self.ResetContext()

        if self.words.count > MaxPersistedWords + MaxGrowth {
            trimWords(MaxPersistedWords)
        }

    }

    func trimWords(maxWords : Int)
    {
        if self.words.count <= maxWords {
            return
        }

        // (1) Sort the key/value pairs descending by value to produce an array of key/value pairs
        // (2) Take the first n
        // (3) Convert back to a dict
        //
        // Note that this will arbitrarily drop words from the oldest date
        let sortedReverseByDate = self.words.sort{ $0.1.compare($1.1) == NSComparisonResult.OrderedDescending }[0..<maxWords]

        // HACKHACK there are clever functional examples on the webz but KISS
        self.words = [String : NSDate]()
        for (k, v) in sortedReverseByDate {
            self.words[k] = v
        }

    }

    func persistWords()
    {
        trimWords(MaxPersistedWords)
        NSUserDefaults.standardUserDefaults().setObject(self.words, forKey: self.WordStoreKey())
    }

    var LangCode : String {
        get {
            return self.langCode
        }
    }

    var CurrentWord : String {
        get {
            return self.currentWord
        }
    }

    func recordChar(ch : String) {
        if ch == "" {
            return
        }

        if let wordInternalCharOfLanguage = CurrentLanguageDefinition()?.InternalPunc.contains(ch) where wordInternalCharOfLanguage == true {

            self.currentWord += ch
        } else if AllLetters.longCharacterIsMember(ch.unicodeScalars.first!.value) {

            self.currentWord += ch
        } else {

            self.recordWord(currentWord)
            self.currentWord = ""
        }
    }

    func ResetContext() {
        self.currentWord = ""
    }

    func DeleteBackward() {
        
        if self.currentWord.characters.count > 0 {

            self.currentWord.removeAtIndex(self.currentWord.endIndex.predecessor())
        }
    }

    class func CurrentWordStore() -> WordStore {
        let currentLang = CurrentLanguageCode()

        if wordStore == nil {
            wordStore = WordStore(langCode: currentLang)
        }
        else if wordStore?.LangCode != currentLang {
            wordStore?.persistWords()
            wordStore = WordStore(langCode: currentLang)
        }

        return wordStore!
    }

}