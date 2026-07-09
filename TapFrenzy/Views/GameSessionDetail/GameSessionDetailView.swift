import SwiftUI
import MapKit

struct GameSessionDetailView: View {
    let session: GameSession

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)
    }

    var body: some View {
        List {
            Section("Result") {
                LabeledContent("Mode", value: session.mode.displayName)
                LabeledContent("Score", value: "\(session.score)")
                LabeledContent("Played", value: session.timestamp.formatted(date: .long, time: .shortened))
            }

            if session.latitude != 0 || session.longitude != 0 {
                Section("Location") {
                    Map(position: .constant(.region(
                        MKCoordinateRegion(center: coordinate,
                                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    ))) {
                        Marker(session.mode.displayName, coordinate: coordinate)
                    }
                    .frame(height: 200)
                }
            }

            Section {
                ShareLink(item: "I scored \(session.score) on \(session.mode.displayName) — beat that!") {
                    Label("Share Score", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle(session.mode.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
