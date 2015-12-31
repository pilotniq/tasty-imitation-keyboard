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

class DefaultSettings: LightDarkView, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView?
    @IBOutlet var effectsView: UIVisualEffectView?
    @IBOutlet var backButton: UIButton?
    @IBOutlet var settingsLabel: UILabel?
    @IBOutlet var pixelLine: UIView?

    private var _languageDefinitions : LanguageDefinitions?

    var settingsList: [(String, [String])] = [
        ("General Settings", [kAutoCapitalization, kPeriodShortcut, kKeyboardClicks]),
        ("Extra Settings", [kSmallLowercase]),
        ("Languages", ["English"])
    ]

    var settingsNames: [String:String] {
        get {
            return [
                kAutoCapitalization: "Auto-Capitalization",
                kPeriodShortcut:  "“.” Shortcut",
                kKeyboardClicks: "Keyboard Clicks",
                kSmallLowercase: "Allow Lowercase Key Caps"
            ]
        }
    }

    var settingsNotes: [String: String] {
        get {
                return [
                    kSmallLowercase: "Changes your key caps to lowercase when Shift is off, making it easier to tell what mode you are in."
                ]
        }
    }

    required init(darkMode: Bool, solidColorMode: Bool, languageDefinitions: LanguageDefinitions) {
        super.init(darkMode: darkMode, solidColorMode: solidColorMode)
        self.loadNib()
        self._languageDefinitions = languageDefinitions

        if self._languageDefinitions != nil {
            settingsList[LanguagesSection] = ("Languages", (self._languageDefinitions?.LangCodes())!)
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("loading from nib not supported")
    }

    required init(darkMode: Bool, solidColorMode: Bool) {
        fatalError("init(darkMode:solidColorMode:) has not been implemented")
    }

    func loadNib() {
        let assets = NSBundle(forClass: self.dynamicType).loadNibNamed("DefaultSettings", owner: self, options: nil)

        if assets.count > 0 {
            if let rootView = assets.first as? UIView {
                rootView.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(rootView)

                let left = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
                let right = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
                let top = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
                let bottom = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)

                self.addConstraint(left)
                self.addConstraint(right)
                self.addConstraint(top)
                self.addConstraint(bottom)
            }
        }

        //self.tableView?.registerClass(DefaultSettingsTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView?.estimatedRowHeight = 44;
        self.tableView?.rowHeight = UITableViewAutomaticDimension;

        // We display the options on top of the kbd. Make certain we can't see any of the underlying buttons etc.
        self.tableView?.backgroundColor = ColorScheme.ColorSchemeChooser(darkMode).tableBackgroundColor()

        self.updateAppearance()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.settingsList.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsList[section].1.count
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.settingsList[section].0
    }

    func formatHeader(label: UILabel?) {
        let colorScheme = ColorScheme.ColorSchemeChooser(darkMode)
        label?.textColor = colorScheme.sectionLabelColor()
        label?.backgroundColor=colorScheme.sectionBackgroundColor()
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = self.settingsList[section].0

        formatHeader(label)

        return label
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let key = self.settingsList[indexPath.section].1[indexPath.row]
        let colorScheme = ColorScheme.ColorSchemeChooser(darkMode)

        if indexPath.section == LanguagesSection {
            let descriptiveName = LanguageDefinitions.Singleton().DescriptiveNameForLangCode(key)

            let cell = LanguageSettingsCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            cell.initializeValues(descriptiveName, langCode: key, colorScheme: colorScheme)

            return cell
        }
        else if let explanatoryText = self.settingsNotes[key] {
            let cell = OptionWithDescription(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            cell.initializeValues(key,
                label: self.settingsNames[key] ?? key,
                description: explanatoryText,
                colorScheme: colorScheme)

            return cell
        }
        else {
            let cell = DefaultSettingsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            cell.initializeValues(key,
                label: self.settingsNames[key] ?? key,
                colorScheme: colorScheme)

            return cell
        }

    }

    override func updateAppearance() {
        super.updateAppearance()

        let colorScheme = ColorScheme.ColorSchemeChooser(darkMode)

        let defaultColor = colorScheme.backTextColor()
        self.pixelLine?.backgroundColor = defaultColor.colorWithAlphaComponent(CGFloat(0.5))

        self.backButton?.setTitleColor(defaultColor, forState: UIControlState.Normal)

        self.settingsLabel?.textColor = colorScheme.labelTextColor()

        self.effectsView?.backgroundColor = colorScheme.effectsBackgroundColor()

        // We have to explicitly redraw the section headings or they stay the same color if the user
        // flips between dark mode and light mode.
        self.tableView?.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, settingsList.count)), withRowAnimation: UITableViewRowAnimation.Automatic)

        if let visibleCells = self.tableView?.visibleCells {
            for cell in visibleCells {
                (cell as? DefaultSettingsTableViewCell)?.applyColorScheme(colorScheme)
            }
        }

    }

    func toggleSetting(sender: UISwitch) {
        if let cell = sender.superview as? UITableViewCell {
            if let indexPath = self.tableView?.indexPathForCell(cell) {
                let descriptor = self.settingsList[indexPath.section].1[indexPath.row]
                let key = indexPath.section == LanguagesSection ? LanguageDefinitions.Singleton().DescriptiveNameForLangCode(descriptor) : descriptor
                
                NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: key)
            }
        }
    }
}

