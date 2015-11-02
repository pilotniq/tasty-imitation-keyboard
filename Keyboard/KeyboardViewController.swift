//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit
import AudioToolbox

enum TTDeviceType{
	case TTDeviceTypeIPhone4
	case TTDeviceTypeIPhone5
	case TTDeviceTypeIPhone6
	case TTDeviceTypeIPhone6p
	
}

var deviceType = TTDeviceType.TTDeviceTypeIPhone5

let metrics: [String:Double] = [
    "topBanner": 30
]
func metric(name: String) -> CGFloat { return CGFloat(metrics[name]!) }

// TODO: move this somewhere else and localize
let kAutoCapitalization = "kAutoCapitalization"
let kPeriodShortcut = "kPeriodShortcut"
let kKeyboardClicks = "kKeyboardClicks"
let kSmallLowercase = "kSmallLowercase"

class KeyboardViewController: UIInputViewController {
    
    let backspaceDelay: NSTimeInterval = 0.5
    let backspaceRepeat: NSTimeInterval = 0.07
    
    var keyboard: Keyboard!
    var forwardingView: ForwardingView!
    var layout: KeyboardLayout?
    var heightConstraint: NSLayoutConstraint?
    
    var bannerView: ExtraView?
    var settingsView: ExtraView?
    
    var currentMode: Int {
        didSet {
            if oldValue != currentMode {
                setMode(currentMode)
            }
			
			forwardingView.currentMode = currentMode
			forwardingView.keyboard_type = keyboard_type
        }
    }
	
    var backspaceActive: Bool {
        get {
            return (backspaceDelayTimer != nil) || (backspaceRepeatTimer != nil)
        }
    }
    var backspaceDelayTimer: NSTimer?
    var backspaceRepeatTimer: NSTimer?
    
    enum AutoPeriodState {
        case NoSpace
        case FirstSpace
    }
    
    var autoPeriodState: AutoPeriodState = .NoSpace
    var lastCharCountInBeforeContext: Int = 0
    
    var shiftState: ShiftState {
        didSet {
            self.updateKeyCaps(shiftState != .Disabled)
        }
    }
    
    // state tracking during shift tap
    var shiftWasMultitapped: Bool = false
    var shiftStartingState: ShiftState?
    
    var keyboardHeight: CGFloat {
        get {
            if let constraint = self.heightConstraint {
                return constraint.constant
            }
            else {
                return 0
            }
        }
        set {
            self.setHeight(newValue)
        }
    }
	
	//MARK:- Extra variables for extra features
	var sug_word : String = ""
	
	var viewLongPopUp:CYRKeyboardButtonView = CYRKeyboardButtonView()
	var button = CYRKeyboardButton()
	
	var isAllowFullAccess : Bool = false
	
	var keyboard_type: UIKeyboardType!
	var preKeyboardType = UIKeyboardType.Default
	
    // TODO: why does the app crash if this isn't here?
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    // HACKHACK
    // Since UIApplication.sharedApplication().statusBarOrientation has been deprecated.
    // For now assume interfaceOrientation and device orientation are the same thing.
    // Couldn't get UIDevice.currentDevice().orientation to work even if I wrapped with begin/endGeneratingDeviceOrientationNotifications
    class func getInterfaceOrientation() -> UIInterfaceOrientation
    {
        let screenSize : CGSize = UIScreen.mainScreen().bounds.size
        return screenSize.width < screenSize.height ? UIInterfaceOrientation.Portrait : UIInterfaceOrientation.LandscapeLeft
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        NSUserDefaults.standardUserDefaults().registerDefaults([
            kAutoCapitalization: true,
            kPeriodShortcut: true,
            kKeyboardClicks: false,
            kSmallLowercase: false
        ])
        
        self.shiftState = .Disabled
        self.currentMode = 0
        
        self.currentInterfaceOrientation = KeyboardViewController.getInterfaceOrientation()

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
		self.forwardingView = ForwardingView(frame: CGRectZero)
		self.view.addSubview(self.forwardingView)
		
        if let aBanner = self.createBanner() {
            for button in [aBanner.btn1, aBanner.btn2, aBanner.btn3] {
                button.addTarget(self, action: "didTapSuggestionButton:", forControlEvents: [.TouchUpInside, .TouchUpOutside, .TouchDragOutside])
                button.addTarget(self, action: "didTTouchDownSuggestionButton:", forControlEvents: [.TouchDown, .TouchDragInside, .TouchDragEnter])
                button.addTarget(self, action: "didTTouchExitDownSuggestionButton:", forControlEvents: [.TouchDragExit, .TouchCancel])
            }
			
			aBanner.hidden = true
			self.view.insertSubview(aBanner, aboveSubview: self.forwardingView)
			self.bannerView = aBanner
		}
		
