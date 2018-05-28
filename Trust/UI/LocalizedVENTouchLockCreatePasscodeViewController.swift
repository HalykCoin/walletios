// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import VENTouchLock

class LocalizedVENTouchLockCreatePasscodeViewController {
    
    let controller: VENTouchLockCreatePasscodeViewController
    
    init() {
        self.controller = VENTouchLockCreatePasscodeViewController()
    }
    
    func getVentCreatePasscodeViewController() -> VENTouchLockCreatePasscodeViewController {
        controller.title = NSLocalizedString("Settings.passcode.title", value: "Set passcode", comment: "")
        controller.touchLock.appearance().createPasscodeInitialLabelText =  NSLocalizedString("Settings.passcode.create", value: "Enter a new passcode", comment: "")
        controller.touchLock.appearance().createPasscodeConfirmLabelText =  NSLocalizedString("Settings.passcode.reenter", value: "Please re-enter your passcode", comment: "")
        controller.touchLock.appearance().createPasscodeMismatchedLabelText =  NSLocalizedString("Settings.passcode.mismatch", value: "Passcode did not match. Try again", comment: "")
        
        controller.touchLock.appearance().enterPasscodeInitialLabelText =  NSLocalizedString("Settings.passcode.enter", value: "Enter your passcode", comment: "")
        controller.touchLock.appearance().enterPasscodeIncorrectLabelText =  NSLocalizedString("Settings.passcode.incorrect", value: "Incorrect passcode. Try again", comment: "")
        return controller
    }
    
}
