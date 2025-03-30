import SwiftUI

struct ManualFoodLogView: View {
    @Binding var isPresented: Bool
    @State private var foodName = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fats = ""
    @EnvironmentObject var nutritionStore: NutritionStore
    
    var body: some View {
        ZStack {
            NeumorphicStyle.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Log Food")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                // Food name input
                VStack(alignment: .leading) {
                    Text("Food Name")
                        .foregroundColor(.gray)
                    TextField("Enter food name", text: $foodName)
                        .textFieldStyle(NeumorphicTextFieldStyle())
                }
                
                // Macro inputs
                HStack {
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .foregroundColor(.gray)
                        TextField("kcal", text: $calories)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Protein")
                            .foregroundColor(.gray)
                        TextField("g", text: $protein)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Carbs")
                            .foregroundColor(.gray)
                        TextField("g", text: $carbs)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Fats")
                            .foregroundColor(.gray)
                        TextField("g", text: $fats)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
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
                        saveFoodLog()
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
    
    private func saveFoodLog() {
        // Create and save a food log
        var foodLog = NutritionLog.defaultFoodLog()
        foodLog.name = foodName
        foodLog.calories = Double(calories) ?? 0
        foodLog.protein = Double(protein) ?? 0
        foodLog.carbs = Double(carbs) ?? 0
        foodLog.fats = Double(fats) ?? 0
        
        nutritionStore.addLog(foodLog)
    }
} 