enum Surface: String, CaseIterable, Identifiable, Codable {
    case asphalt = "Асфальт"
    case gravel = "Гравий"
    case trail = "Тропа"
    var id: String { rawValue }
}
