//
//  UILabel+Extension.swift
//  Hangman
//
//  Created by Huy Bui on 2022-07-14.
//

import UIKit

extension UILabel {
    
    func setCharacterSpacing(kernValue: Double) {
        guard let text = text, !text.isEmpty else { return }
          
        let attributedString = NSMutableAttributedString(string: text)
          attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
          
        attributedText = attributedString
    }
    
    func sizeToFitScreen(maxFontSize: Int, threshold: Int) {
        var maxFontSize = maxFontSize
        
        self.font = UIFont.systemFont(ofSize: CGFloat(maxFontSize), weight: .medium)
        // Resizing label if it exceeds the current screen width
        while self.intrinsicContentSize.width >= UIScreen.main.bounds.size.width - CGFloat(threshold) {
            maxFontSize -= 1
            self.font = UIFont.systemFont(ofSize: CGFloat(maxFontSize), weight: .medium)
        }
    }
    
    func uppercased() {
        self.text = text?.uppercased()
    }
    
    
}

