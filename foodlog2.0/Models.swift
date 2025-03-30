import Foundation

struct NutritionLog: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var type: LogType
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fats: Double
    var waterAmount: Double
    var imageData: Data?
    
    enum LogType: String, Codable {
        case food
        case water
    }
    
    static func defaultWaterLog(amount: Double) -> NutritionLog {
        NutritionLog(
            date: Date(),
            type: .water,
            name: "Water",
            calories: 0,
            protein: 0,
            carbs: 0,
            fats: 0,
            waterAmount: amount
        )
    }
    
    static func defaultFoodLog() -> NutritionLog {
        NutritionLog(
            date: Date(),
            type: .food,
            name: "",
            calories: 0,
            protein: 0,
            carbs: 0,
            fats: 0,
            waterAmount: 0
        )
    }
}

class NutritionStore: ObservableObject {
    @Published var logs: [NutritionLog] = []
    
    private let saveKey = "NutritionLogs"
    
    init() {
        loadLogs()
    }
    
    func addLog(_ log: NutritionLog) {
        logs.append(log)
        saveLogs()
    }
    
    func updateLog(id: UUID, with newLog: NutritionLog) {
        if let index = logs.firstIndex(where: { $0.id == id }) {
            logs[index] = newLog
            saveLogs()
        }
    }
    
    func deleteLog(id: UUID) {
        logs.removeAll { $0.id == id }
        saveLogs()
    }
    
    func getLogsByDate(date: Date) -> [NutritionLog] {
        let calendar = Calendar.current
        return logs.filter { log in
            calendar.isDate(log.date, inSameDayAs: date)
        }
    }
    
    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([NutritionLog].self, from: data) {
                logs = decoded
                return
            }
        }
        
        logs = []
    }
} 