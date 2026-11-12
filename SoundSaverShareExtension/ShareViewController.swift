import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    private let report = UITextView()
    private let closeButton = UIButton(type: .system)
    private var started = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        report.isEditable = false
        report.font = .preferredFont(forTextStyle: .body)
        closeButton.setTitle("Chiudi", for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [report, closeButton])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !started else { return }
        started = true
        let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
        let providers = items.flatMap { $0.attachments ?? [] }
        report.text = providers.enumerated().map { "Allegato \($0.offset + 1): \($0.element.registeredTypeIdentifiers.joined(separator: ", "))" }.joined(separator: "\n")
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.movie.identifier) }) else {
            report.text += "\nNessun video esposto dal provider. URL o testo non equivalgono a un MP4; nessun download eseguito."
            return
        }
        let type = provider.hasItemConformingToTypeIdentifier(UTType.mpeg4Movie.identifier) ? UTType.mpeg4Movie.identifier : UTType.movie.identifier
        report.text += "\nRichiesta rappresentazione: \(type). Copia in corso…"
        closeButton.isEnabled = false
        provider.loadFileRepresentation(forTypeIdentifier: type) { [weak self] url, error in
            let result: String
            do {
                if let error = error { throw error }
                guard let url = url else { throw NSError(domain: "SoundSaver", code: 2, userInfo: [NSLocalizedDescriptionKey: "Il provider non ha restituito un file."]) }
                let saved = try SharedStorage.save(url)
                let size = try saved.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                result = "\nFile copiato: \(saved.lastPathComponent) — \(size) byte. Apri SoundSaver manualmente. Il tipo dichiarato non certifica il contenuto del video."
            } catch { result = "\nErrore: \(error.localizedDescription)" }
            DispatchQueue.main.async {
                self?.report.text += result
                self?.closeButton.isEnabled = true
            }
        }
    }

    @objc private func close() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
