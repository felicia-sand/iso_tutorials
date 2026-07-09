import SwiftUI
import MapKit

struct MapTab: View {
    private var store = SessionStore.shared
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
        }
        .navigationTitle("Map")
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

