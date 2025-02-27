import SwiftUI

struct CreditsScene: View {
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
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Credits")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.orange)
                            .padding(.top, 15)
                            .shadow(radius: 10)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        CreditsSection(title: "About the Developer", content: [
                            "Hi, my name is Pedro Gomes, and I’m a software engineering student from Brazil. I’m passionate about music and technology, and I love creating experiences that bring these two worlds together.",
                            "This project was created for the Swift Student Challenge 2025, combining my love for music, history, and technology into an interactive journey inspired by Beethoven’s resilience and genius."
                        ])
                        
                        CreditsSection(title: "About the Project", content: [
                            "This game is inspired by the life and legacy of Beethoven, a composer who overcame deafness to create some of the most beautiful music in history. In this experience, Beethoven himself guides you on a journey to becoming a pianist. You will explore a piano in augmented reality, learn to play one of his most famous compositions, *Für Elise*, and finally perform it on the grand stage of the Steve Jobs Theater. His story is a testament to resilience, proving that no matter the challenges, passion and dedication can overcome any obstacle."
                        ])
                        
                        CreditsSection(title: "Technology Used", content: [
                            "• Developed using Swift and SpriteKit",
                            "• Augmented reality powered by ARKit",
                            "• Artwork created using Paper (app), iPad, and Apple Pencil"
                        ])
                        
                        CreditsSection(title: "Assets Used", content: [
                            "• Music: *Für Elise* is in the public domain and was composed by Ludwig van Beethoven.",
                            "• Piano Sounds: Sourced from fuhton’s piano-mp3 repository.",
                            "• Images:",
                            "  • All background images were hand-drawn by Pedro Gomes using the app Paper, an iPad, and an Apple Pencil.",
                            "  • The Beethoven character was also hand-drawn by Pedro Gomes.",
                            "  • The piano image was sourced from Unsplash and had its background removed using Remove.bg.",
                            "• 3D Piano Model: Sourced from free3d.com."
                        ])
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                }
                .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.75)
            }
        }
    }
}

struct CreditsSection: View {
    let title: String
    let content: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .fontWeight(.heavy)
                .foregroundStyle(Color.orange)
                .padding(.bottom, 3)
            
            ForEach(content, id: \.self) { text in
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Color.white)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.bottom, 10)
    }
}
