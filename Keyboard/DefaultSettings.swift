//
//  DefaultSettings.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 11/2/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

let LanguagesSection: Int = 2

class ColorScheme
{
    func labelTextColor() -> UIColor {
        return UIColor.grayColor()
    }

    func backTextColor() -> UIColor {
        return UIColor.blackColor()
            //UIColor(red: 0/CGFloat(255), green: 122/CGFloat(255), blue: 255/CGFloat(255), alpha: 1)
    }

    func cellBackgroundColor() -> UIColor {
        return UIColor.whiteColor().colorWithAlphaComponent(CGFloat(0.25))
    }

    func cellLabelColor() -> UIColor {
        return UIColor.blackColor()
    }

    func cellLongLabelColor() -> UIColor {
        return UIColor.grayColor()
    }

    func cellKbdChangerColor() -> UIColor {
        return UIColor.greenColor()
    }


    func tableBackgroundColor() -> UIColor {
        return UIColor.whiteColor().colorWithAlphaComponent(1.0)
    }

    func sectionLabelColor() -> UIColor {
        return UIColor.blackColor()
    }

    func sectionBackgroundColor() -> UIColor {
        return UIColor.whiteColor()
    }

    func settingsBackgroundColor() -> UIColor {
        return UIColor.whiteColor()
    }

    func backButtonBackgroundColor() -> UIColor {
        return UIColor.whiteColor()
    }

    func effectsBackgroundColor() -> UIColor {
        return UIColor.whiteColor().colorWithAlphaComponent(1)
    }

    class func ColorSchemeChooser (darkMode : Bool) -> ColorScheme
    {
        return darkMode ? DarkColorScheme() : ColorScheme()
    }
}

class DarkColorScheme: ColorScheme
{
    override func labelTextColor() -> UIColor {
        return UIColor.whiteColor()
    }

    override func backTextColor() -> UIColor {
        return UIColor.whiteColor()
//        return UIColor(red: 135/CGFloat(255), green: 206/CGFloat(255), blue: 250/CGFloat(255), alpha: 1)
    }

    override func cellBackgroundColor() -> UIColor {
        return UIColor.darkGrayColor().colorWithAlphaComponent(CGFloat(0.5))
    }

    override func cellLabelColor() -> UIColor {
        return UIColor.whiteColor()
    }

    override func tableBackgroundColor() -> UIColor {
        return UIColor.grayColor().colorWithAlphaComponent(1.0)
    }

    override func sectionLabelColor() -> UIColor {
        return UIColor.whiteColor()
    }

    override func sectionBackgroundColor() -> UIColor {
        return UIColor.darkGrayColor().colorWithAlphaComponent(CGFloat(0.5))
    }

    override func settingsBackgroundColor() -> UIColor {
        return UIColor.darkGrayColor().colorWithAlphaComponent(CGFloat(0.5))
    }

    override func effectsBackgroundColor() -> UIColor {
        return UIColor.darkGrayColor().colorWithAlphaComponent(1)
    }

    override func backButtonBackgroundColor() -> UIColor {
        return settingsBackgroundColor()
    }

    override func cellLongLabelColor() -> UIColor {
        return UIColor.whiteColor()
    }

    override func cellKbdChangerColor() -> UIColor {
        return UIColor.whiteColor()
    }


}
