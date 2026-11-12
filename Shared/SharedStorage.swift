import Foundation

enum SharedStorage {
    static func inbox() throws -> URL {
        guard let identifier = Bundle.main.object(forInfoDictionaryKey: "AppGroupIdentifier") as? String,
              let root = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            throw NSError(domain: "SoundSaver", code: 1, userInfo: [NSLocalizedDescriptionKey: "App Group non disponibile. Verificare identificatore, entitlements e profili di entrambi i target."])
        }
        let directory = root.appendingPathComponent("Inbox", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    // Copy synchronously inside the provider callback: its URL expires on return.
    // Publish with a same-directory rename so readers never see partial files.
    static func save(_ source: URL) throws -> URL {
        let directory = try inbox()
        let id = UUID().uuidString
        let temporary = directory.appendingPathComponent(".\(id).partial")
        let suffix = source.pathExtension.isEmpty ? "mov" : source.pathExtension
        let destination = directory.appendingPathComponent("\(id).\(suffix)")
        let scoped = source.startAccessingSecurityScopedResource()
        defer {
            if scoped { source.stopAccessingSecurityScopedResource() }
            try? FileManager.default.removeItem(at: temporary)
        }
        try FileManager.default.copyItem(at: source, to: temporary)
        try FileManager.default.moveItem(at: temporary, to: destination)
        return destination
    }
}
