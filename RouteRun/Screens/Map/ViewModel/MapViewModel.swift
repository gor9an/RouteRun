import MapKit
import Firebase
import FirebaseFirestore


final class MapViewModel: NSObject, ObservableObject {
    private lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .fitness
        _locationManager.distanceFilter = 5.0
        _locationManager.allowsBackgroundLocationUpdates = true
        _locationManager.pausesLocationUpdatesAutomatically = false


        return _locationManager
    }()
    private var routePoints: [CLLocationCoordinate2D] = []
    private var startDate: Date?
    private var lastLocation: CLLocation?
    private var timer: Timer?

    @Published var currentRoute: Route?
    @Published var isRecording = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var distance: Double = 0
    @Published var routeLine: MKPolyline?
    @Published var routeDescription = ""
    @Published var userWeight: Int = 70
    @Published var caloriesBurned: Double = 0

    private let geocoder = CLGeocoder()
    @Published var currentCity: String = "Unknown"

    private let db = Firestore.firestore()

    override init() {
        super.init()
        loadUserWeight()
    }

    func checkLocationIsEnable() {
        self.checkLocationAuthorization()
    }

    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("ограничен")
        case .denied:
            print("отключены")
        case .authorizedAlways, .authorizedWhenInUse:
            print("ok")
        @unknown default:
            break
        }
    }

    func startRecordingRoute() {
        guard !isRecording else { return }

        if elapsedTime > 0 {
            isRecording = true
            startDate = Date().addingTimeInterval(-elapsedTime)
            locationManager.startUpdatingLocation()

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.elapsedTime += 1
            }
            return
        }

        resetRecording()
        isRecording = true
        startDate = Date()
        lastLocation = nil
        locationManager.startUpdatingLocation()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }

    func pauseRecording() {
        isRecording = false
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
    }

    func stopRecordingRoute() throws {
        guard isRecording else { return }

        pauseRecording()

        var userId = ""

        do {
            userId = try AuthenticationManager.shared.getAuthenticatedUser().id
        } catch {
            print("No user logged in")
            throw MapError.unAuthorized
        }

        if let startDate = startDate, let firstLocation = routePoints.first, distance != 0 {
            let location = CLLocation(latitude: firstLocation.latitude, longitude: firstLocation.longitude)
            determineCity(for: location)

            currentRoute = Route(
                name: "",
                description: routeDescription,
                date: startDate,
                coordinates: routePoints,
                distance: distance,
                duration: elapsedTime,
                userId: userId,
                city: currentCity
            )
        } else {
            throw MapError.distanceZero
        }
    }

    func saveRoute(name: String, description: String) {
        guard var route = currentRoute else { return }
        route.name = name
        route.description = description
        route.city = currentCity

        do {
            try db.collection("routes").document(route.id).setData(from: route)
            resetRecording()
        } catch {
            print("Error saving route: \(error.localizedDescription)")
        }
    }

    func resetRecording() {
        isRecording = false
        routePoints.removeAll()
        distance = 0
        elapsedTime = 0
        startDate = nil
        lastLocation = nil
        routeLine = nil
        currentRoute = nil
        routeDescription = ""
        timer?.invalidate()
        timer = nil
    }

    private func determineCity(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }

            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }

            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self.currentCity = city
                }
            }
        }
    }

    private func loadUserWeight() {
        Task {
            guard let uid = try? AuthenticationManager.shared.getAuthenticatedUser().id else { return }
            let document = try await db.collection("users").document(uid).getDocument()
            let user = try? document.data(as: RouteUser.self)
            self.updateWeight(user?.weight)
        }
    }

    private func updateWeight(_ newWeight: Int?) {
        DispatchQueue.main.async {
            self.userWeight = newWeight ?? 70
        }
    }

    private func computeCalories() {
        guard elapsedTime > 0 else {
            caloriesBurned = 0
            return
        }
        let hours = elapsedTime / 3600
        let speedKmh = distance / elapsedTime * 3.6

        let met: Double
        switch speedKmh {
        case ..<6:   met = 3.5
        case ..<9:   met = 7.0
        default:     met = 11.5
        }

        caloriesBurned = met * Double(userWeight) * hours
    }

    private func updateRouteLine() {
        guard !routePoints.isEmpty else {
            routeLine = nil
            return
        }

        let coordinates = routePoints
        routeLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, isRecording else { return }

        guard newLocation.horizontalAccuracy <= 50 else { return }

        if routePoints.isEmpty {
            determineCity(for: newLocation)
        }

        let coordinate = newLocation.coordinate
        routePoints.append(coordinate)

        if let lastLocation = lastLocation {
            distance += newLocation.distance(from: lastLocation)
            computeCalories()
        }
        lastLocation = newLocation

        updateRouteLine()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

extension MapViewModel {
    var formattedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: elapsedTime) ?? "00:00:00"
    }

    var formattedSpeed: String {
        guard distance != 0 && elapsedTime != 0 else {
            return "0.00 км/ч"
        }

        return String(format: "%.2f км/ч", distance / elapsedTime * 3.6)
    }

    var formattedDistance: String {
        if distance >= 1000 {
            return String(format: "%.2f км", distance / 1000)
        } else {
            return String(format: "%.0f м", distance)
        }
    }

    var formattedCalories: String {
        return String(format: "%.1f ккал", caloriesBurned)
    }
}