		initializePopUp()
		
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("defaultsChanged:"), name: NSUserDefaultsDidChangeNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("hideExpandView:"), name: "hideExpandViewNotification", object: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        backspaceDelayTimer?.invalidate()
        backspaceRepeatTimer?.invalidate()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func defaultsChanged(notification: NSNotification) {
        //_ = notification.object as? NSUserDefaults
        self.updateKeyCaps(self.shiftState.uppercase())
    }
    
    // without this here kludge, the height constraint for the keyboard does not work for some reason
    var kludge: UIView?
    func setupKludge() {
        if self.kludge == nil {
            let kludge = UIView()
            self.view.addSubview(kludge)
            kludge.translatesAutoresizingMaskIntoConstraints = false
            kludge.hidden = true
            
            let a = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            let b = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            let c = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            let d = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            self.view.addConstraints([a, b, c, d])
            
            self.kludge = kludge
        }
    }
    
    /*
    BUG NOTE

    For some strange reason, a layout pass of the entire keyboard is triggered 
    whenever a popup shows up, if one of the following is done:

    a) The forwarding view uses an autoresizing mask.
    b) The forwarding view has constraints set anywhere other than init.

    On the other hand, setting (non-autoresizing) constraints or just setting the
    frame in layoutSubviews works perfectly fine.

    I don't really know what to make of this. Am I doing Autolayout wrong, is it
    a bug, or is it expected behavior? Perhaps this has to do with the fact that
    the view's frame is only ever explicitly modified when set directly in layoutSubviews,
    and not implicitly modified by various Autolayout constraints
    (even though it should really not be changing).
    */
    
    var constraintsAdded: Bool = false
    func setupLayout() {
        if !constraintsAdded {
			
			let proxy = textDocumentProxy 
			self.keyboard = defaultKeyboard(proxy.keyboardType!)
			
			preKeyboardType = proxy.keyboardType!
			
			
			
            self.layout = self.dynamicType.layoutClass.init(model: self.keyboard, superview: self.forwardingView, layoutConstants: self.dynamicType.layoutConstants, globalColors: self.dynamicType.globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode())
            
            self.layout?.initialize()
            self.setMode(0)
            
            self.setupKludge()
            
            self.updateKeyCaps(self.shiftState.uppercase())
            self.setCapsIfNeeded()
            
            self.updateAppearances(self.darkMode())
            self.addInputTraitsObservers()
            
            self.constraintsAdded = true
        }
    }
    
    // only available after frame becomes non-zero
    func darkMode() -> Bool {
        let darkMode = { () -> Bool in
                return self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearance.Dark
        }()
        
        return darkMode
    }
    
    func solidColorMode() -> Bool {
        return UIAccessibilityIsReduceTransparencyEnabled()
    }
    
    var lastLayoutBounds: CGRect?
	override func viewDidLayoutSubviews() {
		if view.bounds == CGRectZero {
			return
		}
		
		self.setupLayout()
        
		let orientationSavvyBounds = CGRectMake(0, 0, self.view.bounds.width, self.heightForOrientation(self.currentInterfaceOrientation, withTopBanner: false))
		
		if (lastLayoutBounds != nil && lastLayoutBounds == orientationSavvyBounds) {
			// do nothing
		}
		else {
            let uppercase = self.shiftState.uppercase()
			let characterUppercase = (NSUserDefaults.standardUserDefaults().boolForKey(kSmallLowercase) ? uppercase : true)
			
			self.forwardingView.frame = orientationSavvyBounds
			self.layout?.layoutKeys(self.currentMode, uppercase: uppercase, characterUppercase: characterUppercase, shiftState: self.shiftState)
			self.lastLayoutBounds = orientationSavvyBounds
			self.setupKeys()
		}
		
		self.bannerView?.frame = CGRectMake(0, 0, self.view.bounds.width, metric("topBanner"))
		
		let proxy = textDocumentProxy
		
		self.bannerView!.hidden = proxy.keyboardType == UIKeyboardType.NumberPad || proxy.keyboardType == UIKeyboardType.DecimalPad
		
		let newOrigin = CGPointMake(0, self.view.bounds.height - self.forwardingView.bounds.height)
		self.forwardingView.frame.origin = newOrigin
		
	}
	
