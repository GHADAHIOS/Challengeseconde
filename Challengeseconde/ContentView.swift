import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LearningViewModel() // ربط ContentView بـ ViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 13) {
                    HStack {
                        Spacer()
                        iconView
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    
                    Text("Hello Learner!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
//                        .padding(.bottom, 4)
//
                    Text("This app will help you learn everyday")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    .padding(.top, 0)
                        .baselineOffset(20)
                    
                    Text("I want to learn")
                        .font(.title3)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    learningGoalInput
                        .padding(.bottom, 20)

                    Text("I want to learn it in a")
                        .font(.title3)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    durationSelectionButtons
                        .padding(.bottom, 40)
                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: LearningTrackerView(learningSubject: viewModel.inputText, learningDuration: viewModel.learningDuration)) {
                            startButton
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

private extension ContentView {
    var iconView: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Color(red: 44/255, green: 44/255, blue: 49/255))
                .frame(width: 118, height: 118)
            
            Text("🔥")
                .font(.system(size: 52))
        }
    }

    var learningGoalInput: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $viewModel.inputText)
                .padding(.vertical, 8)
                .background(Color.black)
                .foregroundColor(.white)
                .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                .accentColor(.orange)
            
            if viewModel.inputText.isEmpty {
                Text("swift")
                    .foregroundColor(.gray)
                    .padding(.leading, 5)
            }
        }
    }

    var durationSelectionButtons: some View {
        HStack(spacing: 12) {
            ForEach(["Week", "Month", "Year"], id: \.self) { duration in
                Button(action: {
                    viewModel.setDuration(duration)
                }) {
                    Text(duration)
                        .foregroundColor(viewModel.learningDuration == duration ? .black : .orange)
                        .fontWeight(viewModel.learningDuration == duration ? .bold : .regular)
                        .padding(10)
                        .background(viewModel.learningDuration == duration ? Color(red: 1.0, green: 159/255, blue: 10/255) : Color(red: 44/255, green: 44/255, blue: 49/255))
                        .cornerRadius(8)
                }
            }
        }
    }

    var startButton: some View {
        HStack {
            Text("Start")
                .font(.title2)
                .foregroundColor(.black)
                .bold()
            Image(systemName: "arrow.right")
                .font(.title2)
                .foregroundColor(.black)
        }
        .padding()
        .frame(width: 151, height: 52)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 1.0, green: 159/255, blue: 10/255)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
