// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

func applyStyle() {

    if #available(iOS 11, *) {
    } else {
        UINavigationBar.appearance().isTranslucent = false
    }

    UINavigationBar.appearance().tintColor = Colors.blue

    UINavigationBar.appearance().titleTextAttributes = [
        .foregroundColor: Colors.black,
    ]
}

struct Colors {
    static let darkBlue = UIColor(hex: "234875")
    static let blue = UIColor(hex: "175286")
    static let brightBlue = UIColor(hex: "1C6AAE")
    static let lightBlue = UIColor(hex: "51769A")
    static let red = UIColor(hex: "f7506c")
    static let veryLightRed = UIColor(hex: "FFF4F4")
    static let veryLightOrange = UIColor(hex: "FFECC9")
    static let green = UIColor(hex: "2fbb4f")
    static let lightGray = UIColor.lightGray
    static let veryLightGray = UIColor(hex: "F6F6F6")
    static let gray = UIColor.gray
    static let darkGray = UIColor(hex: "606060")
    static let black = UIColor(hex: "313849")
    static let lightBlack = UIColor(hex: "313849")
    static let lightWhite = UIColor(hex: "CCD7E2")
}

struct StyleLayout {
    static let sideMargin: CGFloat = 15
}
