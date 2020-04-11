//
//  PopulationView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 12.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct PopulationView: View {
    let population = Bundle.main
        .decode(Population.self, from: "population.json")
        .sorted(by: { $0.countryName < $1.countryName })
    
    @State private var search = ""
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.tertiary)
                
                TextField("Type to search", text: $searchText) {
                    self.search = self.searchText
                }
                
                searchText.isNotEmpty
                    ? Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.tertiary)
                        }
                    : nil
            }
            .padding(6)
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
            .stroke(Color.tertiary, style: StrokeStyle(lineWidth: 0.5)))
            .padding(.horizontal)
            
            List {
                ForEach(population
                    .filter {
                        search.count > 3
                            ? $0.countryName.contains(searchText)
                            : true
                }) { item in
                    HStack {
                        Text(item.countryName)
                        Text(item.countryCode)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(item.population)")
                            .font(.subheadline)
                    }
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button(action: {
                            //  MARK: FINISH THIS
                        }) {
                            Image(systemName: "textformat.alt")
                            Text("Edit country")
                        }
                    }
                }
            }
        }
    }
}

struct PopulationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            PopulationView()
        }
        .environment(\.colorScheme, .dark)
    }
}
