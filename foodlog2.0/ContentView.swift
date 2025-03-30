//
//  ContentView.swift
//  foodlog
//
//  Created by Miguel Pereira on 2025-03-30.
//

import SwiftUI
import Foundation

struct NeumorphicStyle {
    static let backgroundColor = Color(red: 241/255, green: 243/255, blue: 248/255)
    static let shadowColor = Color.black.opacity(0.2)
    static let lightColor = Color.white.opacity(0.8)
    static let radius: CGFloat = 15
}

struct NeumorphicButton: View {
    let systemName: String
    let size: CGFloat
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            Image(systemName: systemName)
                .font(.system(size: size))
                .foregroundColor(.gray)
                .frame(width: size * 2, height: size * 2)
                .background(NeumorphicStyle.backgroundColor)
                .clipShape(Circle())
                .shadow(color: NeumorphicStyle.shadowColor,
                       radius: isPressed ? 4 : 8,
                       x: isPressed ? 4 : 8,
                       y: isPressed ? 4 : 8)
                .shadow(color: NeumorphicStyle.lightColor,
                       radius: isPressed ? 4 : 8,
                       x: isPressed ? -4 : -8,
                       y: isPressed ? -4 : -8)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

struct WaterLogModal: View {
    @Binding var isPresented: Bool
    @State private var waterAmount: Double = 0.25
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
                                }
                            }) {
                                Text("\(amount, specifier: "%.2f")L")
                                    .foregroundColor(.gray)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(NeumorphicStyle.backgroundColor)
                                            .shadow(color: waterAmount == amount ? NeumorphicStyle.shadowColor : .clear, radius: 5, x: 5, y: 5)
                                            .shadow(color: waterAmount == amount ? NeumorphicStyle.lightColor : .clear, radius: 5, x: -5, y: -5)
                                    )
                            }
                        }
                    }
                    .padding()
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
                        let waterLog = NutritionLog.defaultWaterLog(amount: waterAmount)
                        nutritionStore.addLog(waterLog)
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
}

struct ManualFoodLogModal: View {
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
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Protein")
                            .foregroundColor(.gray)
                        TextField("g", text: $protein)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Carbs")
                            .foregroundColor(.gray)
                        TextField("g", text: $carbs)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Fats")
                            .foregroundColor(.gray)
                        TextField("g", text: $fats)
                            .textFieldStyle(NeumorphicTextFieldStyle())
                            .keyboardType(.numberPad)
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
                        var foodLog = NutritionLog.defaultFoodLog()
                        foodLog.name = foodName
                        foodLog.calories = Double(calories) ?? 0
                        foodLog.protein = Double(protein) ?? 0
                        foodLog.carbs = Double(carbs) ?? 0
                        foodLog.fats = Double(fats) ?? 0
                        
                        nutritionStore.addLog(foodLog)
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
}

struct NeumorphicTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(NeumorphicStyle.backgroundColor)
                    .shadow(color: NeumorphicStyle.shadowColor, radius: 5, x: 5, y: 5)
                    .shadow(color: NeumorphicStyle.lightColor, radius: 5, x: -5, y: -5)
            )
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.presentationMode.wrappedValue.dismiss()
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
            parent.isPresented = false
        }
    }
}

// Add this enum at the top level, before ContentView
enum ActiveSheet: Identifiable {
    case camera, manualLog, waterLog
    
    var id: Int {
        switch self {
        case .camera: return 1
        case .manualLog: return 2
        case .waterLog: return 3
        }
    }
}

struct MenuButton: View {
    let icon: String
    @State private var isPressed = false
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(NeumorphicStyle.backgroundColor)
                .frame(width: 60, height: 60)
                .shadow(color: NeumorphicStyle.shadowColor,
                       radius: isPressed ? 4 : 8,
                       x: isPressed ? 4 : 8,
                       y: isPressed ? 4 : 8)
                .shadow(color: NeumorphicStyle.lightColor,
                       radius: isPressed ? 4 : 8,
                       x: isPressed ? -4 : -8,
                       y: isPressed ? -4 : -8)
                .scaleEffect(isPressed ? 0.95 : 1.0)
            
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.gray)
        }
    }
}

