//
//  CatboardBanner.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

/*
This is the demo banner. The banner is needed so that the top row popups have somewhere to go. Might as well fill it
with something (or leave it blank if you like.)
*/

class CatboardBanner: ExtraView {
    
    var catSwitch: UISwitch = UISwitch()
    var catLabel: UILabel = UILabel()
	
	var touchToView: [UITouch:UIView]
	
     var isAllowFullAccess : Bool = false
	
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
		self.touchToView = [:]
		
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
		
        self.updateAppearance()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func respondToSwitch() {
        NSUserDefaults.standardUserDefaults().setBool(self.catSwitch.on, forKey: kCatTypeEnabled)
        self.updateAppearance()
    }
    
    func suggestionButton(suggestedWord : String) -> UIButton {
        let btn = UIButton(type: .Custom)
        btn.exclusiveTouch = true
        btn.titleLabel!.minimumScaleFactor = 0.6
        btn.setTitle(suggestedWord, forState: UIControlState.Normal)
        btn.backgroundColor = UIColor(red:0.68, green:0.71, blue:0.74, alpha:1)
        btn.titleLabel?.font = UIFont.systemFontOfSize(18)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel!.adjustsFontSizeToFitWidth = true

        return btn
    }
    
    override func updateAppearance() {

		isAllowFullAccess = isOpenAccessGranted()
        
		btn1 = suggestionButton("The")
        btn2 = suggestionButton("I")
        btn3 = suggestionButton("What")
        btn4 = suggestionButton("Enable Allow Full Access")

        if(isAllowFullAccess == true)
        {
            self.addSubview(self.btn1)
            self.addSubview(self.btn2)
            self.addSubview(self.btn3)
        }
        else
        {
            self.addSubview(self.btn4)
        }
		
		addConstraintsToButtons()
    }

    
    func isOpenAccessGranted() -> Bool {
		
        return (UIPasteboard.generalPasteboard().isKindOfClass(UIPasteboard))
    }

	override func drawRect(rect: CGRect) {}
	
	override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView? {
		
        if self.hidden || self.alpha == 0 || !self.userInteractionEnabled {
            return nil
        }
        else
        {
            return (CGRectContainsPoint(self.bounds, point) ? self : nil)

        }

	}

	
	func addConstraintsToButtons()
	{
        
        if(isAllowFullAccess == true)
        {
            var buttons = [btn1,btn2,btn3]
        
            for (index, button) in buttons.enumerate() {
                
                let topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
                
                let bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
                var rightConstraint : NSLayoutConstraint!
                
                if index == 2
                {
                    rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)
                    self.addConstraint(rightConstraint)
                }
                
                var leftConstraint : NSLayoutConstraint!
                
                if index == 0
                {
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0)
                }
                else
                {
                    
                    let prevtButton = buttons[index-1]
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 1)
                    
                    let firstButton = buttons[0]
                    let widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 1)
                    
