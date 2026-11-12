# Prima build SoundSaver

Repository verificato al commit 41a23551da27edb3b962d7bafdb6ebbf20a1b27b: presenti soltanto .gitignore, README.md e codemagic.yaml. Questo pacchetto aggiunge i sorgenti e sostituisce codemagic.yaml. Conservare README.md e .gitignore esistenti. Nessuna modifica remota: creazione branch rifiutata con HTTP 403 Resource not accessible by integration.

Caricare i file su un nuovo branch, mantenendo le cartelle. In Codemagic selezionare quel branch e il workflow soundsaver-ios, quindi Start new build. XcodeGen genera anche SoundSaver/Info.plist. Il comando build compila app ed estensione; non esegue test XCTest. I log sono raccolti anche in caso di errore e pipefail evita di nascondere il fallimento della compilazione.

La build senza firma produce una .app per simulatore, non una IPA installabile su iPhone/iPad. Non sono state eseguite compilazioni Xcode in Windows. Le versioni latest/Homebrew non sono bloccate: dopo la prima build riuscita fissare le versioni effettivamente riportate nei log.

Prima dei test fisici registrare i due Bundle ID e group.com.paninelloacido.soundsaver nel proprio account Apple Developer, abilitare lo stesso App Group per entrambi i target e rigenerare entrambi i provisioning profile. Gli identificatori sono proposti, non risultano registrati. APP_GROUP_IDENTIFIER in project.yml alimenta sia gli entitlements sia gli Info.plist. Nessun fallback a contenitori privati se il gruppo manca.

Test manuali dopo firma: condividere un MP4 da File, un video da Foto, un link e infine il video TikTok scaricato. Verificare tipi dichiarati, dimensione copiata e presenza nell'app dopo riapertura. La copia termina prima della chiusura del callback NSItemProvider. Il file viene pubblicato con rinomina dopo la copia; l'app ignora i file parziali nascosti. Questa prima versione importa solo il primo video, non converte MP3, non valida i codec, non elimina i file e non apre automaticamente l'app. La disponibilità del video da TikTok resta da provare su dispositivo. Le diagnostiche URL/testo mostrano i tipi esposti, non scaricano contenuti.

Riferimenti verificati:
- https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md
- https://docs.codemagic.io/yaml-basic-configuration/yaml-getting-started/
- https://developer.apple.com/documentation/foundation/nsitemprovider/loadfilerepresentation(fortypeidentifier:completionhandler:)
- https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html