struct PopupMenu: View {
    @Binding var isShowing: Bool
    @Binding var showCamera: Bool
    @Binding var showManualLog: Bool
    @Binding var showWaterLog: Bool
    @State private var opacity: Double = 0
    @State private var buttonScale: Double = 0.1
    @State private var animationProgress: Double = 0
    
    // Positions for the radial menu
    private let radius: CGFloat = 85
    private let angles: [Double] = [205, 270, 335]
    
    private func position(for angle: Double, progress: Double) -> CGSize {
        let radians = angle * .pi / 180
        return CGSize(
            width: CGFloat(Foundation.cos(radians)) * radius * progress,
            height: CGFloat(Foundation.sin(radians)) * radius * progress
        )
    }
    
    var body: some View {
        ZStack {
            // Water Button (left)
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isShowing = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showWaterLog = true
                }
            } label: {
                MenuButton(icon: "drop") {}
            }
            .offset(position(for: angles[0], progress: animationProgress))
            .scaleEffect(buttonScale)
            
            // Manual Entry Button (middle)
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isShowing = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showManualLog = true
                }
            } label: {
                MenuButton(icon: "square.and.pencil") {}
            }
            .offset(position(for: angles[1], progress: animationProgress))
            .scaleEffect(buttonScale)
            
            // Camera Button (right)
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isShowing = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showCamera = true
                }
            } label: {
                MenuButton(icon: "camera") {}
            }
            .offset(position(for: angles[2], progress: animationProgress))
            .scaleEffect(buttonScale)
        }
        .opacity(opacity)
        .onAppear {
            // Initial state
            opacity = 0
            buttonScale = 0.1
            animationProgress = 0
            
            // First animation: fade in and scale up
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                opacity = 1
                buttonScale = 1.2
            }
            
            // Second animation: fan out
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)) {
                animationProgress = 1
            }
        }
    }
}

struct AccountView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var selectedUnit = 0
    
    var body: some View {
        ZStack {
            NeumorphicStyle.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Section
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("John Doe")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(NeumorphicStyle.backgroundColor)
                            .shadow(color: NeumorphicStyle.shadowColor, radius: 8, x: 8, y: 8)
                            .shadow(color: NeumorphicStyle.lightColor, radius: 8, x: -8, y: -8)
                    )
                    .padding()
                    
                    // Settings Sections
                    VStack(spacing: 20) {
                        SettingsSectionHeader(title: "Preferences")
                        
                        ToggleSettingRow(title: "Notifications", isOn: $notificationsEnabled)
                        ToggleSettingRow(title: "Dark Mode", isOn: $darkModeEnabled)
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        SettingsSectionHeader(title: "Units")
                        
                        Picker("Units", selection: $selectedUnit) {
                            Text("Imperial").tag(0)
                            Text("Metric").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(NeumorphicStyle.backgroundColor)
                                .shadow(color: NeumorphicStyle.shadowColor, radius: 5, x: 5, y: 5)
                                .shadow(color: NeumorphicStyle.lightColor, radius: 5, x: -5, y: -5)
                        )
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        // Action Buttons
                        VStack(spacing: 15) {
                            ActionButton(title: "Export Data", icon: "square.and.arrow.up")
                            ActionButton(title: "Privacy Policy", icon: "lock.shield")
                            ActionButton(title: "Terms of Service", icon: "doc.text")
                            ActionButton(title: "Log Out", icon: "arrow.right.square", isDestructive: true)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(NeumorphicStyle.backgroundColor)
                            .shadow(color: NeumorphicStyle.shadowColor, radius: 8, x: 8, y: 8)
                            .shadow(color: NeumorphicStyle.lightColor, radius: 8, x: -8, y: -8)
                    )
                    .padding()
                }
            }
        }
    }
}

struct SettingsSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ToggleSettingRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
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

struct ActionButton: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .foregroundColor(isDestructive ? .red : .gray)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(NeumorphicStyle.backgroundColor)
                    .shadow(color: NeumorphicStyle.shadowColor, radius: 5, x: 5, y: 5)
                    .shadow(color: NeumorphicStyle.lightColor, radius: 5, x: -5, y: -5)
            )
        }
    }
}