// The settings form has a list of options. The cells in the list are implemented using a simple class hierarchy.
// DefaultSettingsTableViewCell     All options have at least a title and a switch to toggle them on and off.
// OptionWithDescription            Same as above but with added explanatory text
// LanguageSettingsCell             Options for enabling a language and choosing a keyboard layout for the language.

class DefaultSettingsTableViewCell: UITableViewCell {

    var sw: UISwitch
    var label: UILabel

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.sw = UISwitch()
        self.label = UILabel(frame: CGRectZero)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.sw.translatesAutoresizingMaskIntoConstraints = false
        self.label.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initializeValues(setting: String, label: String, colorScheme: ColorScheme)
    {
        self.sw.on = NSUserDefaults.standardUserDefaults().boolForKey(setting)
        self.label.text = label

        self.applyColorScheme(colorScheme)
    }

    func applyColorScheme(colorScheme: ColorScheme)
    {
        self.backgroundColor = colorScheme.cellBackgroundColor()
        self.label.textColor = colorScheme.cellLabelColor()

    }

    func addConstraints() {
        self.addSubview(self.sw)
        self.addSubview(self.label)

        let views = ["label": self.label, "sw" : self.sw]
        let metrics = ["pad" : 8.0, "widePad" : 16.0]

        var allConstraints = [NSLayoutConstraint]()

        let topRowConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
        "H:|-pad-[label(>=150)]-[sw]-pad-|",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += topRowConstraints

        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-pad-[label]",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += verticalConstraints

        let verticalConstraints2 = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-pad-[sw]",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += verticalConstraints2

        NSLayoutConstraint.activateConstraints(allConstraints)
    }

}

class OptionWithDescription : DefaultSettingsTableViewCell
{
    var longLabel: UITextView

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.longLabel = MakeUITextView()

        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initializeValues(setting: String, label: String, description: String, colorScheme: ColorScheme)
    {
        self.longLabel.text = description
        super.initializeValues(setting, label: label, colorScheme: colorScheme)
    }

    override func applyColorScheme(colorScheme: ColorScheme)
    {
        super.applyColorScheme(colorScheme)

        self.longLabel.textColor = colorScheme.cellLongLabelColor()
    }

    override func addConstraints() {
        self.addSubview(self.sw)
        self.addSubview(self.label)
        self.addSubview(self.longLabel)

        self.addSubview(self.longLabel)

        let views = ["label": self.label, "longLabel": self.longLabel, "sw" : self.sw]
        let metrics = ["pad" : 8.0, "widePad" : 16.0]

        var allConstraints = [NSLayoutConstraint]()

        let topRowConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-pad-[label(>=150)]-[sw]-pad-|",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += topRowConstraints

        let secondRowConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-widePad-[longLabel]-widePad-|",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += secondRowConstraints

        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-pad-[label]-pad-[longLabel]-pad-|",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += verticalConstraints

        let verticalConstraints3 = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-pad-[sw]",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += verticalConstraints3

        NSLayoutConstraint.activateConstraints(allConstraints)
    }
}


