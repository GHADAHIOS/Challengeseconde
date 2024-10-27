import SwiftUI

class LearningViewModel: ObservableObject {
    // استخدام AppStorage لحفظ البيانات حتى بعد إغلاق التطبيق
    @AppStorage("learningGoal") var learningGoal: String = ""
    @AppStorage("learningDuration") var learningDuration: String = "Week"

    // متغير مؤقت للهدف في صفحة التسجيل
    @Published var inputText: String = ""
    
    // دالة لتحديث الهدف والمدة
    func updateLearningGoal() {
        learningGoal = inputText
    }
    
    func setDuration(_ duration: String) {
        learningDuration = duration
    }
}
