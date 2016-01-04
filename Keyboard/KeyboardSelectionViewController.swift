//
//  KeyboardSelectionViewController.swift
//  TastyImitationKeyboard
//
//  Created by Simon Corston-Oliver on 2/01/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import UIKit

let kChooseTitle = "Choose one of the following keyboards"

class KeyboardSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView = UITableView()
    private var _keyboardDefinitions : [String] = []
    private var _langCode = "EN"

        // TODO diff the keyboard against the current default for the language
    private var _currentLayout = "QWERTY"

    required init()
    {
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(keyboardDefinitions: [String], langCode: String)
    {
        self.init()

        self._currentLayout = getKeyboardLayoutNameForLanguageCode(langCode)

        self._keyboardDefinitions = keyboardDefinitions

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
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._keyboardDefinitions.count
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return kChooseTitle
    }

    func formatHeader(label: UILabel?) {
        let colorScheme = ColorScheme.ColorSchemeChooser(darkMode)
        label?.textColor = colorScheme.sectionLabelColor()
        label?.backgroundColor=colorScheme.sectionBackgroundColor()
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = kChooseTitle

        formatHeader(label)

        return label
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let keyboardName = self._keyboardDefinitions[indexPath.row]
        let colorScheme = ColorScheme.ColorSchemeChooser(darkMode)


        let cell = CheckedTableViewCell(layout: keyboardName, isDefault: keyboardName == self._currentLayout, colorScheme: colorScheme)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self._currentLayout = self._keyboardDefinitions[indexPath.row]
        setKeyboardLayoutNameForLanguageCode(self._langCode, layout: self._currentLayout)

        self.tableView.reloadData()
    }

}
