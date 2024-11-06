import SwiftUI

struct OnboardingView: View {
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @ObservedObject var viewModel: FitCatsViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Welcome to")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)
                
                Text("Fitness Cats!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image("rank1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 20)
                
                Text("Sign in or create a new account")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                NavigationLink(destination: SignInView()) {
                    Text("Go to Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.brown)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account? Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.brown)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .onAppear {
                if isSignedIn {
                    // Automatically navigate to HomeView if signed in
                    navigateToHome()
                }
            }
        }
    }
    
    private func navigateToHome() {
        // Navigating programmatically to HomeView
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: HomeView(viewModel: viewModel)) // Pass viewModel here
            window.makeKeyAndVisible()
        }
    }
}
