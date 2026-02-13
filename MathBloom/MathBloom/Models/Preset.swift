import Foundation
import SwiftData

@Model
final class Preset {
    var name: String
    var childName: String
    var iconColorHex: String
    var configData: Data  // JSON-encoded WorksheetConfig
    var createdAt: Date
    var lastUsedAt: Date

    init(name: String, childName: String = "", iconColorHex: String = "#4CAF50", config: WorksheetConfig) {
        self.name = name
        self.childName = childName
        self.iconColorHex = iconColorHex
        self.configData = (try? JSONEncoder().encode(config)) ?? Data()
        self.createdAt = Date()
        self.lastUsedAt = Date()
    }

    /// Decode the stored config
    var worksheetConfig: WorksheetConfig? {
        try? JSONDecoder().decode(WorksheetConfig.self, from: configData)
    }

    /// Update the stored config
    func updateConfig(_ config: WorksheetConfig) {
        self.configData = (try? JSONEncoder().encode(config)) ?? Data()
        self.lastUsedAt = Date()
    }
}
