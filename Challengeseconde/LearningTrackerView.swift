import SwiftUI

struct LearningTrackerView: View {
    var learningSubject: String // الهدف المدخل
    var learningDuration: String // مدة التعلم: أسبوع، شهر، أو سنة
    @State private var streakDays = 0 // يبدأ العداد من الصفر
    @State private var frozenDays = 0 // عدد الأيام المجمدة
    @State private var selectedDayStatus: String = "log" // الحالة اليومية (تعلم، مجمد، تسجيل)
    @State private var currentWeek = 0 // الأسبوع الحالي
    @State private var currentDate = Date() // الشهر الحالي
    @State private var dayStatuses: [Int: String] = [:] // حالات الأيام السابقة
    private let calendar = Calendar.current

    let weeksInMonth = 4 // عدد الأسابيع المعروضة في الشهر

    // تنسيق التاريخ في الأعلى (مثل: "Saturday,26Oct")
    let topDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE,ddMMM"
        return formatter
    }()
    
    // تنسيق التاريخ في الأسفل (الشهر والسنة فقط)
    let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // لعرض الشهر والسنة فقط مثل "October 2024"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // الجزء العلوي (التاريخ والهدف)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(currentDate, formatter: topDateFormatter)")
                            .foregroundColor(.gray)
                            .font(.subheadline)

                        HStack {
                            Text("Learning \(learningSubject)")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)

                            Spacer()

                            // زر الانتقال إلى UpdateLearningGoalView
                            NavigationLink(destination: UpdateLearningGoalView()) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 44/255, green: 44/255, blue: 49/255))
                                        .frame(width: 60, height:60, alignment: .center)

                                    Text("🔥")
                                        .font(.system(size: 30))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // التقويم وعرض حالة الأيام المتتالية والتجميد
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(width: 360, height: 220)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )

                        VStack(spacing: 10.0) {
                            // جزء الشهر والسنة وأزرار التنقل
                            HStack {
                                Text("\(currentDate, formatter: monthYearFormatter)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                                
                                HStack(spacing: 25) {
                                    Button(action: previousWeek) {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(.orange)
                                    }
                                    
                                    Button(action: nextWeek) {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // عرض أيام الأسبوع حسب الأسبوع الحالي
                            HStack(spacing: 22) {
                                ForEach(weekDays(), id: \.self) { day in
                                    VStack {
                                        Text(dayOfWeek(for: day))
                                            .foregroundColor(.white)
                                            .font(.footnote)
                                            .fontWeight(isToday(day) ? .bold : .semibold)
                                        
                                        ZStack {
                                            Circle()
                                                .fill(dayBackground(for: day))
                                                .frame(width: 28, height: 28)
                                            
                                            Text("\(day)")
                                                .foregroundColor(dayForeground(for: day))
                                                .font(.system(size: 20, weight: isToday(day) ? .bold : .regular, design: .default))
                                        }
                                    }
                                }
                            }
                            .padding(.top, 5)
                            
                            Divider()
                                .frame(width: 360)
                                .background(Color.gray)
                                .padding(.vertical, 5)

                            HStack(spacing: 50) {
                                VStack {
                                    HStack {
                                        Text("\(streakDays)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("🔥")
                                            .foregroundColor(.orange)
                                    }
                                    Text("Day streak")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                
                                Divider()
                                    .frame(width: 1, height: 40)
                                    .background(Color.gray)
                                
                                VStack {
                                    HStack {
                                        Text("\(frozenDays)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("🧊")
                                            .foregroundColor(.blue)
                                    }
                                    Text("Day frozen")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 5)
                        }
                        .padding()
                    }
                    
                    // الدائرة الكبيرة لتسجيل التعلم أو عرض الحالة
                    ZStack {
                        Circle()
                            .fill(selectedDayStatus == "learned" ? Color.orange.opacity(0.5) :
                                  selectedDayStatus == "frozen" ? Color.blue.opacity(0.5) :
                                  Color.orange)
                            .frame(width: 320, height: 320)
                            .onTapGesture {
                                if selectedDayStatus == "log" {
                                    logTodayAsLearned()
                                }
                            }
                        
                        Text(selectedDayStatus == "learned" ? "Learned Today" :
                             selectedDayStatus == "frozen" ? "Day Freezed" :
                             "Log Today as Learned")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    // زر لتجميد اليوم
                    Button(action: freezeToday) {
                        Text("Freeze day")
                            .frame(width: 162, height: 52)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // عرض عدد الأيام المجمدة المتاحة
                    Text("\(frozenDays) out of \(availableFreezes()) freezes used")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
                .padding(.top, 30)
                .onAppear {
                    setInitialWeek()
                    resetStreakIfNeeded()
                }
                .onChange(of: learningSubject) { _ in
                    resetStreak() // إعادة تعيين السلسلة عند تغيير الهدف
                }
                .onChange(of: learningDuration) { _ in
                    resetStreak() // إعادة تعيين السلسلة عند تغيير المدة
                }
            }
        }
    }
    
    // تعيين الأسبوع الذي يحتوي على اليوم الحالي عند فتح الشاشة
    private func setInitialWeek() {
        let today = calendar.component(.day, from: Date())
        currentWeek = (today - 1) / 7
    }
    
    // عرض أيام الأسبوع بناءً على الأسبوع الحالي
    private func weekDays() -> [Int] {
        let startDay = currentWeek * 7 + 1
        return Array(startDay..<startDay + 7)
    }
    
    // التنقل بين الأسابيع
    private func nextWeek() {
        if currentWeek < weeksInMonth - 1 {
            currentWeek += 1
        }
    }
    
    private func previousWeek() {
        if currentWeek > 0 {
            currentWeek -= 1
        }
    }

    private func availableFreezes() -> Int {
        switch learningDuration {
        case "Week":
            return 2
        case "Month":
            return 6
        case "Year":
            return 60
        default:
            return 0
        }
    }
    
    private func dayBackground(for day: Int) -> Color {
        let status = dayStatuses[day] ?? selectedDayStatus
        return isToday(day) ? (status == "learned" ? Color.orange.opacity(0.5) : status == "frozen" ? Color.blue.opacity(0.5) : Color.clear) : Color.clear
    }
    
    private func dayForeground(for day: Int) -> Color {
        let status = dayStatuses[day] ?? selectedDayStatus
        return isToday(day) ? (status == "learned" ? Color.orange : status == "frozen" ? Color.blue : Color.white) : Color.white
    }

    private func dayOfWeek(for day: Int) -> String {
        let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        return days[(day - 1) % 7]
    }
    
    private func logTodayAsLearned() {
        let today = calendar.component(.day, from: Date())
        selectedDayStatus = "learned"
        dayStatuses[today] = "learned"
        streakDays += 1
    }
    
    private func freezeToday() {
        let today = calendar.component(.day, from: Date())
        if frozenDays < availableFreezes() {
            selectedDayStatus = "frozen"
            dayStatuses[today] = "frozen"
            frozenDays += 1
        }
    }
    
    private func resetStreakIfNeeded() {
        // إعادة تعيين السلسلة إذا مر أكثر من 32 ساعة
        if Date().timeIntervalSince(currentDate) > 32 * 60 * 60 {
            resetStreak()
        }
    }
    
    private func resetStreak() {
        streakDays = 0
    }
    
    // التحقق مما إذا كان اليوم الحالي هو اليوم المحدد
    private func isToday(_ day: Int) -> Bool {
        let today = calendar.component(.day, from: Date())
        return day == today
    }
}



struct LearningTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        LearningTrackerView(learningSubject: "Swift", learningDuration: "Week")
    }
}
