enum ActivityType: String, CaseIterable, Identifiable, Codable {
    case walking = "Ходьба"
    case running = "Бег"
    case cycling = "Велосипед"
    var id: String { rawValue }
}
