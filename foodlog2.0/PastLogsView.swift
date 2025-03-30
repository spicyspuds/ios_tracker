import SwiftUI

struct PastLogsView: View {
    @EnvironmentObject var nutritionStore: NutritionStore
    @State private var searchText = ""
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var selectedLogId: UUID? = nil
    @State private var isNavigatingToDetail = false
    @Binding var selectedTab: Int
    
    var filteredLogs: [NutritionLog] {
        let dateFilteredLogs = nutritionStore.getLogsByDate(date: selectedDate)
        
        if searchText.isEmpty {
            return dateFilteredLogs
        } else {
            return dateFilteredLogs.filter { log in
                log.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                NeumorphicStyle.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header with date selector
                    HStack {
                        Text("Past Logs")
                            .font(.title)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showDatePicker.toggle()
                            }
                        }) {
                            HStack {
                                Text(formattedDate)
                                    .foregroundColor(.gray)
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(NeumorphicStyle.backgroundColor)
                                    .shadow(color: NeumorphicStyle.shadowColor, radius: 5, x: 5, y: 5)
                                    .shadow(color: NeumorphicStyle.lightColor, radius: 5, x: -5, y: -5)
                            )
                        }
                    }
                    .padding([.horizontal, .top])
                    
                    // Date Picker (when active)
                    if showDatePicker {
                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(NeumorphicStyle.backgroundColor)
                                    .shadow(color: NeumorphicStyle.shadowColor, radius: 8, x: 8, y: 8)
                                    .shadow(color: NeumorphicStyle.lightColor, radius: 8, x: -8, y: -8)
                            )
                            .padding(.horizontal)
                            .transition(.opacity)
                            .onChange(of: selectedDate) { oldValue, newValue in
                                withAnimation {
                                    showDatePicker = false
                                }
                            }
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search logs...", text: $searchText)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(NeumorphicStyle.backgroundColor)
                            .shadow(color: NeumorphicStyle.shadowColor, radius: 8, x: 8, y: 8)
                            .shadow(color: NeumorphicStyle.lightColor, radius: 8, x: -8, y: -8)
                    )
                    .padding(.horizontal)
                    
                    // Day summary
                    DaySummaryView(logs: filteredLogs)
                        .padding(.horizontal)
                    
                    // Logs List
                    if filteredLogs.isEmpty {
                        Spacer()
                        Text("No logs found for this day")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(filteredLogs) { log in
                                    GeometryReader { geometry in
                                        LogEntryRowView(log: log)
                                            .opacity(rowOpacity(for: geometry))
                                            .offset(x: rowOffset(for: geometry))
                                            .onTapGesture {
                                                selectedLogId = log.id
                                                isNavigatingToDetail = true
                                            }
                                    }
                                    .frame(height: 80)
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Fix the NavigationLink to avoid type conversion issue
                    if let id = selectedLogId {
                        NavigationLink(value: id) {
                            EmptyView()
                        }
                        .navigationDestination(for: UUID.self) { id in
                            LogDetailView(logId: id)
                        }
                    }
                }
            }
        }
    }
    
    private func rowOpacity(for geometry: GeometryProxy) -> Double {
        let minY = geometry.frame(in: .global).minY
        let maxY = geometry.frame(in: .global).maxY
        let screenHeight = UIScreen.main.bounds.height
        
        // Fade out when the row is less than 20% visible at top or bottom
        let topFadeThreshold = 100.0
        let bottomFadeThreshold = screenHeight - 180.0
        
        if minY < topFadeThreshold {
            return max(0, minY / topFadeThreshold)
        } else if maxY > bottomFadeThreshold {
            return max(0, (screenHeight - maxY) / (screenHeight - bottomFadeThreshold))
        }
        
        return 1.0
    }
    
    private func rowOffset(for geometry: GeometryProxy) -> Double {
        let minY = geometry.frame(in: .global).minY
        let maxY = geometry.frame(in: .global).maxY
        let screenHeight = UIScreen.main.bounds.height
        
        // Slide away when the row is less than 20% visible
        let topFadeThreshold = 100.0
        let bottomFadeThreshold = screenHeight - 180.0
        
        if minY < topFadeThreshold {
            return -30 * (1 - minY / topFadeThreshold)
        } else if maxY > bottomFadeThreshold {
            return 30 * (maxY - bottomFadeThreshold) / (screenHeight - bottomFadeThreshold)
        }
        
        return 0
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
}

struct DaySummaryView: View {
    let logs: [NutritionLog]
    
    private var totalCalories: Double {
        logs.reduce(0) { $0 + $1.calories }
    }
    
    private var totalProtein: Double {
        logs.reduce(0) { $0 + $1.protein }
    }
    
    private var totalCarbs: Double {
        logs.reduce(0) { $0 + $1.carbs }
    }
    
    private var totalFats: Double {
        logs.reduce(0) { $0 + $1.fats }
    }
    
    private var totalWater: Double {
        logs.filter { $0.type == .water }.reduce(0) { $0 + $1.waterAmount }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Day Summary")
                .font(.headline)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                SummaryItemView(value: Int(totalCalories), label: "Cal", color: .orange)
                SummaryItemView(value: Int(totalProtein), label: "Protein", color: .blue, unit: "g")
                SummaryItemView(value: Int(totalCarbs), label: "Carbs", color: .green, unit: "g")
                SummaryItemView(value: Int(totalFats), label: "Fats", color: .red, unit: "g")
            }
            
            // Water summary
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                Text("Water: \(totalWater, specifier: "%.2f")L")
                    .foregroundColor(.blue)
            }
            .padding(.top, 5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(NeumorphicStyle.backgroundColor)
                .shadow(color: NeumorphicStyle.shadowColor, radius: 8, x: 8, y: 8)
                .shadow(color: NeumorphicStyle.lightColor, radius: 8, x: -8, y: -8)
        )
    }
}

struct SummaryItemView: View {
    let value: Int
    let label: String
    let color: Color
    var unit: String = ""
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(value)\(unit)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct LogEntryRowView: View {
    let log: NutritionLog
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: log.date)
    }
    
    var body: some View {
        HStack {
            // Icon based on log type
            Image(systemName: log.type == .water ? "drop.fill" : "fork.knife")
                .foregroundColor(log.type == .water ? .blue : .gray)
                .font(.system(size: 24))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(log.name)
                    .font(.headline)
                    .foregroundColor(.gray)
                
                if log.type == .water {
                    Text("Water: \(log.waterAmount, specifier: "%.2f")L")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                } else {
                    HStack {
                        Text("Cal: \(Int(log.calories))")
                        Text("P: \(Int(log.protein))g")
                        Text("C: \(Int(log.carbs))g")
                        Text("F: \(Int(log.fats))g")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Time
            Text(formattedTime)
                .font(.caption)
                .foregroundColor(.gray)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(NeumorphicStyle.backgroundColor)
                .shadow(color: NeumorphicStyle.shadowColor, radius: 5, x: 5, y: 5)
                .shadow(color: NeumorphicStyle.lightColor, radius: 5, x: -5, y: -5)
        )
        .padding(.horizontal)
    }
} 