struct WaterProgressView: View {
    @EnvironmentObject var nutritionStore: NutritionStore
    private let dailyGoal: Double = 2.5 // Daily water goal in liters
    
    private var todayWaterAmount: Double {
        let todayLogs = nutritionStore.getLogsByDate(date: Date())
        return todayLogs.filter { $0.type == .water }.reduce(0) { $0 + $1.waterAmount }
    }
    
    private var progress: Double {
        min(todayWaterAmount / dailyGoal, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Water progress bar
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 12)
                    .fill(NeumorphicStyle.backgroundColor)
                    .frame(height: 24)
                    .shadow(color: NeumorphicStyle.shadowColor, radius: 4, x: 4, y: 4)
                    .shadow(color: NeumorphicStyle.lightColor, radius: 4, x: -4, y: -4)
                
                // Water fill
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: UIScreen.main.bounds.width * 0.7 * progress, height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                    )
            }
            .frame(width: UIScreen.main.bounds.width * 0.7)
            
            // Water info
            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue.opacity(0.7))
                    .font(.system(size: 14))
                
                Text("\(todayWaterAmount, specifier: "%.1f")L / \(dailyGoal, specifier: "%.1f")L")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 10)
    }
}

// Add this new view before ContentView
struct PageIndicator: View {
    let currentPage: Int
    let numberOfPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.gray : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.bottom, 20)
    }
}

struct ContentView: View {
    @StateObject private var nutritionStore = NutritionStore()
    @State private var showingAddMenu = false
    @State private var selectedTab = 1
    @State private var addButtonScale: CGFloat = 1.0
    @State private var showingCamera = false
    @State private var showingManualLog = false
    @State private var showingWaterLog = false
    
    var body: some View {
        ZStack {
            NeumorphicStyle.backgroundColor
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Past Logs View
                PastLogsView(selectedTab: $selectedTab)
                    .tag(0)
                
                // Main View (current view)
                VStack(spacing: 20) {
                    MacrosPieChartView()
                        .padding(.top, 60)
                    
                    WaterProgressView()
                    
                    Spacer()
                }
                .tag(1)
                
                // Account View
                AccountView()
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
            
            // Page Indicator - Only show on side pages
            if selectedTab != 1 {
                VStack {
                    Spacer()
                    PageIndicator(currentPage: selectedTab, numberOfPages: 3)
                }
            }
            
            // Bottom Navigation Bar - Only show on main view
            if selectedTab == 1 {
                VStack {
                    Spacer()
                    ZStack {
                        HStack(spacing: 60) {
                            // Past Logs Button
                            NeumorphicButton(systemName: "clock.arrow.circlepath", size: 24) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = 0
                                }
                            }
                            .opacity(showingAddMenu ? 0 : 1)
                            
                            // Placeholder for plus button spacing
                            Color.clear
                                .frame(width: 80, height: 80)
                            
                            // Account Button
                            NeumorphicButton(systemName: "person", size: 24) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = 2
                                }
                            }
                            .opacity(showingAddMenu ? 0 : 1)
                        }
                        
                        // Add Button and Popup Menu
                        ZStack {
                            if showingAddMenu {
                                PopupMenu(
                                    isShowing: $showingAddMenu,
                                    showCamera: $showingCamera,
                                    showManualLog: $showingManualLog,
                                    showWaterLog: $showingWaterLog
                                )
                            }
                            
                            // Add Button (larger)
                            NeumorphicButton(systemName: "plus", size: 40) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showingAddMenu.toggle()
                                }
                            }
                            .scaleEffect(addButtonScale)
                            .rotationEffect(.degrees(showingAddMenu ? 45 : 0))
                            .onAppear {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever()) {
                                    addButtonScale = 1.05
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .environmentObject(nutritionStore)
        .fullScreenCover(isPresented: $showingCamera) {
            FoodScannerView(isPresented: $showingCamera)
        }
        .sheet(isPresented: $showingManualLog) {
            ManualFoodLogView(isPresented: $showingManualLog)
        }
        .sheet(isPresented: $showingWaterLog) {
            WaterLogView(isPresented: $showingWaterLog)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NutritionStore())
            .previewDevice("iPhone 16 Pro")
    }
}
