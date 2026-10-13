import UIKit
import WebKit

final class BrowserController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let address = UITextField()
    private var web: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = .all
        web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        web.uiDelegate = self
        web.allowsBackForwardNavigationGestures = true
        address.placeholder = "https://…"
        address.text = "https://m.youtube.com"
        address.borderStyle = .roundedRect
        address.autocapitalizationType = .none
        address.autocorrectionType = .no
        address.keyboardType = .URL
        address.addTarget(self, action: #selector(openAddress), for: .editingDidEndOnExit)
        let open = UIButton(type: .system)
        open.setTitle("Abrir", for: .normal)
        open.addTarget(self, action: #selector(openAddress), for: .touchUpInside)
        let row = UIStackView(arrangedSubviews: [address, open])
        row.spacing = 8
        let note = UILabel()
        note.text = "Navegador no iPhone. Para enviar vídeo, use o AirPlay do player do site, quando disponível. A página inteira não é enviada ao CarPlay."
        note.numberOfLines = 0
        note.font = .preferredFont(forTextStyle: .footnote)
        note.textColor = .secondaryLabel
        let stack = UIStackView(arrangedSubviews: [row, note, web])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            row.heightAnchor.constraint(equalToConstant: 44)
        ])
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "YouTube", style: .plain, target: self, action: #selector(youtube)),
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(back))
    }
    @objc private func openAddress() {
        guard let url = ValidatedURL.https(address.text ?? "") else {
            message("Endereço inválido", "Informe um endereço HTTPS sem usuário ou senha na URL."); return
        }
        address.resignFirstResponder()
        confirmStationaryUse { [weak self] in self?.web.load(URLRequest(url: url)) }
    }
    @objc private func youtube() { address.text = "https://m.youtube.com"; openAddress() }
    @objc private func reload() { confirmStationaryUse { [weak self] in self?.web.reload() } }
    @objc private func back() { web.goBack() }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
        let allowed = url.scheme?.lowercased() == "https" || url.absoluteString == "about:blank"
        decisionHandler(allowed ? .allow : .cancel)
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url,
           url.scheme?.lowercased() == "https" { webView.load(URLRequest(url: url)) }
        return nil
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        address.text = webView.url?.absoluteString
        Diagnostics.shared.record("Página carregada no iPhone")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == NSURLErrorCancelled { return }
        Diagnostics.shared.record("Falha de navegação: código \((error as NSError).code)")
        message("Não foi possível abrir", "Verifique a conexão e o endereço. Código: \((error as NSError).code).")
    }
}
