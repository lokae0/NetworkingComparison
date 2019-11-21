//
//  ViewControllerRepresentables.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 10/31/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import SwiftUI

struct ForecastView: UIViewControllerRepresentable {
    enum ViewModelType {
        case URLSession, alamofire

        var viewModel: ForecastViewModel {
            switch self {
            case .URLSession: return URLSessionViewModel()
            case .alamofire: return AlamofireViewModel()
            }
        }
    }

    let type: ViewModelType

    func updateUIViewController(_ uiViewController: ForecastViewController, context: UIViewControllerRepresentableContext<ForecastView>) { }

    func makeUIViewController(context: Context) -> ForecastViewController {
        return ForecastViewController(viewModel: type.viewModel)
    }
}

struct RxSwiftForecastView: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: RxForecastViewController, context: UIViewControllerRepresentableContext<RxSwiftForecastView>) { }

    func makeUIViewController(context: Context) -> RxForecastViewController {
        return RxForecastViewController(viewModel: RxSwiftViewModel())
    }
}