    override func loadView() {
        super.loadView()
		
        if let aBanner = self.createBanner() {
            aBanner.hidden = true
            self.view.insertSubview(aBanner, belowSubview: self.forwardingView)
            self.bannerView = aBanner
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.bannerView?.hidden = false
        self.keyboardHeight = self.heightForOrientation(self.currentInterfaceOrientation, withTopBanner: true)
    }
	
    var currentInterfaceOrientation : UIInterfaceOrientation
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.forwardingView.resetTrackedViews()
        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        // optimization: ensures smooth animation
        if let keyPool = self.layout?.keyPool {
            for view in keyPool {
                view.shouldRasterize = true
            }
        }
        
        self.keyboardHeight = self.heightForOrientation(toInterfaceOrientation, withTopBanner: true)
        self.currentInterfaceOrientation = toInterfaceOrientation
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        // optimization: ensures quick mode and shift transitions
        if let keyPool = self.layout?.keyPool {
            for view in keyPool {
                view.shouldRasterize = false
            }
        }
    }
	
	func isCapitalalize(string: String) -> Bool
	{
		if string.characters.count > 0
		{
            
			let firstChar = string[string.startIndex]
            return ("A"..."Z").contains(firstChar)
		}
		else
		{
			return false
		}
		
	}

    func CasedString(str : String, shiftState : ShiftState) -> String
    {
        if shiftState == .Enabled
        {
            return str.capitalizedString
        }
        else if shiftState == .Locked
        {
            return str.uppercaseString
        }
        else
        {
            return str
        }
    }


	func hideExpandView(notification: NSNotification)
	{
		
		if notification.userInfo != nil
        {
            if let title = notification.userInfo!["text"] as? String {

                self.textDocumentProxy.insertText(CasedString(title, shiftState: self.shiftState))

                self.setCapsIfNeeded()
            }
		}
		
		if self.forwardingView.isLongPressEnable == false
		{
			self.view.bringSubviewToFront(self.bannerView!)
		}
		viewLongPopUp.hidden = true

	}
	
	func heightForOrientation(orientation: UIInterfaceOrientation, withTopBanner: Bool) -> CGFloat {
		let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
		
		//TODO: hardcoded stuff
		let actualScreenWidth = (UIScreen.mainScreen().nativeBounds.size.width /
			UIScreen.mainScreen().nativeScale)
		
		let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(orientation.isPortrait && actualScreenWidth >= 400 ? 226 : 216))
		let canonicalLandscapeHeight = (isPad ? CGFloat(352) : CGFloat(162))
		
		let topBannerHeight = (withTopBanner ? metric("topBanner") : 0)
		let proxy = textDocumentProxy
		
		if proxy.keyboardType == UIKeyboardType.NumberPad || proxy.keyboardType == UIKeyboardType.DecimalPad
		{
			return CGFloat(orientation.isPortrait ? canonicalPortraitHeight + 0 : canonicalLandscapeHeight + 0)
		}
		else
		{
			return CGFloat(orientation.isPortrait ? canonicalPortraitHeight + topBannerHeight : canonicalLandscapeHeight + topBannerHeight)
		}
		
	}
    /*
    BUG NOTE

    None of the UIContentContainer methods are called for this controller.
    */
	
    //override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    //    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    //}
	
