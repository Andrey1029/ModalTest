//
//  ContentView.swift
//  ModalTest
//
//  Created by Andrey on 15.07.2022.
//

import SwiftUI
import ModalPresentationKit

struct ContentView: View {
    @State private var isPresentedMy = false
    @State private var isPresentedApple = false
    @State private var height: CGFloat = UIScreen.main.bounds.height * 0.5
    
    var body: some View {
        VStack(spacing: 20) {
            Button("UIKit modal window") { self.isPresentedApple = true }
            Button("ModalPresentationKit modal window") { self.isPresentedMy = true }
        }
        .modalView(isPresented: $isPresentedMy, height: height) {
            TestView(height: $height)
        }
        .sheet(isPresented: $isPresentedApple) {
            TestView(height: $height)
        }
    }
}

struct TestView: View {
    @Binding var height: CGFloat

    var body: some View {
        VStack {
            HStack {
                Button("Up") { self.height += 100 }
                Spacer()
                Button("Down") { self.height -= 100 }
            }.padding()
            
            HStack {
                List {
                    ForEach(0 ..< 100) { i in
                        Text("Row \(i)")
                    }
                }
                List {
                    ForEach(0 ..< 100) { i in
                        Text("Row \(i)")
                    }
                }
            }
        }
    }
}
