//
//  NavigationButton.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 10/31/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import SwiftUI

struct NavigationButton<Destination>: View where Destination: View {
    let destination: Destination
    @State var isActive: Bool
    let buttonTitle: String

    var body: some View {
        NavigationLink(
            destination: destination.navigationBarTitle("San Francisco"),
            isActive: $isActive,
            label: {
                Button(action: { self.isActive = true }) {
                    Text(buttonTitle)
                }
                .padding(12)
                .background(Color.blue)
                .cornerRadius(15.0)
                .foregroundColor(Color.white)
                .font(.title)
        })
    }
}

struct NavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                NavigationButton(destination: Text("Destination"), isActive: false, buttonTitle: "Navigation")
            }
            NavigationView {
                HStack(spacing: 20) {
                    NavigationButton(destination: Text("Destination"), isActive: false, buttonTitle: "Side By")
                    NavigationButton(destination: Text("Destination"), isActive: false, buttonTitle: "Side")
                }
            }
        }
    }
}
