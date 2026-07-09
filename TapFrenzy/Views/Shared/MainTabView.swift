import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Home", systemImage: "gamecontroller.fill")
            }

            NavigationStack {
                StatsTab()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                MapTab()
            }
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }

            NavigationStack {
                SettingsTab()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .onAppear {
            LocationService.shared.requestPermission()
        }
    }
}

#Preview {
    MainTabView()
}
