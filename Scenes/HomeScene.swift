import SwiftUI

struct HomeScene: View {
    @State private var isGameActive = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("backgroundSteveJobsTheater")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.clear]), startPoint: .top, endPoint: .bottom)
                    )
                    .blur(radius: 7)
                
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.85)
                    .foregroundStyle(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("Echoes of Silence")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.orange)
                            .shadow(radius: 15)
                        
                        Text("A Pianist’s Journey")
                            .foregroundStyle(Color.white)
                            .font(.title)
                    }
                    .multilineTextAlignment(.center)
                    
                    startButton
                    infoButton
                    
                    Spacer()
                }
                .padding(.bottom, 60)
            }
            .fullScreenCover(isPresented: $isGameActive) {
                GameViewControllerWrapper()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ReturnToHomeScene"))) { _ in
                print("Received ReturnToHomeScene Notification - Returning to HomeScene")
                isGameActive = false
            }
        }
    }
    
    var startButton: some View {
        Button(action: {
            isGameActive = true
        }) {
            Text("Start")
                .font(.title2)
                .fontWeight(.black)
                .frame(width: 250, height: 50)
                .padding()
                .background(Color.orange)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.4), lineWidth: 4)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.white.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PressEffect())
    }
    
    var infoButton: some View {
        NavigationLink(destination: CreditsScene()) {
            Text("Credits")
                .font(.title2)
                .fontWeight(.medium)
                .frame(width: 250, height: 50)
                .padding()
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 4)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(PressEffect())
    }
}

struct GameViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController()
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {}
}
