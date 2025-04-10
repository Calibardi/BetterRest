//
//  ContentView.swift
//  BetterRest
//
//  Created by Lorenzo Ilardi on 09/04/25.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeUp
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var shouldShowAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    
    static private var defaultWakeUp: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    private var bedtime: String {
        return calculateBedtime()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mint.opacity(0.5)
                    .edgesIgnoringSafeArea(.bottom)
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("When do you want to wake up?")
                                .font(.headline)
                            
                            HStack {
                                Spacer()
                                DatePicker(
                                    "Please enter a time",
                                    selection: $wakeUp,
                                    displayedComponents: .hourAndMinute)
                                .labelsHidden()
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    Picker(selection: $coffeeAmount) {
                        ForEach(1...12, id: \.self) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    } label: {
                        Text("Daily coffee intake")
                            .font(.headline)
                    }
                    
                    Section {
                        HStack {
                            Spacer()
                            Text(bedtime)
                                .font(.largeTitle)
                            Spacer()
                        }
                        .frame(height: 100)
                    } header: {
                        Text("Ideal bed time")
                            .font(.headline)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("BetterRest")
                .alert(alertTitle, isPresented: $shouldShowAlert) {
                    Button("OK") { }
                } message: {
                    Text(alertMessage)
                }
                .padding()
            }
        }
    }
    
    private func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let prediction = try model.prediction(
                wake: getWakeUpTime(),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount))
            
            let sleepTime: Date = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch(let error) {
            alertTitle = "Error!"
            alertMessage = error.localizedDescription
            shouldShowAlert = true
            return ""
        }
    }
    
    private func getWakeUpTime() -> Double {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        return Double(hour + minute)
    }
}

#Preview {
    ContentView()
}
