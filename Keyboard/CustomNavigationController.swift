//
//  CustomNavigationController.swift
//  TastyImitationKeyboard
//
//  Created by Simon Corston-Oliver on 3/01/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import Foundation

// Show a custom version of the UINavigationController that only appears when we're in the settings view controller
// but disappears when we're done and go back to the keyboard.

class CustomNavigationController : UINavigationController {

    var countViews: Int = 0

    // Something of a hack: we may have to totally redraw the keyboard when we dismiss the nav controller
    // e.g. if the user selected a different layout
    var parent: KeyboardViewController?

    override func pushViewController(viewController: UIViewController, animated: Bool) {
        countViews += 1

        super.pushViewController(viewController, animated: animated)
    }

    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {

        if countViews == 3 { // The nav bar itself + dummy VC (to force the back button) + settings VC

            countViews = 0
            super.popViewControllerAnimated(false)
            self.dismissViewControllerAnimated(false, completion: nil) // Nav bar goes away, revealing keyboard again
            self.parent?.ChangeKeyboardLanguage(CurrentLanguageCode()) // But no event triggers the keyboard redrawing e.g. to account for selecting a different layout; so explicitly redo the kbd

            return nil
        }
        else {
            countViews -= 1
            return super.popViewControllerAnimated(animated)
        }
    }

    // When we display the initial settings view controller the back button wouldn't appear with a normal nav controller
    // because it would be the topmost view. So fake out the widget by preloading a dummy view controller
    required init()
    {
        super.init(nibName: nil, bundle: nil)

        self.pushViewController(UIViewController(), animated: false)
    }

    convenience init (parent: KeyboardViewController)
    {
        self.init()
        self.parent = parent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}