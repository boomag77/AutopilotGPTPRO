
import Foundation

struct Review {
    var rating: Int
    var name: String
    var title: String
    var text: String
}

class PaywallViewModel {
    
    let reviews: [Review] = [
        Review(rating: 5,
               name: "Kira Marich",
               title: "Extremely well done",
               text: "This app is a real lifesaver! I had been searching for a job for a long time and felt like I was stuck in the rut of hopeless searching. But when I installed this app, everything changed."),
        Review(rating: 5,
               name: "Hloe Anderson ",
               title: "Perfect!!!",
               text: "Finding a new job seemed daunting until I discovered this app. It guided me through the process seamlessly, boosting my confidence along the way."),
        Review(rating: 5, 
               name: "Marcus Kentuch",
               title: "Extremely well done",
               text: "This really helped me find the best application for work."),
        Review(rating: 5, 
               name: "Kirck Dendver",
               title: "Extremely well done",
               text: "When I started looking for a new job, I was filled with doubts and uncertainties. But thanks to this app, I was able to overcome all obstacles on the path to success."),
        Review(rating: 5,
               name: "July Medison",
               title: "Extremely well done",
               text: "I was skeptical at first, but this app proved me wrong. It streamlined my job search and helped me land a fantastic opportunity in no time.")
    ]
    
}
