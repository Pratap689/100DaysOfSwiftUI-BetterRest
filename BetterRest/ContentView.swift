//
//  ContentView.swift
//  BetterRest
//
//  Created by Pratap Rana on 20/02/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUpTime = defaultWakeUpTime
    @State private var hoursSleep = 8.0
    @State private var coffeeAmount = 8
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var showAlert = false
    static var defaultWakeUpTime: Date {
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0
        return Calendar.current.date(from: dateComponents) ?? Date.now
    }
    var body: some View {
        NavigationView {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter the time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section("When you want to wake up?") {
                    Stepper("\(hoursSleep.formatted()) hours", value: $hoursSleep, in: 4...24, step: 0.25)
                }
                
                Section("How much coffee do you intake in a day?") {
                    Picker(coffeeAmount == 0 ? "1 cup": "\(coffeeAmount) cups", selection: $coffeeAmount) {
                        ForEach(0..<20) { cup in
                           Text("\(cup)")
                        }
                    }
                   // Stepper(coffeeAmount == 0 ? "1 cup": "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
            }.navigationTitle("Better Rest")
                .toolbar {
                    Button("Calculate", action: calculate)
                }
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("OK") {}
                } message: {
                    Text(alertMessage)
                }
        }
    }
    
    func calculate() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hours = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hours + minutes), estimatedSleep: hoursSleep, coffee: Double(coffeeAmount))
            let sleepTime = wakeUpTime - prediction.actualSleep
            alertTitle = "Your bed time is"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "There is some problem while calculating your badtime"
        }
        
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