    func setupKeys() {
        if self.layout == nil {
            return
        }
		
        for page in keyboard.pages {
            for rowKeys in page.rows { // TODO: quick hack
                for key in rowKeys {
                    if let keyView = self.layout?.viewForKey(key) {
                        keyView.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
						
                        switch key.type {
                        case Key.KeyType.KeyboardChange:
                            keyView.addTarget(self, action: "advanceTapped:", forControlEvents: .TouchUpInside)
                        case Key.KeyType.Backspace:
                            let cancelEvents: UIControlEvents = [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpInside, UIControlEvents.TouchDragExit, UIControlEvents.TouchUpOutside, UIControlEvents.TouchCancel, UIControlEvents.TouchDragOutside]
                            
                            keyView.addTarget(self, action: "backspaceDown:", forControlEvents: .TouchDown)
                            keyView.addTarget(self, action: "backspaceUp:", forControlEvents: cancelEvents)
                        case Key.KeyType.Shift:
                            keyView.addTarget(self, action: Selector("shiftDown:"), forControlEvents: .TouchDown)
                            keyView.addTarget(self, action: Selector("shiftUp:"), forControlEvents: .TouchUpInside)
                            keyView.addTarget(self, action: Selector("shiftDoubleTapped:"), forControlEvents: .TouchDownRepeat)
                        case Key.KeyType.ModeChange:
                            keyView.addTarget(self, action: Selector("modeChangeTapped:"), forControlEvents: .TouchDown)
                        case Key.KeyType.Settings:
                            keyView.addTarget(self, action: Selector("toggleSettings"), forControlEvents: .TouchUpInside)
                        default:
                            break
                        }
                        
                        if key.isCharacter {
                            if UIDevice.currentDevice().userInterfaceIdiom != UIUserInterfaceIdiom.Pad {
                                keyView.addTarget(self, action: Selector("showPopup:"), forControlEvents: [.TouchDown, .TouchDragInside, .TouchDragEnter])
                                keyView.addTarget(keyView, action: Selector("hidePopup"), forControlEvents: [.TouchDragExit, .TouchCancel])
                                keyView.addTarget(self, action: Selector("hidePopupDelay:"), forControlEvents: [.TouchUpInside, .TouchUpOutside, .TouchDragOutside])
                            }
							
							keyView.addTarget(self, action: Selector("keyCharDoubleTapped:"), forControlEvents: .TouchDownRepeat)
                        }
                        
                        if key.hasOutput {
                            keyView.addTarget(self, action: "keyPressedHelper:", forControlEvents: .TouchUpInside)
                        }
                        
                        if key.type != Key.KeyType.Shift && key.type != Key.KeyType.ModeChange {
                            
                            keyView.addTarget(self, action: Selector("highlightKey:"), forControlEvents: [.TouchDown, .TouchDragInside, .TouchDragEnter])
                            keyView.addTarget(self, action: Selector("unHighlightKey:"), forControlEvents: [.TouchUpInside, .TouchUpOutside, .TouchDragOutside,  .TouchDragExit, .TouchCancel])
                        }
                        
                        keyView.addTarget(self, action: Selector("playKeySound"), forControlEvents: .TouchDown)
                    }
                }
            }
        }
    }
    
    /////////////////
    // POPUP DELAY //
    /////////////////
    
    var keyWithDelayedPopup: KeyboardKey?
    var popupDelayTimer: NSTimer?
    
    func showPopup(sender: KeyboardKey) {
        if sender == self.keyWithDelayedPopup {
            self.popupDelayTimer?.invalidate()
        }
		
		self.view.sendSubviewToBack(self.bannerView!)
		
		let proxy = textDocumentProxy
        if proxy.keyboardType != UIKeyboardType.NumberPad && proxy.keyboardType != UIKeyboardType.DecimalPad {

            sender.showPopup()
		}
    }
	
