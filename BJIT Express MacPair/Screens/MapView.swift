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
    @Binding var distanceInMeter: Int
    @Binding var durationInSecond: Int
    
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
                durationInSecond = 0
                distanceInMeter = 0
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
            distanceInMeter = Int(route.distance)
            durationInSecond = Int(route.expectedTravelTime)
            
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
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @State private var errorWrapper: ErrorWrapper?
    @State private var selectedTransportType: MKDirectionsTransportType = .automobile
    @State private var eta: String = ""
    @State private var distance: String = ""
    @State private var canStart: Bool = false
    @State private var showAlert = false
    var fakeRoute = DemoLocation().getRoute()
    @State var routeIndex = 0
    @State private var durationInSecond = 0
    @State private var distanceInMeter = 0
    let hour = 10, minute = 5, second = 0
    @State var hasStarted = false
    @State var busName = ""
    var body: some View {
        VStack {
            
            VStack {
                MapTopView()
                VehicleSelectionView(selectedVehicle: $selectedTransportType)
                if routeIndex < fakeRoute.count{
                    Map(sourceLocation: CLLocationCoordinate2D(latitude: locationProvider.latitude, longitude: locationProvider.longitude), destinationLocation: CLLocationCoordinate2D(latitude: fakeRoute[routeIndex].coordinate.latitude , longitude: fakeRoute[routeIndex].coordinate.longitude), selectedTransportType: $selectedTransportType, estimatedArrivalTime: $eta, distance: $distance, canStart: $canStart,distanceInMeter: $distanceInMeter, durationInSecond: $durationInSecond)
                        .cornerRadius(10)
                        .onAppear {
                            locationProvider.requestLocation()
                        }
                        .onChange(of: durationInSecond) { newValue in
                            print("duration in seconds: \(newValue)")
                            homeViewModel.durationInSecond = newValue
                        }
                        .onChange(of: distanceInMeter) { newValue in
                            homeViewModel.distanceInMeter = newValue
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
//                            if isBeforeTimeOfDay(date: Date(), hour: hour, minute: minute, second: second) {
                                Task{
                                    if !hasStarted{
                                        //checkin
                                        let isReserveDone = await allocateBus()
                                        if isReserveDone{
                                            hasStarted = true
                                        } else{
                                            hasStarted = false
                                        }
                                        showAlert = true
                                    } else{
                                        //checkout
                                        showAlert = false
                                        hasStarted = false
                                        if let reservedSeat = ckManager.isSeatReserved(employeeId: savedEmployeeID){
                                            await ckManager.deallocateSeat(editedSeat: reservedSeat)
                                        }
                                    }
                                }
                        }, label: {
                            HStack{
                                Image(systemName: "location.north")
                                Text(!hasStarted ? "Check-In" : "Check-Out")
                                
                            }.padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .foregroundColor(Color("startButtonTextColor"))
                        })
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Alert"),
                                message: Text(busName.isEmpty ? "There is not bus schedule at  this moment." : "Your bus is \(busName)"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        .background(Color("startButtonColor"))
                        .cornerRadius(20)
                        .buttonStyle(.borderless)
                        .disabled(!canStart)
                        Spacer()
                        
                        Button(action: {
                            if routeIndex > 1{
                                routeIndex = routeIndex - 1
                            }
                            Task{
                                await allocateBus()
                            }
                        }, label: {
                            Text("Previous")
                        })
//                        .hidden()
                        Button(action: {
                            if routeIndex < fakeRoute.count{
                                routeIndex = routeIndex + 1
                            }
                            Task{
                                await allocateBus()
                            }
                        }, label: {
                            Text("Next")
                        })
//                        .hidden()
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }
    
    func allocateBus()async ->Bool {
        var reserveDone = false
        for bus in ckManager.buses{
            let busDepartureDuration = Int(bus.startTime.timeIntervalSince(Date()))
            if let reservedSeat = ckManager.isSeatReserved(employeeId: savedEmployeeID){
                await ckManager.deallocateSeat(editedSeat: reservedSeat)
                try? await ckManager.populateSeats(busId: bus.busId)
            }
            if homeViewModel.durationInSecond < busDepartureDuration{
                // allocate to empty seat
                let isReserved = try? await ckManager.allocateSeat(busId: bus.busId, employeeId: savedEmployeeID, distanceInMeter: homeViewModel.distanceInMeter)
                
                try? await ckManager.populateSeats(busId: bus.busId)
                if isReserved == true{
                    busName = bus.name
                    reserveDone = true
                    break
                }
                else{
                    busName = ""
                    print("no seat in the bus: \(bus.name) of id: \(bus.busId), trying next bus")
                }
            }
        }
        if reserveDone == false{
            busName = ""
            print("oops! no seat available on any bus")
        }
        return reserveDone
    }
    
}
