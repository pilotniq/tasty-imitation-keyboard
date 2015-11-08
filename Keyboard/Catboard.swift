//
//  Catboard.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 9/24/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

/*
This is the demo keyboard. If you're implementing your own keyboard, simply follow the example here and then
set the name of your KeyboardViewController subclass in the Info.plist file.
*/

let kCatTypeEnabled = "kCatTypeEnabled"

class Catboard: KeyboardViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        NSUserDefaults.standardUserDefaults().registerDefaults([kCatTypeEnabled: true])
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyPressed(key: Key) {
        let textDocumentProxy = self.textDocumentProxy
        
        let keyOutput = key.outputForCase(self.shiftState.uppercase())
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(kCatTypeEnabled) {
            textDocumentProxy.insertText(keyOutput)
            return
        }
        
        if key.type == .Character || key.type == .SpecialCharacter {
            let context = textDocumentProxy.documentContextBeforeInput
            if context != nil {
                if context!.characters.count < 2 {
                    textDocumentProxy.insertText(keyOutput)
                    return
                }
                
                var index = context!.endIndex
                
                index = index.predecessor()
                if context?.characters[index] != " " {
                    textDocumentProxy.insertText(keyOutput)
                    return
                }
                
                index = index.predecessor()
                if context?.characters[index] == " " {
                    textDocumentProxy.insertText(keyOutput)
                    return
                }
                
                textDocumentProxy.insertText(keyOutput)
                return
            }
            else {
                textDocumentProxy.insertText(keyOutput)
                return
            }
        }
        else {
            textDocumentProxy.insertText(keyOutput)
            return
        }
        
    }
    
    override func setupKeys() {
        super.setupKeys()
    }
    
    override func createBanner() -> ExtraView? {
        return CatboardBanner(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
    }
    
}
