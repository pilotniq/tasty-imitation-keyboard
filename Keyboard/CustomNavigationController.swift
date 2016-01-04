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

    override func pushViewController(viewController: UIViewController, animated: Bool) {
        countViews++

        super.pushViewController(viewController, animated: animated)
    }

    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {

        if countViews == 3 { // The nav bar itself + dummy VC (to force the back button) + settings VC

            countViews = 0
            super.popViewControllerAnimated(false)
            self.dismissViewControllerAnimated(false, completion: nil) // Nav bar goes away, revealing keyboard again

            return nil
        }
        else {
            countViews--
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}