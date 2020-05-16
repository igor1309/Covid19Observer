//
//  TestLocalJSONPublisher.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 21.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import Combine

final class TestingCorona: ObservableObject {
    
    let johnHopkinsAPI = JohnHopkinsAPI.shared
    
    let currentByCountryFilename = "current-country.json"
    let currentByRegionFilename = "current-region.json"
    
    @Published var currentByCountry: Present
    @Published var currentByRegion: Present
    
    @Published var currentByCountryLastUpdated: String = ""
    
    var fetchStr: String {
        currentByCountry.isFetchOK ?? false
            ? "fetch ok (\(currentByCountryLastUpdated))"
            : "???"
    }
    
    var isUpdateAllowed: Bool = true
    
    var updateRequestedSubject = PassthroughSubject<String, Never>()
    
    var isOldOrEmpty: Bool {
        #warning("include history!!!")
        return currentByCountry.isEmpty || currentByCountry.isOld
    }
    
    init() {
        
        currentByCountry = Present.load(type: .byCountry, from: currentByCountryFilename)
        currentByRegion  = Present.load(type: .byRegion, from: currentByRegionFilename)
        
        currentByCountryLastUpdated = currentByCountry.lastFetchDate.hoursMunutesTillNowNice
        
        createSubs()
        
        #warning("count new and current cases is called separately in countNewAndPresent()")
    }
    
    func createSubs() {
        
        updateRequestedSubject
            .sink { _ in
                print("updateRequestedSubject - didSet FIRED")
                self.isUpdateAllowed = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2 * 60) {
                    self.isUpdateAllowed = true
                }
        }
        .store(in: &cancellables)
        
        
        Timer.publish(every: 30, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.currentByCountryLastUpdated = self.currentByCountry.lastFetchDate.hoursMunutesTillNowNice
        }
        .store(in: &cancellables)
        
        
        #warning("$currentByRegion заменить на History")
        Publishers.CombineLatest($currentByCountry, $currentByRegion)
            .sink {_ in
                self.calculateOutbreak()
        }
        .store(in: &cancellables)
        
        
        updateRequestedSubject//$isUpdateRequested
            //  .print(">>>>> $isUpdateRequested - fetchCoronaResponseErr")
            .setFailureType(to: FetchError.self)
            .flatMap { _ in
                self.johnHopkinsAPI.fetchCoronaResponseErr(url: self.currentByCountry.endpoint.url)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [unowned self] (completion) in
                if case let .failure(error) = completion {
                    print("from Country SUB: recieved error")
                    self.currentByCountry.fetchError = error
                }},
            receiveValue: { [unowned self] in
                print("from Country SUB: non-empty CoronaResponse recieved")
                let current = Present(type: .byCountry, response: $0)
                self.currentByCountry = current
                print("from Country SUB: update completed, cases count: \(self.currentByCountry.cases.count)")
                self.currentByCountryLastUpdated = self.currentByCountry.lastFetchDate.hoursMunutesTillNowNice
                self.currentByCountry.save(to: self.currentByCountryFilename)
                //  self.calculateOutbreak()
        })
            .store(in: &cancellables)
        
        
        updateRequestedSubject//$isUpdateRequested
            //  .print(">>>>> $isUpdateRequested - fetchCoronaResponseErr")
            .setFailureType(to: FetchError.self)
            .flatMap { _ in
                self.johnHopkinsAPI.fetchCoronaResponseErr(url: self.currentByRegion.endpoint.url)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [unowned self] (completion) in
                if case let .failure(error) = completion {
                    print("from Region SUB: recieved error")
                    self.currentByRegion.fetchError = error
                }},
            receiveValue: { [unowned self] in
                print("from Region SUB: non-empty CoronaResponse recieved")
                let current = Present(type: .byRegion, response: $0)
                self.currentByRegion = current
                print("from Region SUB: update completed, cases count: \(self.currentByRegion.cases.count)")
                self.currentByRegion.save(to: self.currentByRegionFilename)
                //  self.calculateOutbreak()
        })
            .store(in: &cancellables)
    }
    
    func calculateOutbreak() {
        #warning("calculate Outbreak! NEED HISTORY HERE")
        
        print("\(self.currentByCountry.name) \(self.currentByCountry.isEmpty ? "is empty" : "is not empty"), \(self.currentByRegion.name) \(self.currentByRegion.isEmpty ? "is empty" : "is not empty")")
        
        guard self.currentByCountry.isNotEmpty && self.currentByRegion.isNotEmpty else {
            print("can't calculate Outbreak\n")
            return
        }
        
        print("ready to calc Outbreak\n")
    }
    
    var cancellables = [AnyCancellable]()
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
}


struct TestLocalJSONPublisher: View {
    @ObservedObject private var testing = TestingCorona()
    
    //    @State private var isUpdateAllowed = true
    
    var body: some View {
        VStack {
            Text("currentByCountry rows: \(testing.currentByCountry.cases.count)")
            
            Text(testing.fetchStr)
                .foregroundColor(testing.currentByCountry.isFetchOK ?? false
                    ? .systemGreen
                    : .secondary
            )
                .opacity(testing.currentByCountry.isFetchOK ?? false
                    ? 0.75
                    : 1
            )
                .font(.caption)
            
            testing.currentByCountry.fetchError == nil
                ? nil
                : Text(testing.currentByCountry.fetchError!.localizedDescription)
                    .foregroundColor(.secondary)
                    .font(.caption)
            
            Divider()
            
            Text("currentByRegion rows: \(testing.currentByRegion.cases.count)")
            
            Divider()
            
            Button(testing.isUpdateAllowed
                ? "Update"
                : "Please wait before next update"
            ) {
                self.testing.updateRequestedSubject.send("Update")
            }
            .disabled(!testing.isUpdateAllowed)
            
            Divider()
            
            Button("Delete JSONs") {
                self.deleteJSONs()
            }
            .foregroundColor(.systemRed)
        }
        .onAppear {
            if self.testing.isOldOrEmpty {
                print("need update - empty or old")
                self.testing.updateRequestedSubject.send("Update")
            }
        }
    }
    
    func deleteJSONs() {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            do {
                let fileURLs = try FileManager.default
                    .contentsOfDirectory(at: documentsUrl,
                                         includingPropertiesForKeys: nil,
                                         options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                for fileURL in fileURLs {
                    if fileURL.pathExtension == "json" {
                        print("deleteing \(fileURL)")
                        try FileManager.default.removeItem(at: fileURL)
                    }
                }
            } catch {
                print(error)
            }
        } else {
            print("error getting Document Directory")
        }
    }
}


struct TestLocalJSONPublisher_Previews: PreviewProvider {
    static var previews: some View {
        TestLocalJSONPublisher()
    }
}
