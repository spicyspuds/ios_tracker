import SwiftUI

struct LogDetailView: View {
    let logId: UUID
    @EnvironmentObject var nutritionStore: NutritionStore
    @Environment(\.presentationMode) var presentationMode
    @State private var isEditing = false
    
    // Editable states
    @State private var editName = ""
    @State private var editCalories = ""
    @State private var editProtein = ""
    @State private var editCarbs = ""
    @State private var editFats = ""
    @State private var editWaterAmount = ""
    
    var log: NutritionLog? {
        nutritionStore.logs.first { $0.id == logId }
    }
    
    var body: some View {
        ZStack {
            NeumorphicStyle.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text(formattedDate)
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                if isEditing {
                                    saveChanges()
                                }
                                isEditing.toggle()
                            }
                        }) {
                            Image(systemName: isEditing ? "checkmark" : "pencil")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(NeumorphicStyle.backgroundColor)
                                        .shadow(color: NeumorphicStyle.shadowColor, radius: 4, x: 4, y: 4)
                                        .shadow(color: NeumorphicStyle.lightColor, radius: 4, x: -4, y: -4)
                                )
                        }
                        
                        Button(action: {
                            deleteLog()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 20))
                                .foregroundColor(.red.opacity(0.8))
                                .padding()
                                .background(
                                    Circle()
                                        .fill(NeumorphicStyle.backgroundColor)
                                        .shadow(color: NeumorphicStyle.shadowColor, radius: 4, x: 4, y: 4)
                                        .shadow(color: NeumorphicStyle.lightColor, radius: 4, x: -4, y: -4)
                                )
                        }
                    }
                    .padding()
                    
                    if let log = log {
                        // Display image if available
                        if let imageData = log.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(15)
                                .padding(.horizontal)
                        }
                        
                        // Content based on log type
                        if log.type == .water {
                            waterLogDetail(log: log)
                        } else {
                            foodLogDetail(log: log)
                        }
                    } else {
                        Text("Log not found")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
        }
        .onAppear {
            loadEditValues()
        }
    }
    
    private var formattedDate: String {
        if let log = log {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: log.date)
        }
        return ""
    }
    
    private func waterLogDetail(log: NutritionLog) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "drop.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding()
            
            if isEditing {
                VStack(alignment: .leading) {
                    Text("Water Amount (L)")
                        .foregroundColor(.gray)
                    TextField("Water amount", text: $editWaterAmount)
                        .textFieldStyle(NeumorphicTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                .padding()
            } else {
                Text("Water Amount: \(log.waterAmount, specifier: "%.2f")L")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(NeumorphicStyle.backgroundColor)
                .shadow(color: NeumorphicStyle.shadowColor, radius: 8, x: 8, y: 8)
                .shadow(color: NeumorphicStyle.lightColor, radius: 8, x: -8, y: -8)
        )
        .padding(.horizontal)
    }
    
    private func foodLogDetail(log: NutritionLog) -> some View {
        VStack(spacing: 15) {
            if isEditing {
                // Editable fields
                VStack(alignment: .leading) {
                    Text("Food Name")
                        .foregroundColor(.gray)
                    TextField("Food name", text: $editName)
                        .textFieldStyle(NeumorphicTextFieldStyle())
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .foregroundColor(.gray)
                        TextField("kcal", text: $editCalories)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Protein")
                            .foregroundColor(.gray)
                        TextField("g", text: $editProtein)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Carbs")
                            .foregroundColor(.gray)
                        TextField("g", text: $editCarbs)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Fats")
                            .foregroundColor(.gray)
                        TextField("g", text: $editFats)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
            } else {
                // Display fields
                Text(log.name)
                    .font(.title)
                    .foregroundColor(.gray)
                
                HStack(spacing: 30) {
                    NutrientCircle(value: Int(log.calories), label: "Calories", color: .orange)
                    NutrientCircle(value: Int(log.protein), label: "Protein", color: .blue, unit: "g")
                }
                
                HStack(spacing: 30) {
                    NutrientCircle(value: Int(log.carbs), label: "Carbs", color: .green, unit: "g")
                    NutrientCircle(value: Int(log.fats), label: "Fats", color: .red, unit: "g")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(NeumorphicStyle.backgroundColor)
                .shadow(color: NeumorphicStyle.shadowColor, radius: 8, x: 8, y: 8)
                .shadow(color: NeumorphicStyle.lightColor, radius: 8, x: -8, y: -8)
        )
        .padding(.horizontal)
    }
    
    private func loadEditValues() {
        guard let log = log else { return }
        
        editName = log.name
        editCalories = String(format: "%.0f", log.calories)
        editProtein = String(format: "%.0f", log.protein)
        editCarbs = String(format: "%.0f", log.carbs)
        editFats = String(format: "%.0f", log.fats)
        editWaterAmount = String(format: "%.2f", log.waterAmount)
    }
    
    private func saveChanges() {
        guard let currentLog = log else { return }
        
        var updatedLog = currentLog
        
        if currentLog.type == .water {
            updatedLog.waterAmount = Double(editWaterAmount) ?? currentLog.waterAmount
        } else {
            updatedLog.name = editName
            updatedLog.calories = Double(editCalories) ?? currentLog.calories
            updatedLog.protein = Double(editProtein) ?? currentLog.protein
            updatedLog.carbs = Double(editCarbs) ?? currentLog.carbs
            updatedLog.fats = Double(editFats) ?? currentLog.fats
        }
        
        nutritionStore.updateLog(id: currentLog.id, with: updatedLog)
    }
    
    private func deleteLog() {
        if let logId = log?.id {
            nutritionStore.deleteLog(id: logId)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct NutrientCircle: View {
    let value: Int
    let label: String
    let color: Color
    var unit: String = ""
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(NeumorphicStyle.backgroundColor)
                    .frame(width: 80, height: 80)
                    .shadow(color: NeumorphicStyle.shadowColor, radius: 5, x: 5, y: 5)
                    .shadow(color: NeumorphicStyle.lightColor, radius: 5, x: -5, y: -5)
                
                Text("\(value)\(unit)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
} 