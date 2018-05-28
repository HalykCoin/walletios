// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

enum ButtonSize: Int {
    case small
    case normal
    case large
    case extraLarge

    var height: CGFloat {
        switch self {
        case .small: return 32
        case .normal: return 44
        case .large: return 50
        case .extraLarge: return 64
        }
    }
}

enum ButtonStyle: Int {
    case solid
    case squared
    case border
    case borderless
    case solidBlue
    case borderlessBlue

    var backgroundColor: UIColor {
        switch self {
        case .solid, .squared: return .white
        case .border, .borderless, .borderlessBlue: return .clear
        case .solidBlue: return Colors.blue
        }
    }

    var backgroundColorHighlighted: UIColor {
        switch self {
        case .solid, .squared, .solidBlue: return .white
        case .border: return .white
        case .borderless: return Colors.blue
        case .borderlessBlue: return .clear
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .solid, .border, .solidBlue: return 5
        case .squared, .borderless, .borderlessBlue: return 0
        }
    }

    var font: UIFont {
        switch self {
        case .solid,
             .squared,
             .border,
             .borderless,
             .solidBlue,
             .borderlessBlue:
            return UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        }
    }

    var textColor: UIColor {
        switch self {
        case .solid, .squared, .borderlessBlue: return Colors.blue
        case .border, .borderless, .solidBlue: return .white
        }
    }

    var textColorHighlighted: UIColor {
        switch self {
        case .solid, .squared, .solidBlue: return Colors.lightBlue
        case .border: return Colors.blue
        case .borderless, .borderlessBlue: return Colors.lightBlue
        }
    }

    var borderColor: UIColor {
        switch self {
        case .solid, .squared, .border: return .white
        case .borderless, .borderlessBlue: return .clear
        case .solidBlue: return Colors.blue
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .solid, .squared, .borderless, .solidBlue, .borderlessBlue: return 0
        case .border: return 1
        }
    }
}

class Button: UIButton {

    init(size: ButtonSize, style: ButtonStyle) {
        super.init(frame: .zero)
        apply(size: size, style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(size: ButtonSize, style: ButtonStyle) {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: size.height),
            ])

        backgroundColor = style.backgroundColor
        layer.cornerRadius = style.cornerRadius
        layer.borderColor = style.borderColor.cgColor
        layer.borderWidth = style.borderWidth
        layer.masksToBounds = true
        titleLabel?.textColor = style.textColor
        titleLabel?.font = style.font
        setTitleColor(style.textColor, for: .normal)
        setTitleColor(style.textColorHighlighted, for: .highlighted)
        setBackgroundColor(style.backgroundColorHighlighted, forState: .highlighted)
        setBackgroundColor(style.backgroundColorHighlighted, forState: .selected)
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }

}
