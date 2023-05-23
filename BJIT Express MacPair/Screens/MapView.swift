//
//  MapView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 12/5/23.
//

import SwiftUI
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationString: String = ""
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    override init() {
        super.init()
        locationManager.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackgroundActive(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForegroundActive(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async {[weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self?.locationManager.startUpdatingLocation()
                self?.locationManager.allowsBackgroundLocationUpdates = true
                self?.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let placemark = placemarks?.first {
                    DispatchQueue.main.async {
                        self.locationString = "\(placemark.locality ?? ""), \(placemark.country ?? "")"
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    @objc private func applicationDidEnterBackgroundActive (_ notification: Notification) {
        print("location updates on background EnterBackgroundActive \(locationManager.location?.coordinate.latitude)")
        self.locationManager.startUpdatingLocation()
    }
    
    @objc private func applicationWillEnterForegroundActive (_ notification: Notification) {
        print("location updates on background WillEnterForegroundActive \(locationManager.location?.coordinate.latitude)")
        self.locationManager.startUpdatingLocation()
    }
}






struct Map: UIViewRepresentable {
    let sourceLocation: CLLocationCoordinate2D
    let destinationLocation: CLLocationCoordinate2D
    @Binding var selectedTransportType: MKDirectionsTransportType
    @Binding var estimatedArrivalTime: String
    @Binding var distance: String
    @Binding var canStart: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing overlays
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        // Add a polyline overlay between source and destination
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let request = MKDirections.Request()
        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = selectedTransportType
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let route = response?.routes.first else {
                estimatedArrivalTime = "No Routes found."
                distance = ""
                canStart = false
                return
            }
            mapView.addOverlay(route.polyline)
            let eta = route.expectedTravelTime
            let formattedETA = DateComponentsFormatter()
            formattedETA.unitsStyle = .abbreviated
            let formattedString = formattedETA.string(from: eta)
            estimatedArrivalTime = "\(formattedString ?? "")"
            print("Estimated arrival time: \(formattedString ?? "")")
            canStart = true
            
            let distanceInKm = route.distance / 1000 // Convert distance to kilometers
            distance = String(format: "%.2f km", distanceInKm)
            
            let distanceAnnotation = MKPointAnnotation()
            distanceAnnotation.title = estimatedArrivalTime
            let index = route.polyline.pointCount - 1
            distanceAnnotation.coordinate = route.polyline.points()[index].coordinate
            
            mapView.addAnnotation(distanceAnnotation)
        }
        
        // Set the region to show both source and destination
        let centerCoordinate = CLLocationCoordinate2D(latitude: (sourceLocation.latitude + destinationLocation.latitude) / 2,
                                                      longitude: (sourceLocation.longitude + destinationLocation.longitude) / 2)
        let span = MKCoordinateSpan(latitudeDelta: abs(sourceLocation.latitude - destinationLocation.latitude) * 2,
                                    longitudeDelta: abs(sourceLocation.longitude - destinationLocation.longitude) * 2)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: Map
        
        init(_ parent: Map) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKPolyline {
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 7
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

struct MapView: View {
   
    @StateObject private var locationProvider = LocationManager()
    @AppStorage("employeeID") var savedEmployeeID: String = ""
    @EnvironmentObject private var ckManager: CloudKitManager
    @State private var errorWrapper: ErrorWrapper?
    @State private var selectedTransportType: MKDirectionsTransportType = .automobile
    @State private var eta: String = ""
    @State private var distance: String = ""
    @State private var canStart: Bool = false
    @State private var showAlert = false
    var fakeRoute = DemoLocation().getRoute()
    @State var routeIndex = 0
    let hour = 10, minute = 5, second = 0
    var body: some View {
        VStack {
            
            VStack {
                MapTopView()
                VehicleSelectionView(selectedVehicle: $selectedTransportType)
                if routeIndex < fakeRoute.count{
                    Map(sourceLocation: CLLocationCoordinate2D(latitude: locationProvider.latitude, longitude: locationProvider.longitude), destinationLocation: CLLocationCoordinate2D(latitude: fakeRoute[routeIndex].coordinate.latitude, longitude: fakeRoute[routeIndex].coordinate.longitude), selectedTransportType: $selectedTransportType, estimatedArrivalTime: $eta, distance: $distance, canStart: $canStart)
                        .cornerRadius(10)
                        .onAppear {
                            locationProvider.requestLocation()
                        }
                }
                VStack(alignment: .leading){
                    Rectangle()
                        .frame(height: 0)
                    HStack{
                        Text(eta)
                            .foregroundColor(.red)
                        Text(distance.isEmpty ? "" : "(\(distance))")
                            .foregroundColor(.gray)
                    }
                    .font(.system(size: 20, design: .rounded))
                    HStack {
                        Button(action: {
                            //Start Button Action
                            if isBeforeTimeOfDay(date: Date(), hour: hour, minute: minute, second: second) {
                                Task{
                                    do{
                                        try await ckManager.addUser(user: UserModel(name: "User", employeeId: savedEmployeeID, isActive: true, startTime: Date()))
                                    }
                                    catch{
                                        errorWrapper = ErrorWrapper(error: error, guidance: "Failed to update task. Try again later.")
                                    }
                                }
                            } else{
                                showAlert = true
                            }
                        }, label: {
                            HStack{
                                Image(systemName: "location.north")
                                Text("Start")
                                
                            }.padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .foregroundColor(Color("startButtonTextColor"))
                        })
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Alert"),
                                message: Text("There is not bus schedule at  this moment."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        .background(Color("startButtonColor"))
                        .cornerRadius(20)
                        .buttonStyle(.borderless)
                        .disabled(!canStart)
                        Spacer()
                        Button(action: {
                            if routeIndex < fakeRoute.count{
                                routeIndex = routeIndex + 1
                            }
                        }, label: {
                            Text("Next")
                        })
                        .hidden()
                        Button(action: {
                            if routeIndex > 1{
                                routeIndex = routeIndex - 1
                            }
                        }, label: {
                            Text("Previous")
                        })
                        .hidden()
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }
    
    func isBeforeTimeOfDay(date: Date, hour: Int, minute: Int, second: Int) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()

        // Extracting the components (year, month, day) from the current date
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)

        // Creating a new date with the same year, month, and day, but with the specified time
        var components = DateComponents()
        components.year = currentComponents.year
        components.month = currentComponents.month
        components.day = currentComponents.day
        components.hour = hour
        components.minute = minute
        components.second = second

        if let specifiedTime = calendar.date(from: components) {
            return date < specifiedTime
        }

        return false
    }
}
