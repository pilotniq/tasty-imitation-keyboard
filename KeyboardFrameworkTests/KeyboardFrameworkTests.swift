//
//  KeyboardFrameworkTests.swift
//  KeyboardFrameworkTests
//
//  Created by Simon Corston-Oliver on 3/11/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import XCTest

@testable import Keyboard


class KeyboardFrameworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTrimWhiteSpace() {
        XCTAssertEqual(TrimWhiteSpace(""), "", "Trim empty string yields empty string")
        XCTAssertEqual(TrimWhiteSpace(nil), "", "Trim nil yields empty string")
        XCTAssertEqual(TrimWhiteSpace(" a"), "a", "Trim ' a' string yields 'a'")
        XCTAssertEqual(TrimWhiteSpace("\t\ta"), "a", "Trim '\\t\\ta' yields 'aa'")
    }

    func testCharacterIsPunctuation() {
        let validPunctuation = ".!?"
        for validPunc in validPunctuation.characters {
            XCTAssert(characterIsPunctuation(validPunc))
        }

        for invalidPunc in String(NSCharacterSet(charactersInString: validPunctuation).invertedSet).characters {
            XCTAssert(!characterIsPunctuation(invalidPunc))
        }
    }

    func testCharacterIsNewline() {
        for validNewlineChar in "\n\r".characters {
            XCTAssert(characterIsNewline(validNewlineChar))
        }

        for invalidNewlineChar in "\tk".characters {
            XCTAssert(!characterIsNewline(invalidNewlineChar))
        }
    }

    func testIsInitCaps()
    {
        XCTAssert(!isInitCaps(""))
        XCTAssert(!isInitCaps("dog"))
        XCTAssert(isInitCaps("DOG"))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
/*        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
 */
    }


    // Do a bunch of tests to validate the language definitions file
    func testJSONLoading()
    {
        // Can we at least load the file as JSON?
        // This will fail if the file is missing or ill-formed
        XCTAssert (loadJSON("LanguageDefinitions") != nil)


        // Make sure we barf for an invalid JSON file
        XCTAssert (loadJSON("FileThatDoesNotExist") == nil)

    }

}
