import SwiftUI
import SwiftData

@Observable
final class PresetListViewModel {

    /// Save current config as a new preset
    func savePreset(from config: WorksheetConfig, name: String, childName: String = "", modelContext: ModelContext) {
        let preset = Preset(name: name, childName: childName, config: config)
        modelContext.insert(preset)
    }

    /// Load config from a preset
    func loadPreset(_ preset: Preset) -> WorksheetConfig? {
        preset.lastUsedAt = Date()
        return preset.worksheetConfig
    }

    /// Duplicate a preset
    func duplicatePreset(_ preset: Preset, modelContext: ModelContext) {
        guard let config = preset.worksheetConfig else { return }
        let newPreset = Preset(
            name: preset.name + " (copy)",
            childName: preset.childName,
            iconColorHex: preset.iconColorHex,
            config: config
        )
        modelContext.insert(newPreset)
    }

    /// Check if user can save more presets (free tier limit)
    func canSaveMore(currentCount: Int) -> Bool {
        currentCount < StoreManager.shared.maxPresets
    }
}
