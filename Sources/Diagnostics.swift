import UIKit
import AVFoundation

final class Diagnostics {
    static let shared = Diagnostics()
    private(set) var events: [String] = []
    var carPlayConnected = false
    var supportsVideo: Bool?
    private var routeObserver: NSObjectProtocol?
    private init() {
        routeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in self?.record("Rota de áudio alterada") }
    }
    func record(_ event: String) {
        // Never log browsing URLs, cookies or media URLs: these may contain credentials.
        events.append("\(ISO8601DateFormatter().string(from: Date())) | \(event)")
        if events.count > 100 { events.removeFirst(events.count - 100) }
    }
    var report: String {
        let route = AVAudioSession.sharedInstance().currentRoute.outputs.map { $0.portType.rawValue }.joined(separator: ", ")
        let capability = supportsVideo.map { $0 ? "Sim" : "Não" } ?? "Desconhecido: nenhuma sessão CarPlay autorizada observada"
        #if CARPLAY
        let variant = "CarPlay Video (exige entitlement e perfil autorizados)"
        #else
        let variant = "iPhone / AltStore (sem entitlement CarPlay)"
        #endif
        return """
        ParkView 0.1 — protótipo
        Sistema: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        Variante: \(variant)
        Sessão CarPlay do app: \(carPlayConnected ? "Conectada" : "Não observada")
        supportsVideoPlayback: \(capability)
        Rota de ÁUDIO: \(route.isEmpty ? "Não observada" : route)

        carAudio NÃO comprova suporte a vídeo.
        supportsVideoPlayback NÃO comprova que o carro está estacionado.
        A central e o iOS decidem quando a tela do carro pode mostrar vídeo.
        Este app não lê marcha P, freio de estacionamento ou velocidade do carro.
        A variante AltStore não consegue consultar a capacidade de uma sessão
        CarPlay que não foi concedida ao próprio app.

        Eventos locais (sem URLs e cookies):
        \(events.joined(separator: "\n"))
        """
    }
}

final class DiagnosticsController: UIViewController {
    private let text = UITextView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        text.isEditable = false
        text.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        text.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(text)
        NSLayoutConstraint.activate([
            text.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            text.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            text.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            text.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Compartilhar", style: .plain, target: self, action: #selector(share)),
            UIBarButtonItem(title: "Atualizar", style: .plain, target: self, action: #selector(refresh))
        ]
    }
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); refresh() }
    @objc private func refresh() { text.text = Diagnostics.shared.report }
    @objc private func share() {
        let sheet = UIActivityViewController(activityItems: [Diagnostics.shared.report], applicationActivities: nil)
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.first
        present(sheet, animated: true)
    }
}

extension UIViewController {
    func message(_ title: String, _ body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func confirmStationaryUse(_ action: @escaping () -> Void) {
        let alert = UIAlertController(title: "Uso com carro estacionado", message:
            "Use esta interface somente depois de estacionar. Esta confirmação é sua declaração; o app não consegue detectar a marcha P. Na tela do carro, a autorização de vídeo continua sendo controlada pela central e pelo iOS.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Estou estacionado", style: .default) { _ in action() })
        present(alert, animated: true)
    }
}

enum ValidatedURL {
    static func https(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidate = trimmed.contains("://") ? trimmed : "https://" + trimmed
        guard let url = URL(string: candidate), url.scheme?.lowercased() == "https",
              let host = url.host, !host.isEmpty, url.user == nil, url.password == nil else { return nil }
        return url
    }
    static func youtube(_ url: URL) -> Bool {
        let host = url.host?.lowercased() ?? ""
        return host == "youtu.be" || host == "youtube.com" || host.hasSuffix(".youtube.com")
    }
}