    func hidePopupDelay(sender: KeyboardKey) {
        self.popupDelayTimer?.invalidate()
        
        if sender != self.keyWithDelayedPopup {
            self.keyWithDelayedPopup?.hidePopup()
            self.keyWithDelayedPopup = sender
        }
        
        if sender.popup != nil {
            self.popupDelayTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("hidePopupCallback"), userInfo: nil, repeats: false)
        }
    }
    
    func hidePopupCallback() {
        self.keyWithDelayedPopup?.hidePopup()
        self.keyWithDelayedPopup = nil
        self.popupDelayTimer = nil
    }
    
    /////////////////////
    // POPUP DELAY END //
    /////////////////////
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    // TODO: this is currently not working as intended; only called when selection changed -- iOS bug

	override func textDidChange(textInput: UITextInput?) {
		self.contextChanged()
		
		let proxy = textDocumentProxy 
		
		keyboard_type = textDocumentProxy.keyboardType!
		
        if proxy.documentContextBeforeInput == nil {
			sug_word = " "
		}
		
		dispatch_async(dispatch_get_main_queue(), {
			if proxy.keyboardType! != self.preKeyboardType
			{
				self.forwardingView.resetTrackedViews()
				self.shiftStartingState = nil
				self.shiftWasMultitapped = false
				//
				// optimization: ensures smooth animation
				if let keyPool = self.layout?.keyPool {
					for view1 in keyPool {
						view1.shouldRasterize = true
					}
				}
				
				for view1 in self.forwardingView.subviews
				{
					let v = view1 
					v.removeFromSuperview()
					
				}
				
				self.keyboardHeight = self.heightForOrientation(self.currentInterfaceOrientation, withTopBanner: true)
				
				self.constraintsAdded = false
				self.setupLayout()
				
			}
			
		})
	}
	
    func contextChanged() {
        self.setCapsIfNeeded()
        self.autoPeriodState = .NoSpace
    }
	
    func setHeight(height: CGFloat) {
        if self.heightConstraint == nil {
            self.heightConstraint = NSLayoutConstraint(
                item:self.view,
                attribute:NSLayoutAttribute.Height,
                relatedBy:NSLayoutRelation.Equal,
                toItem:nil,
                attribute:NSLayoutAttribute.NotAnAttribute,
                multiplier:0,
                constant:height)
            self.heightConstraint!.priority = 1000
			
            self.view.addConstraint(self.heightConstraint!) // TODO: what if view already has constraint added?
        }
        else {
            self.heightConstraint?.constant = height
        }
    }
    
    func updateAppearances(appearanceIsDark: Bool) {
        self.layout?.solidColorMode = self.solidColorMode()
        self.layout?.darkMode = appearanceIsDark
        self.layout?.updateKeyAppearance()
        
        self.bannerView?.darkMode = appearanceIsDark
        self.settingsView?.darkMode = appearanceIsDark
    }
    
    func highlightKey(sender: KeyboardKey) {
        sender.highlighted = true
    }
    
    func unHighlightKey(sender: KeyboardKey) {
        sender.highlighted = false
    }
    
    func keyPressedHelper(sender: KeyboardKey) {
        if let model = self.layout?.keyForView(sender) {
            self.keyPressed(model)

            // auto exit from special char subkeyboard
            if model.type == Key.KeyType.Space || model.type == Key.KeyType.Return
                || model.lowercaseOutput == "'"
                || model.type == Key.KeyType.Character {

                    self.currentMode = 0
            }

            // auto period on double space
            self.handleAutoPeriod(model)

            // TODO: reset context
        }
        
        self.setCapsIfNeeded()
    }
	
    func handleAutoPeriod(key: Key) {
        if !NSUserDefaults.standardUserDefaults().boolForKey(kPeriodShortcut) {
            return
        }
		
        if self.autoPeriodState == .FirstSpace {
            if key.type != Key.KeyType.Space {
                self.autoPeriodState = .NoSpace
                return
            }
			
            let charactersAreInCorrectState = { () -> Bool in
                let previousContext = self.textDocumentProxy.documentContextBeforeInput
				
                if previousContext == nil || previousContext!.characters.count < 3 {
                    return false
                }
				
                var index = previousContext!.endIndex
				
                index = index.predecessor()
                if previousContext![index] != " " {
                    return false
                }
                
                index = index.predecessor()
                if previousContext![index] != " " {
                    return false
                }
                
                index = index.predecessor()
                let char = previousContext![index]
                if characterIsWhitespace(char) || characterIsPunctuation(char) || char == "," {
                    return false
                }
                
                return true
            }()
            
            if charactersAreInCorrectState {
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.insertText(".")
                self.textDocumentProxy.insertText(" ")
            }
            
            self.autoPeriodState = .NoSpace
        }
        else {
            if key.type == Key.KeyType.Space {
                self.autoPeriodState = .FirstSpace
            }
        }
    }
    
    func cancelBackspaceTimers() {
        self.backspaceDelayTimer?.invalidate()
        self.backspaceRepeatTimer?.invalidate()
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = nil
    }
    
    func backspaceDown(sender: KeyboardKey) {
        self.cancelBackspaceTimers()
        
        let textDocumentProxy = self.textDocumentProxy
        textDocumentProxy.deleteBackward()
        
        self.setCapsIfNeeded()
        
        // trigger for subsequent deletes
        self.backspaceDelayTimer = NSTimer.scheduledTimerWithTimeInterval(backspaceDelay - backspaceRepeat, target: self, selector: Selector("backspaceDelayCallback"), userInfo: nil, repeats: false)
    }
    
    func backspaceUp(sender: KeyboardKey) {
        self.cancelBackspaceTimers()
    }
    
    func backspaceDelayCallback() {
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = NSTimer.scheduledTimerWithTimeInterval(backspaceRepeat, target: self, selector: Selector("backspaceRepeatCallback"), userInfo: nil, repeats: true)
    }
    
    func backspaceRepeatCallback() {
        self.playKeySound()
        
        self.textDocumentProxy.deleteBackward()
        
        self.setCapsIfNeeded()
    }
    
    func shiftDown(sender: KeyboardKey) {
        self.shiftStartingState = self.shiftState
        
        if let shiftStartingState = self.shiftStartingState {
            if shiftStartingState.uppercase() {
                // handled by shiftUp
                return
            }
            else {
                self.shiftState = (self.shiftState == .Disabled) ? .Enabled : .Disabled
                (sender.shape as? ShiftShape)?.withLock = false
            }
        }
    }
    
    func shiftUp(sender: KeyboardKey) {
        if self.shiftWasMultitapped {
            // do nothing
        }
        else {
            if let shiftStartingState = self.shiftStartingState {
                if !shiftStartingState.uppercase() {
                    // handled by shiftDown
                }
                else {
                    self.shiftState = (self.shiftState == .Disabled) ? .Enabled : .Disabled
                    (sender.shape as? ShiftShape)?.withLock = false
                }
            }
        }

        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
    }
    
    func shiftDoubleTapped(sender: KeyboardKey) {
        self.shiftWasMultitapped = true
        self.shiftState = (self.shiftState == .Locked) ? .Disabled : .Locked
    }
    
    func updateKeyCaps(uppercase: Bool) {
        let characterUppercase = (NSUserDefaults.standardUserDefaults().boolForKey(kSmallLowercase) ? uppercase : true)
        self.layout?.updateKeyCaps(false, uppercase: uppercase, characterUppercase: characterUppercase, shiftState: self.shiftState)
    }
    
    func modeChangeTapped(sender: KeyboardKey) {
        if let toMode = self.layout?.viewToModel[sender]?.toMode {
            self.currentMode = toMode
        }
    }
    
    func setMode(mode: Int) {
        self.forwardingView.resetTrackedViews()
        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        let uppercase = self.shiftState.uppercase()
        let characterUppercase = (NSUserDefaults.standardUserDefaults().boolForKey(kSmallLowercase) ? uppercase : true)
        self.layout?.layoutKeys(mode, uppercase: uppercase, characterUppercase: characterUppercase, shiftState: self.shiftState)
        
        self.setupKeys()
    }
    
    func advanceTapped(sender: KeyboardKey) {
        self.forwardingView.resetTrackedViews()
        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        self.advanceToNextInputMode()
    }
    @IBAction func toggleSettings() {
        // lazy load settings
        if self.settingsView == nil {
            if let aSettings = self.createSettings() {
                aSettings.darkMode = self.darkMode()
                
                aSettings.hidden = true
                self.view.addSubview(aSettings)
                self.settingsView = aSettings
                
                aSettings.translatesAutoresizingMaskIntoConstraints = false
                
                let widthConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
                let heightConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
                let centerXConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
                let centerYConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
                
                self.view.addConstraint(widthConstraint)
                self.view.addConstraint(heightConstraint)
                self.view.addConstraint(centerXConstraint)
                self.view.addConstraint(centerYConstraint)
            }
        }
        
        if let settings = self.settingsView {
            let hidden = settings.hidden

            self.bannerView?.hidden = hidden
            
            settings.hidden = !hidden
            
            self.forwardingView.hidden = hidden
            self.forwardingView.userInteractionEnabled = !hidden
        }
    }
    
    func setCapsIfNeeded() -> Bool {
        if self.shouldAutoCapitalize() {
            self.shiftState = (self.shiftState == .Locked) ? .Locked : .Enabled
            
            return true
        }
        else {
            self.shiftState = (self.shiftState == .Locked) ? .Locked : .Disabled
            
            return false
        }
    }
    
    func shouldAutoCapitalize() -> Bool {
        if !NSUserDefaults.standardUserDefaults().boolForKey(kAutoCapitalization) {
            return false
        }
        
        let traits = self.textDocumentProxy
        if let autocapitalization = traits.autocapitalizationType {
            let documentProxy = self.textDocumentProxy
            
            switch autocapitalization {
            case .None:
                return false
            case .Words:
                if let beforeContext = documentProxy.documentContextBeforeInput {
                    let previousCharacter = beforeContext[beforeContext.endIndex.predecessor()]
                    return characterIsWhitespace(previousCharacter)
                }
                else {
                    return true
                }
                
            case .Sentences:
                if let beforeContext = documentProxy.documentContextBeforeInput {
                    let offset = min(3, beforeContext.characters.count)
                    var index = beforeContext.endIndex
                    
                    for (var i = 0; i < offset; i += 1) {
                        index = index.predecessor()
                        let char = beforeContext[index]
                        
                        if characterIsPunctuation(char) {
                            if i == 0 {
                                return false //not enough spaces after punctuation
                            }
                            else {
                                return true //punctuation with at least one space after it
                            }
                        }
                        else {
                            if !characterIsWhitespace(char) {
                                return false //hit a foreign character before getting to 3 spaces
                            }
                            else if characterIsNewline(char) {
                                return true //hit start of line
                            }
                        }
                    }
                    
                    return true //either got 3 spaces or hit start of line
                }
                else {
                    return true
                }
            case .AllCharacters:
                return true
            }
        }
        else {
            return false
        }
        
    }
    
    // this only works if full access is enabled
    func playKeySound() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(kKeyboardClicks) {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            AudioServicesPlaySystemSound(1104)
        })
    }
    
    //////////////////////////////////////
    // MOST COMMONLY EXTENDABLE METHODS //
    //////////////////////////////////////
    
    class var layoutClass: KeyboardLayout.Type { get { return KeyboardLayout.self }}
    class var layoutConstants: LayoutConstants.Type { get { return LayoutConstants.self }}
    class var globalColors: GlobalColors.Type { get { return GlobalColors.self }}
    
    func keyPressed(key: Key) {
            self.textDocumentProxy.insertText(key.outputForCase(self.shiftState.uppercase()))
    }
    
    // a banner that sits in the empty space on top of the keyboard
    func createBanner() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        return ExtraView(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        //return nil
    }
    
    // a settings view that replaces the keyboard when the settings button is pressed
    func createSettings() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        let settingsView = DefaultSettings(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        settingsView.backButton?.addTarget(self, action: Selector("toggleSettings"), forControlEvents: UIControlEvents.TouchUpInside)
        return settingsView
    }
	
	// MARK: Added methods for extra features
	func initializePopUp()
	{
		button.hidden = true
		button.forwordingView = forwardingView
		button.frame = CGRectMake(0, 0, 20, 20)
		button.tag = 111
		self.view.insertSubview(self.button, aboveSubview: self.forwardingView)
		button.setupInputOptionsConfigurationWithView(forwardingView)
		button.hidden = true
		viewLongPopUp.hidden = true
	}

	func didTTouchExitDownSuggestionButton(sender: AnyObject?)
	{
		let button = sender as! UIButton
		button.backgroundColor = UIColor(red:0.68, green:0.71, blue:0.74, alpha:1)
		button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
	}
	
	func didTTouchDownSuggestionButton(sender: AnyObject?)
	{
        if let button = sender as? UIButton {

            if let btn_title = button.titleForState(UIControlState.Normal) where !stringIsWhitespace(btn_title)  {
                self.bannerView?.showPressedAppearance(button)
            }
        }
    }
	
	func didTapSuggestionButton(sender: AnyObject?)
	{
        
		self.currentMode = 0
		
		self.autoPeriodState = .FirstSpace

        onSuggestionTap(sender)

        self.bannerView!.updateAppearance()
		
		self.setCapsIfNeeded()
		
	}
	
    func onSuggestionTap(sender: AnyObject?)
    {
        if let button = sender as? UIButton {

            let title = TrimWhiteSpace(button.titleForState(.Normal))

            if title == ""
            {
                return
            }

            if self.shiftState == .Enabled
            {
                self.textDocumentProxy.insertText(title.capitalizedString + " ")
            }
            else if self.shiftState == .Locked
            {
                self.textDocumentProxy.insertText(title.uppercaseString + " ")
            }
            else
            {
                let tokens = self.sug_word.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as [String]

                if let lastWord = tokens.last where lastWord != "" && self.isCapitalalize(lastWord) {
                    self.textDocumentProxy.insertText(title.capitalizedString + " ")
                }
                else {
                    self.textDocumentProxy.insertText(title + " ")
                }
                
            }
        }
    }



	func keyCharDoubleTapped(sender: KeyboardKey)
	{
		if sender.tag == 888
		{
			sender.hidePopup()
			
			var arrOptions = self.getInputOption(sender.text.uppercaseString) as [String]
			
			if arrOptions.count > 0
			{
				if arrOptions[0] != ""
				{
					var offsetY : CGFloat = 9
					
                    if self.currentInterfaceOrientation == UIInterfaceOrientation.LandscapeLeft || self.currentInterfaceOrientation == UIInterfaceOrientation.LandscapeRight {
                        offsetY = 3
                    }
                    else {
                        switch  KeyboardViewController.getDeviceType() {
                        case TTDeviceType.TTDeviceTypeIPhone4, TTDeviceType.TTDeviceTypeIPhone5:
                            offsetY = 9
                            
                        case TTDeviceType.TTDeviceTypeIPhone6:
                            offsetY = 13
                            
                        case TTDeviceType.TTDeviceTypeIPhone6p:
                            offsetY = 16
                        }
                    }
					
					self.button.removeFromSuperview()
					
					self.button.frame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y + sender.frame.size.height - offsetY, sender.frame.size.width, sender.frame.size.height)
					
					self.view.insertSubview(self.button, aboveSubview: self.forwardingView)
					
                    let isTopRow:Bool = self.layout?.keyForView(sender)?.isTopRow ?? false
					self.viewLongPopUp = self.button.showLongPopUpOptions(isTopRow)
					self.button.input = sender.text
					self.button.hidden = true
					self.button.inputOptions = arrOptions
					self.viewLongPopUp.hidden = false
					
					for anyView in self.view.subviews
					{
						if anyView is CYRKeyboardButtonView
						{
							anyView.removeFromSuperview()
						}
					}
					
					self.viewLongPopUp.userInteractionEnabled = false;
					
					button.setupInputOptionsConfigurationWithView(forwardingView)
					self.view.insertSubview(self.viewLongPopUp, aboveSubview: self.forwardingView)
					self.forwardingView.isLongPressEnable = true
					self.view.bringSubviewToFront(self.viewLongPopUp)
					//self.forwardingView.resetTrackedViews()
					//sender.hidePopup()
					//self.view.addSubview(self.viewLongPopUp)
					
					sender.tag = 0
				}
			}
		}
	}
	
	class func getDeviceType()->TTDeviceType
	{
		var height = UIScreen.mainScreen().bounds.size.height
		
		if UIScreen.mainScreen().bounds.size.height < UIScreen.mainScreen().bounds.size.width
		{
			height = UIScreen.mainScreen().bounds.size.width
		}
		
		switch (height) {
		case 480:
			deviceType = TTDeviceType.TTDeviceTypeIPhone4
			break
			
		case 568:
			deviceType = TTDeviceType.TTDeviceTypeIPhone5
			break
            
		case 667:
			deviceType = TTDeviceType.TTDeviceTypeIPhone6
			break
            
		case 736:
			deviceType = TTDeviceType.TTDeviceTypeIPhone6p
			break
			
		default:
			break
		}
		
		return deviceType
		
	}
    
    let lowerCaseCousins: [String : [String]] = [
        "A" : ["a","á", "à", "ä", "â", "ã", "å", "æ","ā"],
        "E" : ["e", "é", "è", "ë", "ê", "ę", "ė", "ē"],
        "U" : ["u", "ú", "ü", "ù", "û", "ū"],
        "I" : ["i", "í", "ï", "ì", "î", "į", "ī"],
        "O" : ["o", "ó", "ò", "ö", "ô", "õ", "ø", "œ", "ō"],
        "S" : ["s","š"],
        "D" : ["d", "đ"],
        "C" : ["c", "ç", "ć", "č"],
        "N" : ["n","ñ", "ń"],
        "." : [".com",".edu",".net",".org"]
    ]

    let upperCaseCousins: [String : [String]] = [
        "A" : ["A","Á","À","Ä","Â","Ã","Å","Æ","Ā"],
        "E" : ["E","É","È","Ë","Ê","Ę","Ė","Ē"],
        "U" : ["U","Ú","Ü","Ù","Û"],
        "I" : ["I","Í","Ï","Ì","Î","Į","Ī"],
        "O" : ["O","Ó","Ò","Ö","Ô","Õ","Ø","Œ","Ō"],
        "S" : ["S","Š"],
        "D" : ["D","Đ"],
        "C" : ["C","Ç","Ć","Č"],
        "N" : ["N","Ñ","Ń"],
        "." : [".com",".edu",".net",".org"]
    ]

	func getInputOption(strChar : String) -> [String]
	{
        if let cousins = self.shiftState == .Enabled || self.shiftState == .Locked ? upperCaseCousins[strChar] : lowerCaseCousins[strChar] {
            return cousins
        }
        else {
            return [""]
        }
    }
}