class LanguageSettingsCell : DefaultSettingsTableViewCell
{
    var kbdChanger: UITextView
    var kbdName: UITextView
    var kbdLayoutChooserView: KeyboardLayoutSelection? = nil

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        self.kbdName = MakeUITextView()
        self.kbdChanger = MakeUITextView()

        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    func initializeValues(descriptiveName: String, langCode: String, colorScheme: ColorScheme)
    {
        self.sw.on = NSUserDefaults.standardUserDefaults().boolForKey(descriptiveName)
        self.label.text = descriptiveName
        self.kbdName.text = LanguageDefinitions.Singleton().KeyboardFileForLanguageCode(langCode)

        self.kbdChanger.text = "Change..."
        self.kbdChanger.userInteractionEnabled = true

        let recognizer = UITapGestureRecognizer(target: self, action: "goclick:")
        recognizer.delegate = self

        self.kbdChanger.addGestureRecognizer(recognizer)
//        self.kbdChanger.addTarget(self, action: "goclick:", forControlEvents: .TouchDown)

        self.applyColorScheme(colorScheme)
    }

    @objc func goclick(recognizer: UITapGestureRecognizer)
    {
        NSLog("Hello world")
        toggleKeyboardLayoutForm()
    }

    func toggleKeyboardLayoutForm()
    {
        // lazy load settings
        if self.kbdLayoutChooserView == nil {

            self.kbdLayoutChooserView = KeyboardLayoutSelection(globalColors: GlobalColors.self, darkMode: false, solidColorMode: false, currentLayout: self.kbdName.text, compatibleLayouts: ["QWERTY", "AZERTY", "QWERTZ", "DVORAK"])

            if let chooserView = self.kbdLayoutChooserView {

                self.addSubview(self.kbdLayoutChooserView!)


                chooserView.translatesAutoresizingMaskIntoConstraints = false

                let widthConstraint = NSLayoutConstraint(item: chooserView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
                let heightConstraint = NSLayoutConstraint(item: chooserView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
                let centerXConstraint = NSLayoutConstraint(item: chooserView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
                let centerYConstraint = NSLayoutConstraint(item: chooserView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)

                self.addConstraint(widthConstraint)
                self.addConstraint(heightConstraint)
                self.addConstraint(centerXConstraint)
                self.addConstraint(centerYConstraint)

                self.hidden = true
            }

        }
        else {
            self.kbdLayoutChooserView?.hidden = true
            self.kbdLayoutChooserView?.removeFromSuperview()
            self.kbdLayoutChooserView = nil
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyColorScheme(colorScheme: ColorScheme)
    {
        super.applyColorScheme(colorScheme)

        self.kbdChanger.textColor = colorScheme.cellKbdChangerColor()
    }

    override func addConstraints() {
        self.addSubview(self.sw)
        self.addSubview(self.label)
        self.addSubview(self.kbdName)

        self.addSubview(self.kbdChanger)

        let views = ["label": self.label, "kbdName": self.kbdName, "sw" : self.sw, "kbdChanger": self.kbdChanger]
        let metrics = ["pad" : 8.0, "widePad" : 16.0]

        var allConstraints = [NSLayoutConstraint]()

        let topRowConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-pad-[label(>=150)]-[sw]-pad-|",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += topRowConstraints


        let secondRowConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-pad-[kbdName(>=10)]-pad-[kbdChanger]",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += secondRowConstraints

        let verticalConstraints2 = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-pad-[label]-pad-[kbdChanger]-pad-|",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += verticalConstraints2

        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-pad-[label]-pad-[kbdName]-pad-|",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += verticalConstraints

        let verticalConstraints3 = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-pad-[sw]",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += verticalConstraints3

        NSLayoutConstraint.activateConstraints(allConstraints)
    }

}

func MakeUITextView() -> UITextView
{
    let view = UITextView(frame: CGRectZero)
    view.text = nil
    view.backgroundColor = UIColor.clearColor()
    view.scrollEnabled = false
    view.selectable = false
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
}


