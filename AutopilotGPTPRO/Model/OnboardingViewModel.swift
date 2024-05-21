
import UIKit

struct Question {
    var title: String
    var answers: [String]
}

protocol OnboardingViewModelDelegate: UIViewController {
    func updateProgress(to step: Int, of steps: Int)
    func resetProgress()
}

class OnboardingViewModel {
    
    private var questionSet: [Question]
    private var currentQuestionIndex: Int
    
    weak var delegate: OnboardingViewModelDelegate?
    
    init(lang: Language) {
        switch lang {
            case .english:
                questionSet = englishQuestions
            case .spanish:
                questionSet = spanishQuestions
            case .french:
                questionSet = frenchQuestions
            case .russian:
                questionSet = russianQuestions
        }
        self.currentQuestionIndex = 0 
    }
    
    func getQuestion() -> Question? {
        guard currentQuestionIndex < questionSet.count else {
            return nil
        }
        //let progress = Float(currentQuestionIndex) / Float(questionSet.count)
        delegate?.updateProgress(to: currentQuestionIndex, of: questionSet.count)
        let question = questionSet[currentQuestionIndex]
        currentQuestionIndex += 1
        return question
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
        delegate?.resetProgress()
    }
    
    private let englishQuestions: [Question] = [
        
        Question(title: "What age group are you in?",
                 answers: ["18-25 years old",
                            "26-35 years old",
                            "36-45 years old",
                            "46-55 years old",
                            "56+ years old"]
                ),
        Question(title: "What gender identity do you identify with?",
                 answers: ["Male",
                            "Female",
                            "Non-binary / Other"]
                ),
        Question(title: "What income level is comfortable for you in your current role?",
                 answers: ["Less than $500 per month",
                           "$500 - $1000 per month",
                           "$1000 - $2000 per month",
                           "Over $2000 per month"]
                ),
        Question(title: "How many years have you been developing in the QA field?",
                 answers: ["Less than 1 year",
                           "1-3 years",
                           "3-5 years",
                           "More than 5 years"]
                ),
        Question(title: "Have you encountered interviews that helped you grow professionally?",
                 answers: ["Yes, multiple times",
                           "Yes, several times a year",
                           "Yes, periodically",
                           "Yes, but it was rare",
                           "Yes, once",
                           "No, never"]
                ),
        Question(title: "Have you encountered any difficulties in professional communication?",
                 answers: ["Yes",
                           "No"]
                ),
        Question(title: "What devices do you usually use for work?",
                 answers: ["PC / Laptop",
                           "Smartphone",
                           "Tablet",
                           "Other"]
                ),
        Question(title: "How would you rate your communication skills in the workplace?",
                 answers: ["High",
                           "Average",
                           "Low"]
                ),
        Question(title: "What approach to problem-solving at work do you find most effective for yourself?",
                 answers: ["Analytical",
                           "Collaborative",
                           "Intuitive",
                           "Systematic"]
                ),
        Question(title: "How open are you to using new tools that can improve your workflow?",
                 answers: ["Very open",
                           "More open than not",
                           "More closed than open",
                           "Completely closed"]
                ),
        Question(title: "How important is it for you to be able to rely on a team to achieve professional goals?",
                 answers: ["Very important",
                           "Quite important",
                           "Not very important",
                           "Not important at all"]
                ),
        Question(title: "What is your attitude towards learning and implementing new technologies at work?",
                 answers: ["Positive",
                           "Neutral",
                           "Negative"]
                ),
        Question(title: "What is your level of proficiency in English in the context of professional activity?",
                 answers: ["Advanced",
                           "Intermediate",
                           "Basic",
                           "Not proficient"]
                ),
        Question(title: "What testing tools have you worked with?",
                 answers: ["Selenium",
                           "JIRA",
                           "Appium",
                           "Postman",
                           "SoapUI",
                           "Any others"]
                ),
        Question(title: "What types of testing have you conducted in projects?",
                 answers: ["Functional",
                           "Load",
                           "Integration",
                           "Performance",
                           "UI/UX",
                           "Security",
                           "Others"]
                )
    ]
    private let spanishQuestions: [Question] = []
    private let frenchQuestions: [Question] = []
    private let russianQuestions: [Question] = []
    
}
