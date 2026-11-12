import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var files: [URL] = []
    @State private var message = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Prima prova") {
                    Text("Condividi un video con SoundSaver, poi riapri questa app per vedere il file ricevuto.")
                    Text("Versione diagnostica: conversione MP3 non ancora inclusa.")
                }
                if !message.isEmpty { Text(message) }
                Section("Video ricevuti") {
                    ForEach(files, id: \.self) { file in
                        Text(file.lastPathComponent).font(.caption).textSelection(.enabled)
                    }
                }
            }
            .navigationTitle("SoundSaver")
            .toolbar { Button("Aggiorna", action: reload) }
            .onAppear(perform: reload)
            .onChange(of: scenePhase) { phase in if phase == .active { reload() } }
        }
    }

    private func reload() {
        do {
            files = try FileManager.default.contentsOfDirectory(at: SharedStorage.inbox(), includingPropertiesForKeys: nil, options: .skipsHiddenFiles).sorted { $0.lastPathComponent < $1.lastPathComponent }
            message = files.isEmpty ? "Nessun video ricevuto." : "\(files.count) file nel contenitore condiviso."
        } catch { message = error.localizedDescription }
    }
}
