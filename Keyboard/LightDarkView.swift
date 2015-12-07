//
//  LightDarkView.swift
// Base class that knows about dark mode vs. light mode

import UIKit

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

