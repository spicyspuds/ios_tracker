import SwiftUI

struct WaterLogView: View {
    @Binding var isPresented: Bool
    @State private var waterAmount: Double = 0.25
    @State private var customAmount: String = ""
    @State private var showingCustomInput = false
    @EnvironmentObject var nutritionStore: NutritionStore
    
    let amounts = [0.25, 0.5, 0.75, 1.0, 1.5, 2.0]
    
    var body: some View {
        ZStack {
            NeumorphicStyle.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("Log Water Intake")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Image(systemName: "drop.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding()
                
                Text("\(waterAmount, specifier: "%.2f")L")
                    .font(.title)
                    .foregroundColor(.gray)
                
                // Water amount picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(amounts, id: \.self) { amount in
                            Button(action: {
                                withAnimation(.spring()) {
                                    waterAmount = amount
                                    showingCustomInput = false
                                }
                            }) {
                                Text("\(amount, specifier: "%.2f")L")
                                    .foregroundColor(.gray)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(NeumorphicStyle.backgroundColor)
                                            .shadow(color: !showingCustomInput && waterAmount == amount ? NeumorphicStyle.shadowColor : .clear, radius: 5, x: 5, y: 5)
                                            .shadow(color: !showingCustomInput && waterAmount == amount ? NeumorphicStyle.lightColor : .clear, radius: 5, x: -5, y: -5)
                                    )
                            }
                        }
                        
                        // Custom amount button
                        Button(action: {
                            withAnimation(.spring()) {
                                showingCustomInput = true
                                customAmount = String(format: "%.2f", waterAmount)
                            }
                        }) {
                            Text("Custom")
                                .foregroundColor(.gray)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(NeumorphicStyle.backgroundColor)
                                        .shadow(color: showingCustomInput ? NeumorphicStyle.shadowColor : .clear, radius: 5, x: 5, y: 5)
                                        .shadow(color: showingCustomInput ? NeumorphicStyle.lightColor : .clear, radius: 5, x: -5, y: -5)
                                )
                        }
                    }
                    .padding()
                }
                
                // Custom amount input field
                if showingCustomInput {
                    VStack {
                        TextField("Amount in liters", text: $customAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .padding(.horizontal)
                            .onChange(of: customAmount) { oldValue, newValue in
                                if let amount = Double(newValue), amount > 0 {
                                    waterAmount = amount
                                }
                            }
                        
                        Text("Tap outside to confirm")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .transition(.opacity)
                }
                
                HStack(spacing: 20) {
                    // Cancel Button
                    Button(action: {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }) {
                        Text("Cancel")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(NeumorphicStyle.backgroundColor)
                                    .shadow(color: NeumorphicStyle.shadowColor, radius: 5, x: 5, y: 5)
                                    .shadow(color: NeumorphicStyle.lightColor, radius: 5, x: -5, y: -5)
                            )
                    }
                    
                    // Save Button
                    Button(action: {
                        saveWaterIntake()
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }) {
                        Text("Save")
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(NeumorphicStyle.backgroundColor)
                                    .shadow(color: NeumorphicStyle.shadowColor, radius: 5, x: 5, y: 5)
                                    .shadow(color: NeumorphicStyle.lightColor, radius: 5, x: -5, y: -5)
                            )
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(NeumorphicStyle.backgroundColor)
                    .shadow(color: NeumorphicStyle.shadowColor, radius: 10, x: 10, y: 10)
                    .shadow(color: NeumorphicStyle.lightColor, radius: 10, x: -10, y: -10)
            )
            .padding()
        }
    }
    
    private func saveWaterIntake() {
        // Create and add a water log to our nutrition store
        let waterLog = NutritionLog.defaultWaterLog(amount: waterAmount)
        nutritionStore.addLog(waterLog)
    }
} 