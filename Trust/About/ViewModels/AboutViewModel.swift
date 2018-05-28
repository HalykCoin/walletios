// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct AboutViewModel {
    var label = NSLocalizedString("transactionsEmpty.deposit", value: "Buy HLC", comment: "")
    var title: String
    var subtitle: String
    var image: UIImage

    init() {
        title = ""
        subtitle = ""
        image = #imageLiteral(resourceName: "onboarding_lock")
    }

    init(title: String, subtitle: String, image: UIImage) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }

    var backgroundColor: UIColor {
        return Colors.blue
    }

}
