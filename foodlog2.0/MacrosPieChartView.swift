import SwiftUI

struct MacrosPieChartView: View {
    @EnvironmentObject var nutritionStore: NutritionStore
    @State private var rotation: Double = 0
    @State private var selectedSegment: MacroType?
    
    private var todayLogs: [NutritionLog] {
        nutritionStore.getLogsByDate(date: Date())
    }
    
    private var totalCalories: Double {
        todayLogs.reduce(0) { $0 + $1.calories }
    }
    
    private var totalProtein: Double {
        todayLogs.reduce(0) { $0 + $1.protein }
    }
    
    private var totalCarbs: Double {
        todayLogs.reduce(0) { $0 + $1.carbs }
    }
    
    private var totalFats: Double {
        todayLogs.reduce(0) { $0 + $1.fats }
    }
    
    private var totalWater: Double {
        todayLogs.filter { $0.type == .water }.reduce(0) { $0 + $1.waterAmount }
    }
    
    private var proteinCalories: Double {
        totalProtein * 4 // 4 calories per gram of protein
    }
    
    private var carbsCalories: Double {
        totalCarbs * 4 // 4 calories per gram of carbs
    }
    
    private var fatsCalories: Double {
        totalFats * 9 // 9 calories per gram of fat
    }
    
    private var hasData: Bool {
        totalCalories > 0
    }
    
    enum MacroType: String, CaseIterable {
        case protein = "Protein"
        case carbs = "Carbs"
        case fats = "Fats"
        
        var color: Color {
            switch self {
            case .protein: return .blue
            case .carbs: return .green
            case .fats: return .red
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Circle background
            Circle()
                .fill(NeumorphicStyle.backgroundColor)
                .frame(width: 250, height: 250)
                .shadow(color: NeumorphicStyle.shadowColor, radius: 10, x: 10, y: 10)
                .shadow(color: NeumorphicStyle.lightColor, radius: 10, x: -10, y: -10)
            
            if hasData {
                // Pie chart
                ZStack {
                    // Protein segment
                    PieSegment(
                        startAngle: .degrees(0),
                        endAngle: .degrees(proteinPercentage * 360),
                        color: MacroType.protein.color
                    )
                    .opacity(selectedSegment == nil || selectedSegment == .protein ? 1.0 : 0.3)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedSegment = selectedSegment == .protein ? nil : .protein
                        }
                    }
                    
                    // Carbs segment
                    PieSegment(
                        startAngle: .degrees(proteinPercentage * 360),
                        endAngle: .degrees((proteinPercentage + carbsPercentage) * 360),
                        color: MacroType.carbs.color
                    )
                    .opacity(selectedSegment == nil || selectedSegment == .carbs ? 1.0 : 0.3)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedSegment = selectedSegment == .carbs ? nil : .carbs
                        }
                    }
                    
                    // Fats segment
                    PieSegment(
                        startAngle: .degrees((proteinPercentage + carbsPercentage) * 360),
                        endAngle: .degrees(360),
                        color: MacroType.fats.color
                    )
                    .opacity(selectedSegment == nil || selectedSegment == .fats ? 1.0 : 0.3)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedSegment = selectedSegment == .fats ? nil : .fats
                        }
                    }
                }
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        rotation = 360
                    }
                }
                
                // Inner circle with calorie info
                Circle()
                    .fill(NeumorphicStyle.backgroundColor)
                    .frame(width: 120, height: 120)
                    .shadow(color: NeumorphicStyle.shadowColor.opacity(0.3), radius: 5, x: 5, y: 5)
                    .shadow(color: NeumorphicStyle.lightColor.opacity(0.3), radius: 5, x: -5, y: -5)
                    .overlay(
                        VStack {
                            if let selected = selectedSegment {
                                Text(selected.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                let value = selected == .protein ? totalProtein : (selected == .carbs ? totalCarbs : totalFats)
                                let percentage = selected == .protein ? proteinPercentage : (selected == .carbs ? carbsPercentage : fatsPercentage)
                                
                                Text("\(Int(value))g")
                                    .font(.title3)
                                    .foregroundColor(selected.color)
                                
                                Text("\(Int(percentage * 100))%")
                                    .font(.caption)
                                    .foregroundColor(selected.color)
                            } else {
                                Text("Calories")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("\(Int(totalCalories))")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                            }
                        }
                    )
            } else {
                // No data yet
                VStack {
                    Text("No data")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Add food to see\nyour macros")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
        }
        
        // Macro legends
        VStack(spacing: 5) {
            HStack(spacing: 20) {
                ForEach(MacroType.allCases, id: \.self) { type in
                    HStack {
                        Circle()
                            .fill(type.color)
                            .frame(width: 10, height: 10)
                        Text(type.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Water consumption
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                
                Text("Water: \(totalWater, specifier: "%.1f")L")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 10)
    }
    
    private var proteinPercentage: Double {
        let total = proteinCalories + carbsCalories + fatsCalories
        return total > 0 ? proteinCalories / total : 0.33
    }
    
    private var carbsPercentage: Double {
        let total = proteinCalories + carbsCalories + fatsCalories
        return total > 0 ? carbsCalories / total : 0.33
    }
    
    private var fatsPercentage: Double {
        let total = proteinCalories + carbsCalories + fatsCalories
        return total > 0 ? fatsCalories / total : 0.34
    }
}

struct PieSegment: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                
                path.move(to: center)
                path.addArc(center: center,
                           radius: radius,
                           startAngle: startAngle,
                           endAngle: endAngle,
                           clockwise: false)
                path.closeSubpath()
            }
            .fill(color)
        }
    }
} 