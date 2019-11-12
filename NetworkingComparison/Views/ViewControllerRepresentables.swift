//
//  ViewControllerRepresentables.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 10/31/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import SwiftUI

struct ForecastView: UIViewControllerRepresentable {
    let viewModel: ForecastViewModel

    func updateUIViewController(_ uiViewController: ForecastViewController, context: UIViewControllerRepresentableContext<ForecastView>) { }

    func makeUIViewController(context: Context) -> ForecastViewController {
        return ForecastViewController(viewModel: viewModel)
    }
}
