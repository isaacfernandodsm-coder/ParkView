import UIKit
import AVKit

final class Playback {
    static let shared = Playback()
    let player = AVPlayer()
    private var statusObservation: NSKeyValueObservation?
    private var externalObservation: NSKeyValueObservation?
    private init() {
        player.allowsExternalPlayback = true
        externalObservation = player.observe(\.isExternalPlaybackActive, options: [.new]) { player, _ in
            DispatchQueue.main.async {
                Diagnostics.shared.record("Reprodução externa AVPlayer: \(player.isExternalPlaybackActive)")
            }
        }
    }
    func load(_ url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            Diagnostics.shared.record("Falha ao ativar sessão de áudio: código \((error as NSError).code)")
        }
        let item = AVPlayerItem(url: url)
        statusObservation = item.observe(\.status, options: [.new]) { item, _ in
            DispatchQueue.main.async {
                if item.status == .failed {
                    Diagnostics.shared.record("Player falhou: código \((item.error as NSError?)?.code ?? 0)")
                } else if item.status == .readyToPlay {
                    Diagnostics.shared.record("Mídia pronta para reprodução")
                }
            }
        }
        player.replaceCurrentItem(with: item)
        player.play()
        Diagnostics.shared.record("Reprodução solicitada")
    }
    func test() {
        guard let url = Bundle.main.url(forResource: "test-pattern", withExtension: "mp4") else {
            Diagnostics.shared.record("Arquivo de teste ausente"); return
        }
        load(url)
    }
}

final class VideoController: UIViewController {
    private let address = UITextField()
    private let playerController = AVPlayerViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        address.placeholder = "URL HTTPS direta: .mp4 ou .m3u8"
        address.borderStyle = .roundedRect
        address.autocapitalizationType = .none
        address.autocorrectionType = .no
        address.keyboardType = .URL
        let play = UIButton(type: .system)
        play.setTitle("Reproduzir link direto", for: .normal)
        play.addTarget(self, action: #selector(playURL), for: .touchUpInside)
        let test = UIButton(type: .system)
        test.setTitle("Reproduzir vídeo de teste local", for: .normal)
        test.addTarget(self, action: #selector(testVideo), for: .touchUpInside)
        let route = AVRoutePickerView()
        route.prioritizesVideoDevices = true
        route.heightAnchor.constraint(equalToConstant: 44).isActive = true
        let note = UILabel()
        note.text = "O botão AirPlay lista destinos de mídia. Áudio no carro não garante vídeo. Links de páginas do YouTube devem ser abertos na aba Navegador."
        note.font = .preferredFont(forTextStyle: .footnote)
        note.numberOfLines = 0
        note.textColor = .secondaryLabel
        addChild(playerController)
        playerController.player = Playback.shared.player
        playerController.allowsPictureInPicturePlayback = false
        let stack = UIStackView(arrangedSubviews: [address, play, test, route, note, playerController.view])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        playerController.didMove(toParent: self)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            address.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    @objc private func testVideo() { confirmStationaryUse { Playback.shared.test() } }
    @objc private func playURL() {
        guard let url = ValidatedURL.https(address.text ?? "") else {
            message("Link inválido", "Use uma URL HTTPS de mídia, sem usuário ou senha no endereço."); return
        }
        if ValidatedURL.youtube(url) {
            message("Link de página", "Abra o YouTube na aba Navegador. O app não extrai arquivos ou contorna as restrições do serviço."); return
        }
        address.resignFirstResponder()
        confirmStationaryUse { Playback.shared.load(url) }
    }
}
