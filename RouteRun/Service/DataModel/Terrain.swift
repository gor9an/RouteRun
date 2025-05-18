enum Terrain: String, CaseIterable, Identifiable, Codable {
    case flat = "Плоский"
    case hilly = "Холмистый"
    case mountainous = "Горный"
    var id: String { rawValue }
}
