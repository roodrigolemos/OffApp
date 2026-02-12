//
//  TabBarView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct TabBarView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ProgresssView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(.offAccent)
    }
}

#Preview {
    TabBarView()
        .previewEnvironment()
}
