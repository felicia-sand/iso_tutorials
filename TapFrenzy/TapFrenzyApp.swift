

//import SwiftUI
//
//@main
//struct TapFrenzyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            RootTabView()
//        }
//    }
//}
//
//struct RootTabView: View {
//    var body: some View {
//        TabView {
//            NavigationStack { ContentView() }
//                .tabItem { Label("Home", systemImage: "gamecontroller") }
//
//            NavigationStack { StatsTab() }
//                .tabItem { Label("Stats", systemImage: "chart.bar") }
//
//            NavigationStack { MapTab() }
//                .tabItem { Label("Map", systemImage: "map") }
//
//            NavigationStack { SettingsTab() }
//                .tabItem { Label("Settings", systemImage: "gear") }
//        }
//        .onAppear {
//            LocationService.shared.requestPermission()
//        }
//    }
//}

import SwiftUI

@main
struct TapFrenzyApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    LocationService.shared.requestPermission()
                }
        }
    }
}
