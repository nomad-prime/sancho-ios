//
//  ContentView.swift
//  sancho
//
//  Created by Armin Ghajar Jazi on 03.06.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Sancho's Home", systemImage: "house.fill")
                }

            LearnView()
                .tabItem {
                    Label("Let's Learn", systemImage: "book.fill")
                }

            PracticeView()
                .tabItem {
                    Label("Practice Time", systemImage: "figure.walk")
                }

            ProfileView()
                .tabItem {
                    Label("My Progress", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
