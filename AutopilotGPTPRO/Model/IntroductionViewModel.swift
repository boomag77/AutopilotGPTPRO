
import UIKit

struct ScreenContent {
    var screenNumber: Int
    var title: String
    var description: String
    
    func imageName() -> String {
        return "bg_\(self.screenNumber)"
    }
}

class IntroductionViewModel {
    
    
    var currentScreenNumber = 0
    var totalScreensCount = 0
    private var content: [ScreenContent] = [] {
        didSet {
            self.totalScreensCount = content.count
        }
    }
    
    init() {
        setupScreenContent()
    }
    
    func getScreenContent() -> ScreenContent? {
        guard currentScreenNumber < totalScreensCount else {
            return nil
        }
        currentScreenNumber += 1
        return content[currentScreenNumber-1]
    }
    
}

extension IntroductionViewModel {
    
    private func setupScreenContent() {
        self.content = [
            ScreenContent(screenNumber: 0,
                          title: "Accelerate Your QA Engineer Career with Interview AI-Buddy",
                          description:
                            """
                          Get valuable tips and strategies for successful interview performance with Interview AI-Buddy - your reliable partner in the world of development.
                          
                          Our app offers effective solutions and answers to the most pressing questions, helping you succeed in interviews. Join our community of developers who trust Interview AI-Buddy to accelerate their careers.
                          """),
            ScreenContent(screenNumber: 1,
                          title: "Interview AI-Buddy: Your Gateway to Success in QA Interviews!",
                          description:
                            """
                            Join millions worldwide in mastering QA interviews effortlessly with Interview AI-Buddy. Let our cutting-edge technology guide you to ace every question and secure your dream job.
                            """),
            ScreenContent(screenNumber: 2,
                          title: "Unlock Your Career Potential with Interview AI-Buddy: Ace Every QA Interview! ",
                          description:
                            """
                            Experience the power of Interview AI-Buddy as you embark on your journey to QA interview success. Join a global community of millions who trust our innovative technology to navigate interviews with confidence and precision.
                            """),
            ScreenContent(screenNumber: 3,
                          title: "Elevate Your QA Career with Interview AI-Buddy",
                          description:
                            """
                            Conquer Interviews with Confidence! Empower your QA journey with Interview AI-Buddy, the ultimate companion for mastering interviews.
                            
                            Our app offers effective solutions and answers to the most pressing questions, helping you succeed in interviews. Join our community of developers who trust Interview AI-Buddy to accelerate their careers.
                            """
                          ),
            ScreenContent(screenNumber: 4,
                          title: "Dominate QA Interviews with Interview AI-Buddy",
                          description:
                            """
                            Your Key to Career Triumph! Seize control of your career path with Interview AI-Buddy, the premier tool for dominating QA interviews. With our comprehensive support and cutting-edge technology, you'll outshine the competition and land your dream job!
                            """),
            ScreenContent(screenNumber: 5,
                          title: "Let's make your dream a reality with Interview AI-Buddy!",
                          description:
                            """
                            Don't settle for anything less - your potential is limitless, and we're here to help you achieve your most ambitious goals. Believe in yourself, aim for the stars, and trust Interview AI-Buddy on your journey to career success and dream fulfillment!
                            """)
        ]
    }
}
