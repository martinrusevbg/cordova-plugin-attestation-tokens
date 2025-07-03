import Foundation
import FirebaseCore
import FirebaseAppCheck

class AttestationTokensAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        // Use #available to check iOS version at runtime
        if #available(iOS 14.0, *) {
            return AppAttestProvider(app: app)
        } else {
            // Fallback to DeviceCheckProvider for iOS versions older than 14.0
            // DeviceCheckProvider is available from iOS 11.0
            return DeviceCheckProvider(app: app)
        }
    }
}

@objc(AttestationTokens)
class AttestationTokens: CDVPlugin {
    override func pluginInitialize() {
        super.pluginInitialize()

        if FirebaseApp.app() == nil {
            let providerFactory = AttestationTokensAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
    
            FirebaseApp.configure()
        }
    }

    @objc(getToken:)
    func getToken(_ command: CDVInvokedUrlCommand) {
        AppCheck.appCheck().token(forcingRefresh: false) { token, error in
            var pluginResult: CDVPluginResult

            if let error = error {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: error.localizedDescription
                )
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }
            guard let token = token else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Couldn't get attestation token"
                )
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }

            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: token.token)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }

    @objc(getLimitedUseToken:)
    func getLimitedUseToken(_ command: CDVInvokedUrlCommand) {
        AppCheck.appCheck().limitedUseToken { token, error in
            var pluginResult: CDVPluginResult

            if let error = error {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: error.localizedDescription
                )
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }
            guard let token = token else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Couldn't get attestation token"
                )
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }

            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: token.token)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
}
