//
//  ExtraView.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

class ExtraView: UIView {
    
    var globalColors: GlobalColors.Type?
    var darkMode: Bool {
        didSet {
            if oldValue != darkMode {
                updateAppearance()
            }
        }
    }
    
    var solidColorMode: Bool
	
	var btn1 : UIButton = UIButton()
	var btn2 : UIButton = UIButton()
	var btn3 : UIButton = UIButton()
	var btn4 : UIButton = UIButton()
	
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        self.globalColors = globalColors
        self.darkMode = darkMode
        self.solidColorMode = solidColorMode
        
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.globalColors = nil
        self.darkMode = false
        self.solidColorMode = false
        
        super.init(coder: aDecoder)
    }


    func updateAppearance() {
        for button in [btn1, btn2, btn3] {
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
