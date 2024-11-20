import SwiftUI

struct LearningTrackerView: View {
    var learningSubject: String // الهدف التعليمي المدخل من المستخدم
    var learningDuration: String // مدة التعلم، مثل: أسبوع، شهر، أو سنة
    @State private var streakDays = 0 // عدد الأيام المتتالية (يبدأ من الصفر)
    @State private var frozenDays = 0 // عدد الأيام المجمدة
    @State private var selectedDayStatus: String = "log" // الحالة اليومية (تعلم، مجمد، تسجيل)
    @State private var currentWeek = 0 // رقم الأسبوع الحالي
    @State private var currentDate = Date() // التاريخ الحالي (يتم استخدامه للتنقل بين الأسابيع)
    @State private var dayStatuses: [Int: String] = [:] // حالات الأيام السابقة بناءً على التاريخ
    private let calendar = Calendar.current // استخدام التقويم الحالي للنظام

    let weeksInMonth = 4 // عدد الأسابيع المعروضة في الشهر

    // تنسيق التاريخ لعرض اليوم الكامل والتاريخ، مثل: "Saturday, 26 Oct"
    let topDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMM"
        return formatter
    }()
    
    // تنسيق الشهر والسنة فقط، مثل: "October 2024"
    let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // خلفية سوداء تغطي كامل الشاشة

                VStack(spacing: 5) {
                    // الجزء العلوي (التاريخ والهدف)
                    VStack(alignment: .leading, spacing: 5) {
                        // عرض اليوم الحالي مع التاريخ الكامل باستخدام التنسيق المحدد
                        Text(currentDate, formatter: topDateFormatter)
                            .foregroundColor(.gray)
                            .font(.subheadline)

                        HStack {
                            // عرض نص الهدف التعليمي بعنوان كبير ولون أبيض
                            Text("Learning \(learningSubject)")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)

                            Spacer()

                            // زر للتنقل إلى شاشة UpdateLearningGoalView لتحديث الهدف ومدة التعلم
                            NavigationLink(destination: UpdateLearningGoalView()) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 44/255, green: 44/255, blue: 49/255))
                                        .frame(width: 60, height:60, alignment: .center)

                                    Text("🔥") // رمز الحماس أو النشاط
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
                            .frame(width: 367, height: 208)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )

                        VStack(spacing: 10.0) {
                            // جزء الشهر والسنة وأزرار التنقل
                            HStack {
                                Text(currentDate, formatter: monthYearFormatter) // عرض الشهر والسنة
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                Image(systemName: "chevron.right") // رمز السهم لليمين
                                    .foregroundColor(.orange)

                                Spacer()
                                
                                // أزرار للتنقل بين الأسابيع السابقة والقادمة
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

                            // عرض أيام الأسبوع مع تمييز اليوم الحالي
                            HStack(spacing: 7) {
                                ForEach(weekDays(), id: \.self) { date in
                                    VStack {
                                        Text(dayOfWeek(for: date)) // عرض اختصار اليوم (مثل: SAT, SUN)
                                            .foregroundColor(isToday(date) ? .white : .gray)
                                            .font(.footnote)
                                            .fontWeight(isToday(date) ? .bold : .semibold)
                                        
                                        ZStack {
                                            Circle()
                                                .fill(dayBackground(for: date)) // خلفية اليوم بناءً على حالته
                                                .frame(width: 44, height: 44)
                                            
                                            Text("\(calendar.component(.day, from: date))") // رقم اليوم في الشهر
                                                .foregroundColor(isToday(date) && dayStatuses[calendar.component(.day, from: date)] == nil ? Color.orange : .white)
                                                .font(.system(size: 20, weight: isToday(date) && dayStatuses[calendar.component(.day, from: date)] == nil ? .regular : .bold))
                                                                                        }
                                    }
                                }
                            }
                            .padding(.top, 5)
                            
                            Divider()
                                .frame(width: 360)
                                .background(Color.gray)
                                .padding(.vertical, 5)

                            // عرض حالة الأيام المتتالية وعدد الأيام المجمدة
                            HStack(spacing: 50) {
                                VStack {
                                    HStack {
                                        Text("\(streakDays)") // عرض عدد الأيام المتتالية
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("🔥") // رمز الحماس لعدد الأيام المتتالية
                                            .font(.largeTitle)
                                            .foregroundColor(.orange)
                                    }
                                    Text("Day streak") // تسمية العداد
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                
                                Divider()
                                    .frame(width: 1, height: 60)
                                    .background(Color.gray)
                                
                                VStack {
                                    HStack {
                                        Text("\(frozenDays)") // عرض عدد الأيام المجمدة
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("🧊") // رمز التجميد
                                            .foregroundColor(.blue)
                                            .font(.largeTitle)
                                    }
                                    Text("Day frozen") // تسمية الأيام المجمدة
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                    }
                    VStack{VStack {
                       // Spacer() // يدفع الزر إلى أسفل الشاشة

                        Button(action: {
                            if selectedDayStatus == "log" { // يسمح بالضغط فقط إذا كانت الحالة "log"
                                logTodayAsLearned()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(selectedDayStatus == "learned" ? Color.darkorange2 :
                                          selectedDayStatus == "frozen" ? Color.darkblue2 :
                                          Color.orange2)
                                    .frame(width: 320, height: 320)
                                
                                // عرض النص بناءً على الحالة اليومية الحالية
                                Text(selectedDayStatus == "learned" ? "Today \n Learned" :
                                      selectedDayStatus == "frozen" ? "Day \n Freezed" :
                                      "Log Today\nas Learned")
                                    .font(.system(size: 41, weight: .semibold, design: .default))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(selectedDayStatus == "learned" ? Color.orange2 :
                                                     selectedDayStatus == "frozen" ? Color.blue2 :
                                                     Color.black)
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // لضمان أن الزر يظهر بدون أي تأثير افتراضي

                        Spacer().frame(height: 30) // مسافة صغيرة من أسفل الشاشة إذا أردت ذلك
                    }}
                    // زر لتجميد اليوم
                    Button(action: freezeToday) {
                        Text("Freeze day")
                            .bold()
                            .frame(width: 162, height: 52)
                            .background(selectedDayStatus == "learned" || selectedDayStatus == "frozen" ? Color.darkgrey2 : Color.babyblue)
                            .foregroundColor(selectedDayStatus == "learned" || selectedDayStatus == "frozen" ? Color.white : Color.blue2)
                            .cornerRadius(10)
                    }
                    
                    // عرض عدد الأيام المجمدة المتاحة
                    Text("\(frozenDays) out of \(availableFreezes()) freezes used")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
                .padding(.top, 30)
                .onAppear {
                    setInitialWeek() // تعيين الأسبوع الحالي عند فتح الشاشة
                    resetStreakIfNeeded() // إعادة تعيين الأيام المتتالية إذا لزم الأمر
                }
                .onChange(of: learningSubject) { _ in
                    resetStreak() // إعادة تعيين السلسلة عند تغيير الهدف
                }
                .onChange(of: learningDuration) { _ in
                    resetStreak() // إعادة تعيين السلسلة عند تغيير المدة
                }
            }
            .navigationBarBackButtonHidden(false)
        }
    }
    
    // تحديد اليوم الحالي عند فتح الشاشة
    private func setInitialWeek() {
        currentDate = Date()
    }
    
    // عرض أيام الأسبوع بحيث يكون اليوم الحالي في المنتصف
    private func weekDays() -> [Date] {
        let today = calendar.startOfDay(for: currentDate)
        let middleIndex = 3 // اجعل اليوم الحالي في المنتصف (المؤشر 3 في قائمة تتضمن 7 أيام)
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - middleIndex, to: today)
        }
    }
    
    // التنقل إلى الأسبوع التالي مع تحديث التاريخ الحالي
    private func nextWeek() {
        currentDate = calendar.date(byAdding: .weekOfMonth, value: 1, to: currentDate) ?? currentDate
    }
    
    // التنقل إلى الأسبوع السابق مع تحديث التاريخ الحالي
    private func previousWeek() {
        currentDate = calendar.date(byAdding: .weekOfMonth, value: -1, to: currentDate) ?? currentDate
    }

    // تحديد الحد الأقصى للأيام المجمدة بناءً على المدة
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
    // دالة الانتقال إلى الشهر التالي
    private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
    
    // تحديد لون خلفية اليوم بناءً على حالته
    private func dayBackground(for date: Date) -> Color {
        let status = dayStatuses[calendar.component(.day, from: date)] ?? "log"
        
        if isToday(date) {
            return status == "learned" ? Color.orange : status == "frozen" ? Color.blue2 : Color.clear
        } else {
            return status == "learned" ? Color.darkorange2.opacity(0.5) : status == "frozen" ? Color.darkblue2.opacity(0.5) : Color.clear
        }
    }
    
    // تحديد لون النص بناءً على حالة اليوم
    private func dayForeground(for date: Date) -> Color {
        let status = dayStatuses[calendar.component(.day, from: date)] ?? "log"
        
        if isToday(date) {
            return .white
        } else {
            return status == "learned" ? Color.orange : status == "frozen" ? Color.blue : .white
        }
    }

    // عرض اسم اليوم باختصار، مثل: "SAT"
    private func dayOfWeek(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    // تسجيل اليوم الحالي كتعلم
    private func logTodayAsLearned() {
        let today = calendar.component(.day, from: Date())
        selectedDayStatus = "learned"
        dayStatuses[today] = "learned"
        streakDays += 1
    }
    
    // تجميد اليوم الحالي إذا لم يتم تجاوز الحد الأقصى
    // تجميد اليوم الحالي إذا لم يتم تجاوز الحد الأقصى ولم يكن مجمداً مسبقاً
    private func freezeToday() {
        let today = calendar.component(.day, from: Date())
        if frozenDays < availableFreezes(), dayStatuses[today] != "frozen" {
            selectedDayStatus = "frozen"
            dayStatuses[today] = "frozen"
            frozenDays += 1
        }
    }
    
    // تبديل الحالة اليومية بين "تعلم"، "تجميد"، أو "تسجيل"
    private func toggleDayStatus() {
        if selectedDayStatus == "log" {
            logTodayAsLearned()
        } else if selectedDayStatus == "learned" {
            freezeToday()
        } else {
            selectedDayStatus = "log"
        }
    }

    // إعادة تعيين سلسلة الأيام المتتالية إذا مرّ وقت طويل دون تسجيل
    private func resetStreakIfNeeded() {
        if Date().timeIntervalSince(currentDate) > 32 * 60 * 60 {
            resetStreak()
        }
    }
    
    // إعادة تعيين سلسلة الأيام المتتالية إلى الصفر
    private func resetStreak() {
        streakDays = 0
    }
    
    // التحقق مما إذا كان التاريخ هو اليوم الحالي
    private func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
}

struct LearningTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        LearningTrackerView(learningSubject: "Swift", learningDuration: "Week")
    }
}
