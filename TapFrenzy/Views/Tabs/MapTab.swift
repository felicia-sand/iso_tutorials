import SwiftUI
import MapKit

struct MapTab: View {
    private var store = SessionStore.shared
    private var locationService = LocationService.shared

    @State private var selectedSessionID: GameSession.ID?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedSessionID) {
            ForEach(store.sessions) { session in
                Marker(session.mode.displayName, coordinate: CLLocationCoordinate2D(
                    latitude: session.latitude, longitude: session.longitude
                ))
                .tag(session.id)
            }

            UserAnnotation()
        }
        .navigationTitle("Map")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    locationService.refreshLocation()
                } label: {
                    Image(systemName: "location.circle")
                }
            }
        }
        .task {
            if locationService.authorizationStatus == .notDetermined {
                locationService.requestPermission()
            } else {
                locationService.requestLocation()
            }
        }
        .onChange(of: locationService.currentLocation?.latitude) { _, _ in
            guard let coordinate = locationService.currentLocation else { return }
            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let id = selectedSessionID,
               let session = store.sessions.first(where: { $0.id == id }) {
                HStack {
                    Label(session.mode.displayName, systemImage: session.mode.icon)
                    Spacer()
                    ScoreBadge(score: session.score)
                }
                .padding()
                .background(.regularMaterial)
            }
        }
    }
}
