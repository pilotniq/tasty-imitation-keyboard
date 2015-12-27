//
//  Utilities.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/22/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import Foundation
import UIKit

var profile: ((id: String) -> Double?) = {
    var counterForName = Dictionary<String, Double>()
    var isOpen = Dictionary<String, Double>()
    
    return { (id: String) -> Double? in
        if let startTime = isOpen[id] {
            let diff = CACurrentMediaTime() - startTime
            if let currentCount = counterForName[id] {
                counterForName[id] = (currentCount + diff)
            }
            else {
                counterForName[id] = diff
            }
            
            isOpen[id] = nil
        }
        else {
            isOpen[id] = CACurrentMediaTime()
        }
        
        return counterForName[id]
    }
}()

// Remove trailing and leading white space.
// Treat nil as equivalent to the empty string.
func TrimWhiteSpace(x : String?) -> String {
    return x == nil ? "" : x!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
}

func characterIsPunctuation(character: Character) -> Bool {
    return character == "." || character == "!" || character == "?"
}

func characterIsNewline(character: Character) -> Bool {
    return character == "\n" || character == "\r"
}

func characterIsWhitespace(character: Character) -> Bool {
    // there are others, but who cares
    return character == " " || character == "\n" || character == "\r" || character == "\t"
}

func stringIsWhitespace(str: String?) -> Bool {
    return TrimWhiteSpace(str) == ""
}

func isInitCaps(string: String) -> Bool
{
    return string.characters.count > 0
        && ("A"..."Z").contains(string[string.startIndex])
}

// HACKHACK I need a locally defined class that I can get a reference to self for as a param to NSBundle()
class foo
{

}

// In the deployed app, JSON resources etc live in the main bundle but when running a unit test we're not running as the main bundle
func getBundle() -> NSBundle {

#if UNIT_TESTS
    return NSBundle(forClass: foo.self)
#else
    return NSBundle.mainBundle()
#endif

}

func loadJSON(fileName: String?) -> NSDictionary?
{
    if let path = getBundle().pathForResource(fileName, ofType: "json")
    {
        if !NSFileManager().fileExistsAtPath(path) {
            NSLog("File does not exist at \(path)")
            return nil
        }

        if let jsonData = NSData(contentsOfFile: path)
        {
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(jsonData, options:NSJSONReadingOptions(rawValue: 0))

                return JSON as? NSDictionary
            }
            catch let JSONError as NSError {
                NSLog("JSONError exception\n\(JSONError)")
                return nil
            }
            catch {
                NSLog("Some other error occurred")
                return nil
            }
        }
    }
    
    return nil

}

func isOpenAccessGranted() -> Bool {
    #if FULLACCESS
        return (UIPasteboard.generalPasteboard().isKindOfClass(UIPasteboard))
    #else
        return true
    #endif
}

// http://stackoverflow.com/questions/3552108/finding-closest-object-to-cgpoint b/c I'm lazy
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

func CurrentLanguageCode() -> String {
    return NSUserDefaults.standardUserDefaults().stringForKey(kActiveLanguageCode) ?? vEnglishLanguageCode
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
