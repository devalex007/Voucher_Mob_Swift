//
//  GlobalDialog.swift
//  vochuer
//
//  Created by Admin on 6/14/23.
//

import Foundation
import UIKit
import SwiftMessages

class GlobalDialog{
    static let commonDialogId = "CommonDialog"
    static let timeoutId = "timeoutId"
    static let successDialogId = "successDialogId"

    static func showErrorMessage(message: String) {
        DispatchQueue.main.async {
            SwiftMessages.hide(id: commonDialogId)
            let messageDialog = MessageView.viewFromNib(layout: .cardView)
            messageDialog.configureTheme(.error)
            messageDialog.configureDropShadow()
            messageDialog.configureContent(title: "Error", body: message)
            
            messageDialog.backgroundView.backgroundColor = UIColor.red
            messageDialog.button?.tintColor = UIColor.red
            
            messageDialog.button?.isHidden = false
            messageDialog.button?.titleLabel?.textAlignment = NSTextAlignment.center
            messageDialog.button?.setTitle("OK", for: .normal)
            messageDialog.buttonTapHandler = {button in
                SwiftMessages.hide(id: messageDialog.id)
            }
            messageDialog.id = commonDialogId
            var messageConfig = SwiftMessages.defaultConfig
            messageConfig.presentationStyle = .center
            messageConfig.duration = .forever
            SwiftMessages.show(config: messageConfig, view: messageDialog)
        }
    }
    
    static func showSuccessMessage(message: String) {
        DispatchQueue.main.async {
            SwiftMessages.hide(id:successDialogId)
            let messageDialog = MessageView.viewFromNib(layout: .cardView)
            messageDialog.configureTheme(.success)
            messageDialog.configureDropShadow()
            messageDialog.configureContent(title: "Success", body: message)
            messageDialog.button?.isHidden = false
            messageDialog.button?.setTitle("Ok", for: .normal)
            messageDialog.buttonTapHandler = {button in
                SwiftMessages.hide(id: messageDialog.id)
            }
            messageDialog.id = successDialogId
            var messageConfig = SwiftMessages.defaultConfig
            messageConfig.presentationStyle = .center
            messageConfig.duration = .forever
            SwiftMessages.show(config: messageConfig, view: messageDialog)
        }
    }
}
