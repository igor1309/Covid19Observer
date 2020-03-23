//
//  JohnsHopkinsData.swift
//  Doubling
//
//  Created by Igor Malyarov on 18.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

final class JohnsHopkinsData: ObservableObject {
    @Published var cases: Cases = Cases(from: "")
    
    @Published var selectedCountry: String = UserDefaults.standard.string(forKey: "selectedCountry") ?? "Russia" {
        didSet {
            UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
        }
    }
    
    func getData() {
        let url = URL(string: "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")!
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localURL = localURL {
                if let casesStr = try? String(contentsOf: localURL) {
                    DispatchQueue.main.async {
                        self.cases = Cases(from: casesStr)
                    }
                }
            }
        }
        
        task.resume()
    }
}
