//
//  LanguageSettingsViewController.swift
//  TastyImitationKeyboard
//
//  Created by Simon Corston-Oliver on 2/01/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import UIKit

let darkMode = false
let kUnknownLookupKey = "UNKNOWN"

class LanguageSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableView = UITableView()
    private var _languageDefinitions : LanguageDefinitions? = nil
    private var _navController: CustomNavigationController? = nil

    required init()
    {
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(languageDefinitions: LanguageDefinitions, navController: CustomNavigationController?)
    {
        self.init()

        self._navController = navController

        self._languageDefinitions = languageDefinitions
        if self._languageDefinitions != nil {
            settingsList[LanguagesSection] = ("Languages", (self._languageDefinitions?.LangCodes())!)
        }

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.frame = self.view.frame
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.view.addSubview(self.tableView)

        self.addConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("loading from nib not supported")
    }

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

    func addConstraints() {
        let views = ["tableView" : self.tableView]
        let metrics = ["pad" : 1]

        var allConstraints = [NSLayoutConstraint]()

        let topRowConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-pad-[tableView]-pad-|",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += topRowConstraints

        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[tableView]|",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += verticalConstraints

        NSLayoutConstraint.activateConstraints(allConstraints)
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.settingsList.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsList[section].1.count
    }

    func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        switch indexPath.section {
        case 0:
            return 40
        case 1:
            return 75
        default:
            return 60
        }
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
        label.text = self.settingsList[section].0.uppercaseString

        formatHeader(label)

        return label
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let key = self.settingsList[indexPath.section].1[indexPath.row]
        let colorScheme = ColorScheme.ColorSchemeChooser(darkMode)

        if indexPath.section == LanguagesSection {
            let descriptiveName = LanguageDefinitions.Singleton().DescriptiveNameForLangCode(key)

            let cell = LanguageSettingsCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            cell.initializeValues(descriptiveName, langCode: key, colorScheme: colorScheme, parentViewController: self)

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

    func switchToKeyboardSelectionViewController(recognizer: UITapGestureRecognizer, langCode: String) {

        let vc = KeyboardSelectionViewController(keyboardDefinitions: ["QWERTY", "AZERTY", "QWERTZ"], langCode: langCode)

        self._navController?.pushViewController(vc, animated: true)
    }

    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    func updateAppearance() {
        //super.updateAppearance()

        let colorScheme = ColorScheme.ColorSchemeChooser(darkMode)

        // We have to explicitly redraw the section headings or they stay the same color if the user
        // flips between dark mode and light mode.
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, settingsList.count)), withRowAnimation: UITableViewRowAnimation.Automatic)

            for cell in self.tableView.visibleCells {
                (cell as? DefaultSettingsTableViewCell)?.applyColorScheme(colorScheme)
            }

    }

    func toggleSetting(sender: UISwitch) {
        if let cell = sender.superview as? UITableViewCell {
            if let indexPath = self.tableView.indexPathForCell(cell) {
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
    var settingLookupKey: String

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.sw = UISwitch()
        self.label = UILabel(frame: CGRectZero)
        self.settingLookupKey = kUnknownLookupKey

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.sw.translatesAutoresizingMaskIntoConstraints = false
        self.label.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initializeValues(setting: String, label: String, colorScheme: ColorScheme)
    {
        self.settingLookupKey = setting
        self.sw.on = NSUserDefaults.standardUserDefaults().boolForKey(setting)
        self.sw.addTarget(self, action: Selector("toggleSetting:"), forControlEvents: UIControlEvents.ValueChanged)

        self.label.text = label

        self.applyColorScheme(colorScheme)
        self.addConstraints()
    }

    func toggleSetting(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: self.settingLookupKey)
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
        let metrics = ["pad" : 3.0]

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
        let metrics = ["pad" : 3.0, "widePad" : 16.0]

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
    var parentViewController: LanguageSettingsViewController? = nil
    var langCode : String = "EN"

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.kbdName = MakeUITextView()
        self.kbdChanger = MakeUITextView()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }

    func initializeValues(descriptiveName: String, langCode: String, colorScheme: ColorScheme, parentViewController: LanguageSettingsViewController)
    {
        self.langCode = langCode

        self.parentViewController = parentViewController

        self.sw.on = getLanguageCodeEnabled(langCode)
        self.sw.addTarget(self, action: Selector("toggleSetting:"), forControlEvents: UIControlEvents.ValueChanged)

        self.label.text = descriptiveName
        self.kbdName.text = getKeyboardLayoutNameForLanguageCode(self.langCode)

        self.kbdChanger.text = "Change..."
        self.kbdChanger.userInteractionEnabled = true

        let recognizer = UITapGestureRecognizer(target: self, action: "goclick:")
        recognizer.delegate = self

        self.kbdChanger.addGestureRecognizer(recognizer)

        self.applyColorScheme(colorScheme)
        self.addConstraints()
    }

    @objc func goclick(recognizer: UITapGestureRecognizer)
    {
        self.parentViewController?.switchToKeyboardSelectionViewController(recognizer, langCode: self.langCode)
    }

    override func toggleSetting(sender: UISwitch) {
        setLanguageCodeEnabled(self.langCode, value: sender.on)
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
        let metrics = ["pad" : 3.0, "verticalpad": 1.0]

        var allConstraints = [NSLayoutConstraint]()

        let topRowConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-pad-[label(>=100)]-[sw]-pad-|",
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
            "V:|-pad-[label]-verticalpad-[kbdChanger]-pad-|",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += verticalConstraints2

        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-pad-[label]-verticalpad-[kbdName]-pad-|",
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



