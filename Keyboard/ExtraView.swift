//
//  ExtraView.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

// Base class that knows about dark mode vs. light mode
class LightDarkView: UIView {
    
    var globalColors: GlobalColors.Type?
    var darkMode: Bool {
        didSet {
            if oldValue != darkMode {
                updateAppearance()
            }
        }
    }
    
    var solidColorMode: Bool

    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        self.globalColors = globalColors
        self.darkMode = darkMode
        self.solidColorMode = solidColorMode

        super.init(frame: CGRectZero)

        self.hidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.globalColors = nil
        self.darkMode = false
        self.solidColorMode = false
        
        super.init(coder: aDecoder)

        self.hidden = true
    }


    func updateAppearance() {
    }

}

// The view to house the row of suggestion buttons across the top of the keyboard
class SuggestionView: LightDarkView  {

    var btn1 : UIButton = UIButton()
    var btn2 : UIButton = UIButton()
    var btn3 : UIButton = UIButton()
    var btn4 : UIButton = UIButton()

    var buttons: [UIButton] {
        get {
            return [self.btn1, self.btn2, self.btn3]
        }
    }

    override func updateAppearance() {
        for button in self.buttons {
            showUnpressedAppearance(button)
        }
    }

    let bluishGray = UIColor(red:0.68, green:0.71, blue:0.74, alpha:1)
    let whitish = UIColor(red:0.92, green:0.93, blue:0.94, alpha:1)

    func showPressedAppearance(button: UIButton)
    {
        button.backgroundColor = whitish
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
    }

    func showUnpressedAppearance(button: UIButton)
    {
        button.backgroundColor = bluishGray
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
}
