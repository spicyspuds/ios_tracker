import SwiftUI
import UIKit

struct FoodScannerView: View {
    @Binding var isPresented: Bool
    @State private var capturedImage: UIImage?
    @State private var showingImagePicker = true
    @State private var showingResults = false
    @State private var processingImage = false
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
            
            if showingImagePicker {
                CameraImagePicker(isPresented: $showingImagePicker, image: $capturedImage, onImageCaptured: {
                    processingImage = true
                    // When image is captured, we'll analyze it
                    analyzeImage()
                })
            } else if processingImage {
                // Show loading screen while processing
                VStack {
                    Text("Analyzing your meal...")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(15)
                            .padding()
                    }
                    
                    LoadingIndicator()
                        .frame(width: 100, height: 100)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(NeumorphicStyle.backgroundColor)
                        .shadow(color: NeumorphicStyle.shadowColor, radius: 10, x: 10, y: 10)
                        .shadow(color: NeumorphicStyle.lightColor, radius: 10, x: -10, y: -10)
                )
                .padding()
            } else if showingResults {
                // Show results for editing
                VStack(spacing: 20) {
                    Text("Scan Results")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(15)
                    }
                    
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
    }
    
    private func analyzeImage() {
        // This is a placeholder for the GPT-4o API integration
        // In a real implementation, you would:
        // 1. Convert the image to base64 or upload it
        // 2. Send it to the GPT-4o API
        // 3. Parse the response to get nutritional information
        
        // For now, we'll simulate a response after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate receiving data from GPT-4o
            self.foodName = "Chicken Salad"
            self.calories = "350"
            self.protein = "25"
            self.carbs = "15"
            self.fats = "12"
            
            self.processingImage = false
            self.showingResults = true
        }
    }
    
    private func saveFoodLog() {
        var foodLog = NutritionLog.defaultFoodLog()
        foodLog.name = foodName
        foodLog.calories = Double(calories) ?? 0
        foodLog.protein = Double(protein) ?? 0
        foodLog.carbs = Double(carbs) ?? 0
        foodLog.fats = Double(fats) ?? 0
        
        // Save the image data if available
        if let image = capturedImage,
           let imageData = image.jpegData(compressionQuality: 0.7) {
            foodLog.imageData = imageData
        }
        
        nutritionStore.addLog(foodLog)
    }
}

struct CameraImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var image: UIImage?
    var onImageCaptured: () -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraImagePicker
        
        init(_ parent: CameraImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onImageCaptured()
            }
            
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

struct LoadingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.blue.opacity(0.7))
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .opacity(isAnimating ? 1 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever()
                            .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
} 