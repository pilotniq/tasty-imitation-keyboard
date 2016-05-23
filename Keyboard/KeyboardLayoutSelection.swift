//
//  KeyboardLayoutSelection.swift
//  TastyImitationKeyboard
//
//  Created by Simon Corston-Oliver on 29/12/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation

let kCompatibleLayouts = "Compatible Keyboard Layouts"
let kCheckmarkCharacter = "\u{2713}" // Unicode character "CHECK MARK (U+2713)"

class CheckedTableViewCell: UITableViewCell {

    var checkMark: UILabel = UILabel(frame: CGRectZero)
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

        self.checkMark.text = isDefault ? kCheckmarkCharacter : ""
        self.checkMark.translatesAutoresizingMaskIntoConstraints = false

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
        self.addSubview(self.checkMark)
        self.addSubview(self.label)

        let views = ["label": self.label, "check" : self.checkMark]
        let metrics = ["pad" : 8.0]

        var allConstraints = [NSLayoutConstraint]()

        let topRowConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-pad-[label(>=150)]-[check]-pad-|",
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
            "V:|-pad-[check]",
            options: [],
            metrics: metrics,
            views:views)
        allConstraints += verticalConstraints2
        
        NSLayoutConstraint.activateConstraints(allConstraints)
    }
    
}