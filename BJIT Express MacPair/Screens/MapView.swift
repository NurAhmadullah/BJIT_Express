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
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude //37.4074565
            longitude = location.coordinate.longitude //-122.21184
            
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
}






struct Map: UIViewRepresentable {
    let sourceLocation: CLLocationCoordinate2D
    let destinationLocation: CLLocationCoordinate2D
    @Binding var selectedTransportType: MKDirectionsTransportType
    @Binding var estimatedArrivalTime: String
    @Binding var distance: String
    
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
                return }
            mapView.addOverlay(route.polyline)
            let eta = route.expectedTravelTime
            let formattedETA = DateComponentsFormatter()
            formattedETA.unitsStyle = .abbreviated
            let formattedString = formattedETA.string(from: eta)
            estimatedArrivalTime = "\(formattedString ?? "")"
            print("Estimated arrival time: \(formattedString ?? "")")
            
            let distanceInKm = route.distance / 1000 // Convert distance to kilometers
            distance = String(format: "%.2f km", distanceInKm)
            
            let distanceAnnotation = MKPointAnnotation()
            distanceAnnotation.title = estimatedArrivalTime
            let index = route.polyline.pointCount/2
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
    @State private var selectedTransportType: MKDirectionsTransportType = .automobile
    @State private var eta: String = ""
    @State private var distance: String = ""
    var body: some View {
        VStack {
            
            VStack {
                MapTopView()
                VehicleSelectionView(selectedVehicle: $selectedTransportType)
                
                Map(sourceLocation: CLLocationCoordinate2D(latitude: locationProvider.latitude, longitude: locationProvider.longitude), destinationLocation: CLLocationCoordinate2D(latitude: 37.4253688 , longitude: -122.1464785), selectedTransportType: $selectedTransportType, estimatedArrivalTime: $eta, distance: $distance)
                    .cornerRadius(10)
                    .onAppear {
                        locationProvider.requestLocation()
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
                    Button(action: {
                        //Start Button Action
                    }, label: {
                        HStack{
                            Image(systemName: "location.north")
                            Text("Start")
                            
                        }.padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .foregroundColor(Color("startButtonTextColor"))
                        
                    })
                    .background(Color("startButtonColor"))
                    .cornerRadius(20)
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 10)
            }
        }
    }
}
