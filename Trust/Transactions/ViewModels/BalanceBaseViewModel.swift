// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BalanceBaseViewModel {
    var attributedCurrencyAmount: NSAttributedString? { get }
    var attributedAmount: NSAttributedString { get }
}

extension BalanceBaseViewModel {
    var largeLabelAttributed: [NSAttributedStringKey: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return [
            .font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold),
            .foregroundColor: UIColor.white,
            .paragraphStyle: style,
        ]
    }

    var smallLabelAttributes: [NSAttributedStringKey: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return [
            .font: UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular),
            .foregroundColor: UIColor(red: CGFloat(255.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(0.8)),
            .paragraphStyle: style,
        ]
    }
}
