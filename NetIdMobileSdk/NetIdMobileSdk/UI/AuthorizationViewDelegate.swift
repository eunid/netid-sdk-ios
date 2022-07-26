//
// Created by Felix Hug on 26.07.22.
//

import Foundation

public protocol AuthorizationViewDelegate: AnyObject {
    func didTapDismiss()

    func didTapContinue(bundleIdentifier: String?)
}