                    widthConstraint.priority = 800
                    self.addConstraint(widthConstraint)
                    
                }
                
                self.removeConstraints([topConstraint, bottomConstraint, leftConstraint])
                self.addConstraints([topConstraint, bottomConstraint, leftConstraint])
            }
        }
        else
        {
            let buttons = [btn4]
            
            for (index, button) in buttons.enumerate() {
                
                let topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
                
                let bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
                var rightConstraint : NSLayoutConstraint!
                
                if index == buttons.count - 1
                {
                    
                    rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)
                    self.addConstraint(rightConstraint)
                }
                
                
                var leftConstraint : NSLayoutConstraint!
                
                if index == 0
                {
                    
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 0.5, constant: 0)
                    
                }

                self.removeConstraints([topConstraint, bottomConstraint, leftConstraint])
                self.addConstraints([topConstraint, bottomConstraint, leftConstraint])
            }
            
        }
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
		if self.frame.size.height == 30
		{
			for touch in touches
			{
				let position = touch.locationInView(self)
				let view = findNearestView(position)
				
				let viewChangedOwnership = self.ownView(touch, viewToOwn: view)
				if !viewChangedOwnership {
					self.handleControl(view, controlEvent: .TouchDown)
					
					if touch.tapCount > 1 {
						// two events, I think this is the correct behavior but I have not tested with an actual UIControl
						self.handleControl(view, controlEvent: .TouchDownRepeat)
					}
				}
			}
		}
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
		if self.frame.size.height == 30
		{
			for touch in touches
			{
				let position = touch.locationInView(self)
				
				let oldView = self.touchToView[touch]
				let newView = findNearestView(position)
				
				if oldView != newView
				{
					self.handleControl(oldView, controlEvent: .TouchDragExit)
					
					let viewChangedOwnership = self.ownView(touch, viewToOwn: newView)
					
					if !viewChangedOwnership
					{
						self.handleControl(newView, controlEvent: .TouchDragEnter)
					}
					else
					{
						self.handleControl(newView, controlEvent: .TouchDragInside)
					}
				}
				else
				{
					self.handleControl(oldView, controlEvent: .TouchDragInside)
				}
				
			}
			
		}
		
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
		if self.frame.size.height == 30
		{
			for touch in touches
			{
				let view = self.touchToView[touch]
				
				let touchPosition = touch.locationInView(self)
				
				if self.bounds.contains(touchPosition)
				{
					self.handleControl(view, controlEvent: .TouchUpInside)
				}
				else
				{
					self.handleControl(view, controlEvent: .TouchCancel)
				}
				
				self.touchToView[touch] = nil
			}
			
		}
		
	}
	
	override func touchesCancelled(touches: Set<UITouch>!, withEvent event: UIEvent!)
	{
		if self.frame.size.height == 30
		{
			for touch in touches
			{
				let view = self.touchToView[touch]
				
				self.handleControl(view, controlEvent: .TouchCancel)
				
				self.touchToView[touch] = nil
			}
		}
		
	}
	
	// TODO: there's a bit of "stickiness" to Apple's implementation
	func findNearestView(position: CGPoint) -> UIView? {
		if !self.bounds.contains(position) {
			return nil
		}
		
		var closest: (UIView, CGFloat)? = nil
		
		for anyView in self.subviews {
			let view = anyView
			
			if view.hidden {
				continue
			}
			
			view.alpha = 1
			
			let distance = distanceBetween(view.frame, point: position)
			
			if closest != nil {
				if distance < closest!.1 {
					closest = (view, distance)
				}
			}
			else {
				closest = (view, distance)
			}
		}
		
		if closest != nil {
			return closest!.0
		}
		else {
			return nil
		}
	}
	
	func distanceBetween(rect: CGRect, point: CGPoint) -> CGFloat {
		if CGRectContainsPoint(rect, point) {
			return 0
		}
		
		var closest = rect.origin
		
		if (rect.origin.x + rect.size.width < point.x) {
			closest.x += rect.size.width
		}
		else if (point.x > rect.origin.x) {
			closest.x = point.x
		}
		if (rect.origin.y + rect.size.height < point.y) {
			closest.y += rect.size.height
		}
		else if (point.y > rect.origin.y) {
			closest.y = point.y
		}
		
		let a = pow(Double(closest.y - point.y), 2)
		let b = pow(Double(closest.x - point.x), 2)
		return CGFloat(sqrt(a + b));
	}
	
	func ownView(newTouch: UITouch, viewToOwn: UIView?) -> Bool {
		var foundView = false
		
		if viewToOwn != nil {
			for (touch, view) in self.touchToView {
				if viewToOwn == view {
					if touch == newTouch {
						break
					}
					else {
						self.touchToView[touch] = nil
						foundView = true
					}
					break
				}
			}
		}
		
		self.touchToView[newTouch] = viewToOwn
		return foundView
	}
	
	func handleControl(view: UIView?, controlEvent: UIControlEvents) {
		if let control = view as? UIControl {
			let targets = control.allTargets()
			for target in targets { // TODO: Xcode crashes
				let actions = control.actionsForTarget(target, forControlEvent: controlEvent)
				if (actions != nil) {
					for action in actions! {
						let selector = Selector(action)
						
						control.sendAction(selector, to: target, forEvent: nil)
					}
				}
			}
		}
		
	}

}
