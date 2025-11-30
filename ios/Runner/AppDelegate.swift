import Flutter
import UIKit
import NetworkExtension

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var vpnManager = NEVPNManager.shared()
    private var methodChannel: FlutterMethodChannel?
    private var blockedOperators: [String] = []

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channelName = "com.example.nettide/network"
        methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

        methodChannel?.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }

            switch call.method {
            case "requestVpnPermission":
                self.loadAndStartVpn(result: result)
            case "stopVpn":
                self.stopVpn(result: result)
            case "isVpnActive":
                result(self.isVpnActive())
            case "setBlockedOperators":
                if let args = call.arguments as? [String: Any], let operators = args["blockedOperators"] as? [String] {
                    self.blockedOperators = operators
                    // Here you would add logic to check the current carrier and start/stop the VPN if needed.
                    // For now, we rely on manual start/stop from the UI.
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Blocked operators list is missing", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func loadAndStartVpn(result: @escaping FlutterResult) {
        vpnManager.loadFromPreferences { error in
            if let error = error {
                result(FlutterError(code: "VPN_LOAD_ERROR", message: error.localizedDescription, details: nil))
                return
            }

            // Create a new configuration if one doesn't exist
            if self.vpnManager.protocolConfiguration == nil {
                let newProtocol = NETunnelProviderProtocol()
                newProtocol.providerBundleIdentifier = "com.example.nettide.NetTideTunnel" // Make sure this matches your tunnel provider bundle ID
                newProtocol.serverAddress = "localhost" // Dummy address
                self.vpnManager.protocolConfiguration = newProtocol
                self.vpnManager.localizedDescription = "NetTide VPN"
                self.vpnManager.isEnabled = true
            }

            self.vpnManager.saveToPreferences { error in
                if let error = error {
                    result(FlutterError(code: "VPN_SAVE_ERROR", message: error.localizedDescription, details: nil))
                    return
                }

                do {
                    try self.vpnManager.connection.startVPNTunnel()
                    result(nil) // Success
                } catch {
                    result(FlutterError(code: "VPN_START_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    private func stopVpn(result: @escaping FlutterResult) {
        vpnManager.connection.stopVPNTunnel()
        result(nil)
    }

    private func isVpnActive() -> Bool {
        return vpnManager.connection.status == .connected || vpnManager.connection.status == .connecting
    }
}