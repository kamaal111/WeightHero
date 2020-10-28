//
//  ContentView.swift
//  WeightHero
//
//  Created by Kamaal Farah on 28/10/2020.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    var body: some View {
        Button(action: fetchHealthData) {
            Text("Fetch data")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)

        }
        .frame(width: 350, height: 150)
        .background(Color.black)
        .cornerRadius(40)
        .border(Color.black)
        .cornerRadius(40)
    }

    func fetchHealthData() -> Void {
        let healthStore = HKHealthStore()
        if HKHealthStore.isHealthDataAvailable() {
            let readData = Set([
                HKObjectType.quantityType(forIdentifier: .bodyMass)!
            ])
            healthStore.requestAuthorization(toShare: [], read: readData) { (success: Bool, error: Error?) in
                if success {
                    let calendar = NSCalendar.current
                    var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)
                    let offset = (7 + anchorComponents.weekday! - 2) % 7
                    anchorComponents.day! -= offset
                    anchorComponents.hour = 2
                    guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
                        fatalError("*** unable to create a valid date from the given components ***")
                    }
                    let interval = NSDateComponents()
                    interval.minute = 30
                    let endDate = Date()
                    guard let startDate = calendar.date(byAdding: .month, value: -12, to: endDate) else {
                        fatalError("*** Unable to calculate the start date ***")
                    }
                    guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass) else {
                        fatalError("*** Unable to create a step count type ***")
                    }
                    let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                            quantitySamplePredicate: nil,
                                                            options: .discreteAverage,
                                                            anchorDate: anchorDate,
                                                            intervalComponents: interval as DateComponents)
                    query.initialResultsHandler = { (query: HKStatisticsCollectionQuery, results: HKStatisticsCollection?, error: Error?) in
                        guard let statsCollection = results else {
                            fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
                            
                        }
                        statsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics: HKStatistics, stop: UnsafeMutablePointer<ObjCBool>) in
                            if let quantity = statistics.averageQuantity() {
                                let date = statistics.startDate
                                let value = quantity.doubleValue(for: HKUnit(from: "kg"))
                                print(value)
                                print(date)
                            }
                        }
                        
                    }
                    healthStore.execute(query)
                } else {
                    print("Authorization failed")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
