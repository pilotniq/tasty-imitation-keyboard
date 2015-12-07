//
//  DefaultSettings.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 11/2/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

let SwitchTag = 1
let LabelTag = 2
let LongLabelTag = 3

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

    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool, languageDefinitions: LanguageDefinitions) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        self.loadNib()
        self._languageDefinitions = languageDefinitions

        if self._languageDefinitions != nil {
            for i in 0..<settingsList.count
            {
                if settingsList[i].0 == "Languages" {
                    settingsList[i] = ("Languages", (self._languageDefinitions?.LanguageNames())!)
                }
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("loading from nib not supported")
    }

    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        fatalError("init(globalColors:darkMode:solidColorMode:) has not been implemented")
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

        self.tableView?.registerClass(DefaultSettingsTableViewCell.self, forCellReuseIdentifier: "cell")
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
        if let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? DefaultSettingsTableViewCell {
            let key = self.settingsList[indexPath.section].1[indexPath.row]

            if cell.sw.allTargets().count == 0 {
                cell.sw.addTarget(self, action: Selector("toggleSetting:"), forControlEvents: UIControlEvents.ValueChanged)
            }

            cell.sw.on = NSUserDefaults.standardUserDefaults().boolForKey(key)
            cell.label.text = self.settingsNames[key] ?? key
            cell.longLabel.text = self.settingsNotes[key]

            let colorScheme = ColorScheme.ColorSchemeChooser(darkMode)

            cell.backgroundColor = colorScheme.cellBackgroundColor()
            cell.label.textColor = colorScheme.cellLabelColor()
            cell.longLabel.textColor = colorScheme.cellLongLabelColor()

            cell.changeConstraints()

            return cell
        }
        else {
            assert(false, "this is a bad thing that just happened")
            return UITableViewCell()
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

                cell.backgroundColor = colorScheme.cellBackgroundColor()
                let label = cell.viewWithTag(LabelTag) as? UILabel
                label?.textColor = colorScheme.cellLabelColor()
                let longLabel = cell.viewWithTag(LongLabelTag) as? UITextView
                longLabel?.textColor = colorScheme.cellLongLabelColor()

            }
        }

    }

    func toggleSetting(sender: UISwitch) {
        if let cell = sender.superview as? UITableViewCell {
            if let indexPath = self.tableView?.indexPathForCell(cell) {
                let key = self.settingsList[indexPath.section].1[indexPath.row]
                NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: key)
            }
        }
    }
}

class DefaultSettingsTableViewCell: UITableViewCell {

    var sw: UISwitch
    var label: UILabel
    var longLabel: UITextView
    var constraintsSetForLongLabel: Bool
    var cellConstraints: [NSLayoutConstraint]

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.sw = UISwitch()
        self.label = UILabel()
        self.longLabel = UITextView()
        self.cellConstraints = []

        self.constraintsSetForLongLabel = false

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.sw.translatesAutoresizingMaskIntoConstraints = false
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.longLabel.translatesAutoresizingMaskIntoConstraints = false

        self.longLabel.text = nil
        self.longLabel.scrollEnabled = false
        self.longLabel.selectable = false
        self.longLabel.backgroundColor = UIColor.clearColor()

        self.sw.tag = SwitchTag
        self.label.tag = LabelTag
        self.longLabel.tag = LongLabelTag

        self.addSubview(self.sw)
        self.addSubview(self.label)
        self.addSubview(self.longLabel)

        self.addConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addConstraints() {
        let margin: CGFloat = 8
        let sideMargin = margin * 2

        let hasLongText = self.longLabel.text != nil && !self.longLabel.text.isEmpty
        if hasLongText {
            let switchSide = NSLayoutConstraint(item: sw, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -sideMargin)
            let switchTop = NSLayoutConstraint(item: sw, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: margin)
            let labelSide = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: sideMargin)
            let labelCenter = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: sw, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)

            self.addConstraint(switchSide)
            self.addConstraint(switchTop)
            self.addConstraint(labelSide)
            self.addConstraint(labelCenter)

            let left = NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: sideMargin)
            let right = NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -sideMargin)
            let top = NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: sw, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: margin)
            let bottom = NSLayoutConstraint(item: longLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -margin)

            self.addConstraint(left)
            self.addConstraint(right)
            self.addConstraint(top)
            self.addConstraint(bottom)

            self.cellConstraints += [switchSide, switchTop, labelSide, labelCenter, left, right, top, bottom]

            self.constraintsSetForLongLabel = true
        }
        else {
            let switchSide = NSLayoutConstraint(item: sw, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -sideMargin)
            let switchTop = NSLayoutConstraint(item: sw, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: margin)
            let switchBottom = NSLayoutConstraint(item: sw, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -margin)
            let labelSide = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: sideMargin)
            let labelCenter = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: sw, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)

            self.addConstraint(switchSide)
            self.addConstraint(switchTop)
            self.addConstraint(switchBottom)
            self.addConstraint(labelSide)
            self.addConstraint(labelCenter)

            self.cellConstraints += [switchSide, switchTop, switchBottom, labelSide, labelCenter]

            self.constraintsSetForLongLabel = false
        }
    }

    // XXX: not in updateConstraints because it doesn't play nice with UITableViewAutomaticDimension for some reason
    func changeConstraints() {
        let hasLongText = self.longLabel.text != nil && !self.longLabel.text.isEmpty
        if hasLongText != self.constraintsSetForLongLabel {
            self.removeConstraints(self.cellConstraints)
            self.cellConstraints.removeAll()
            self.addConstraints()
        }
    }
}
