// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct WelcomeViewModel {

    var title: String {
        return NSLocalizedString("Welcome.title", value: " ", comment: "")
    }

    var backgroundColor: UIColor {
        return Colors.blue
    }

    var pageIndicatorTintColor: UIColor {
        return Colors.lightWhite
    }

    var currentPageIndicatorTintColor: UIColor {
        return .white
    }

    var numberOfPages = 0
    var currentPage = 0
}
