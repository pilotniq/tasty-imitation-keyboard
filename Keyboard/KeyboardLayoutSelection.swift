//
//  KeyboardLayoutSelection.swift
//  TastyImitationKeyboard
//
//  Created by Simon Corston-Oliver on 29/12/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation

let kCompatibleLayouts = "Compatible Keyboard Layouts"

class KeyboardLayoutSelection: LightDarkView, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView?
    @IBOutlet var effectsView: UIVisualEffectView?
    @IBOutlet var backButton: UIButton?
    @IBOutlet var settingsLabel: UILabel?
    @IBOutlet var pixelLine: UIView?

    var currentLayout: String = ""
    var compatibleLayouts: [String] = []

    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool, currentLayout: String, compatibleLayouts: [String]) {
        self.currentLayout = currentLayout
        self.compatibleLayouts = compatibleLayouts

        super.init(darkMode: darkMode, solidColorMode: solidColorMode)
        self.loadNib()

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
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.compatibleLayouts.count
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return kCompatibleLayouts
    }

    func formatHeader(label: UILabel?) {
        let colorScheme = ColorScheme.ColorSchemeChooser(darkMode)
        label?.textColor = colorScheme.sectionLabelColor()
        label?.backgroundColor=colorScheme.sectionBackgroundColor()
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = kCompatibleLayouts

        formatHeader(label)

        return label
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let layout = compatibleLayouts[indexPath.row]
        let colorScheme = ColorScheme.ColorSchemeChooser(darkMode)

        return CheckedTableViewCell(layout: layout, isDefault: layout == self.currentLayout, colorScheme: colorScheme)


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
        self.tableView?.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 1)), withRowAnimation: UITableViewRowAnimation.Automatic)

        if let visibleCells = self.tableView?.visibleCells {
            for cell in visibleCells {
                (cell as? DefaultSettingsTableViewCell)?.applyColorScheme(colorScheme)
            }
        }

    }

    func initializeValues(currentLayout: String, compatibleLayouts: [String])
    {
        self.currentLayout = currentLayout
        self.compatibleLayouts = compatibleLayouts
    }

    func toggleSetting(sender: UISwitch) {
        if let cell = sender.superview as? UITableViewCell {
            if let indexPath = self.tableView?.indexPathForCell(cell) {
                //let descriptor = self.compatibleLayouts[indexPath.row]
                //let key = indexPath.section == LanguagesSection ? LanguageDefinitions.Singleton().DescriptiveNameForLangCode(descriptor) : descriptor
                
                //NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: key)
            }
        }
    }
}

class CheckedTableViewCell: UITableViewCell {

    var sw: UISwitch = UISwitch()
    var label: UILabel = UILabel(frame: CGRectZero)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(layout: String, isDefault: Bool, colorScheme: ColorScheme)
    {
        self.init(style: UITableViewCellStyle.Default, reuseIdentifier: nil)

        self.sw.on = true
        self.sw.hidden = !isDefault
        self.sw.translatesAutoresizingMaskIntoConstraints = false

        self.label.text = layout
        self.label.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraints()

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