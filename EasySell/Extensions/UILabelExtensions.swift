//
// Created by Almas Adilbek on 3/27/17.
// Copyright (c) 2017 GOOD/APP. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {

    // MARK: Color

    func setColor(color:UIColor, forSubstring substring:String) {
        setColor(color: color, forSubstrings: [substring])
    }

    func setColor(color:UIColor, forSubstrings substrings:[String]) {
        let a = getAttributedString()

        for substring in substrings {
            a.addAttribute(NSForegroundColorAttributeName, value: color, range: (a.string as NSString).range(of: substring))
        }

        self.attributedText = a
    }

    // MARK: Font

    func setFont(font:UIFont, forSubstring substring:String) {
        setFont(font: font, forSubstrings: [substring])
    }

    func setFont(font:UIFont, forSubstrings substrings:[String]) {
        let a = getAttributedString()

        for substring in substrings {
            a.addAttribute(NSFontAttributeName, value: font, range: (a.string as NSString).range(of: substring))
        }

        self.attributedText = a
    }

    func setLetter(spacing:CGFloat) {
        let a = getAttributedString()
        a.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: a.length))
        self.attributedText = a
    }

    func setLetterSpacingHalfOne() {
        self.setLetter(spacing: -0.5)
    }

    func getAttributedString() -> NSMutableAttributedString {
        if let a = self.attributedText {
            return NSMutableAttributedString(attributedString: a)
        }
        if let text = self.text {
            return NSMutableAttributedString(string: text)
        }
        return NSMutableAttributedString()
    }

}

// MARK: Initializations.

extension UILabel {

    static func base() -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }

    static func multiline(lines:Int = 0, lineBreakMode:NSLineBreakMode = .byWordWrapping) -> UILabel {
        return base().multiline()
    }

    func multiline(lines:Int = 0, lineBreakMode:NSLineBreakMode = .byWordWrapping) -> UILabel {
        self.lineBreakMode = lineBreakMode
        self.numberOfLines = lines
        return self
    }

    func aligned(_ alignment:NSTextAlignment = .left) -> UILabel {
        self.textAlignment = alignment
        return self
    }

    func centered() -> UILabel {
        return self.aligned(.center)
    }

    func text(_ text:String) -> UILabel {
        self.text = text
        return self
    }

    func color(_ color:UIColor) -> UILabel {
        self.textColor = color
        return self
    }

    func font(_ font:UIFont) -> UILabel {
        self.font = font
        return self
    }

    func systemFont(_ fontSize:CGFloat) -> UILabel {
        return font(UIFont.systemFont(ofSize: fontSize))
    }

    func boldSystemFont(_ fontSize:CGFloat) -> UILabel {
        return font(UIFont.boldSystemFont(ofSize: fontSize))
    }

}
