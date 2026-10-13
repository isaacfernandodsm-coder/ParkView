#if CARPLAY
import CarPlay
import UIKit

// This file is excluded from the AltStore target. Requires the iOS 27 SDK.
// Capability is NOT a parked-state signal. System and vehicle enforce video availability.
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, CPSessionConfigurationDelegate {
    private var controller: CPInterfaceController?
    private var configuration: CPSessionConfiguration?

    func templateApplicationScene(_ scene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        controller = interfaceController
        Diagnostics.shared.carPlayConnected = true
        let config = CPSessionConfiguration(delegate: self)
        configuration = config
        refresh()
    }
    func templateApplicationScene(_ scene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        Playback.shared.player.pause()
        controller = nil
        configuration = nil
        Diagnostics.shared.carPlayConnected = false
        Diagnostics.shared.supportsVideo = nil
        Diagnostics.shared.record("Sessão CarPlay desconectada; player pausado")
    }
    private func refresh() {
        guard let controller, let configuration else { return }
        let supported: Bool
        if #available(iOS 27.0, *) { supported = configuration.supportsVideoPlayback }
        else { supported = false }
        Diagnostics.shared.supportsVideo = supported
        Diagnostics.shared.record("Central anuncia suporte a vídeo: \(supported)")
        let info = CPListItem(text: supported ? "Central compatível com vídeo" : "Central não anuncia suporte a vídeo",
                              detailText: "A disponibilidade de imagem é decidida pelo carro e pelo iOS.")
        var items = [info]
        if supported {
            let test = CPListItem(text: "Reproduzir teste local", detailText: "Imagem no carro somente quando autorizada pelo sistema")
            test.handler = { _, completion in Playback.shared.test(); completion() }
            items.append(test)
        }
        let root = CPListTemplate(title: "ParkView", sections: [CPListSection(items: items)])
        controller.setRootTemplate(root, animated: false) { _, error in
            if let error { Diagnostics.shared.record("Falha no template: código \((error as NSError).code)") }
        }
    }
    func sessionConfiguration(_ sessionConfiguration: CPSessionConfiguration, limitedUserInterfacesChanged limitedUserInterfaces: CPLimitableUserInterface) {
        refresh()
    }
}
#endif
