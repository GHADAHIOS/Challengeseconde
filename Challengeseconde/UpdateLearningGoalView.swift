import SwiftUI

struct UpdateLearningGoalView: View {
    @Environment(\.presentationMode) var presentationMode // للوصول إلى presentationMode للتحكم في التنقل
    @State private var learningGoal: String = "" // الهدف الافتراضي للتعلم، مبدئيًا فارغ
    @State private var selectedDuration: String = "Month" // المدة الافتراضية
    
    let durations = ["Week", "Month", "Year"] // الخيارات المتاحة للمدة

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            // عنوان الصفحة وأزرار التنقل
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // يرجع إلى الصفحة السابقة
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.orange)
                        Text("Back")
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Text("Learning goal")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Update") {
                    // هنا يمكنك إضافة كود لتحديث الهدف والمدة
                }
                .foregroundColor(.orange)
                .bold() // جعل النص غامق
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // باقي المحتوى مع إزاحة بسيطة لليمين
            VStack(alignment: .leading, spacing: 20) {
                // إدخال الهدف
                Text("I want to learn")
                    .font(.title3)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                ZStack(alignment: .leading) {
                    if learningGoal.isEmpty {
                        Text("swift")
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                    }
                    TextField("", text: $learningGoal)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                        .accentColor(.orange) // لون المؤشر
                }
                
                // اختيار المدة
                Text("I want to learn it in a")
                    .font(.title3)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                durationSelectionButtons // استخدام دالة لتوليد أزرار المدة
                Spacer()
            }
            .padding(.leading, 15) // إزاحة خفيفة لليمين
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    // دالة لتوليد أزرار اختيار المدة
    private var durationSelectionButtons: some View {
        HStack(spacing: 12) {
            ForEach(durations, id: \.self) { duration in
                Button(action: {
                    selectedDuration = duration
                }) {
                    Text(duration)
                        .foregroundColor(selectedDuration == duration ? .black : .orange)
                        .fontWeight(selectedDuration == duration ? .bold : .regular)
                        .padding(10)
                        .background(selectedDuration == duration ? Color.orange : Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct UpdateLearningGoalView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateLearningGoalView()
    }
}
