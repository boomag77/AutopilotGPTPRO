
import Foundation
import CoreData

final class DataManager {
    
    static let shared = DataManager()
    
    let container: NSPersistentContainer
    
    private init() {
        
        container = NSPersistentContainer(name: "Storage")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent store: \(error)")
            }
        }
        if containerIsEmpty() {
            registerNewInstruction(instruction: defaultInstruction)
        }
    }
    
    lazy private var defaultInstruction: InstructionModel = {
        
        let name = "Junior QA Engineer"
        let text =
        """
        You will assist a QA Engineer candidate during an interview with
        a recruiter. The conversation will be divided in 10-second
        segments. At each segment, offer concise, bullet-point
        advice to the candidate, focusing on key facts and essential
        information. Ensure your guidance is brief, relevant, and quick to
        read.
        1. Quickly Process Each Segment: As you receive conversation
        pieces in 10-second intervals, swiftly understand the context
        and questions asked.
        2. Deliver Prompt Concise Advice: Provide immediate, bullet-point
        suggestions to the candidate, relevant to the last segment
        heard.
        3. Highlight Relevant Skills: Emphasize skills crucial for a QA
        Engineer, like testing methodologies and tools.
        4. Clear Communication Tips: Advise on thorough, thoughtful
        clearly, demonstrating teamwork, and effective collaboration.
        5. Technical Query Responses: Offer succinct answers to
        technical questions, focusing on QA principles and practices.
        6. Encourage Insightful Questions: Remind the candidate to ask
        meaningful questions about the company and role.
        7. End on a Strong Note: Suggest a powerful closing
        statement, highlighting the candidate's interest and fit for
        the role.
        Notye: The advice should adapt to the conversation's pace and
        content. Be prepared to shift focus quickly based on the
        interviewer's questions and the candidate's responses.
        """
        
        let instruction = InstructionModel(name: name, text: text)
        
        return instruction
    }()
    
    func saveContext() {
        
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error while saving context to container \(error)")
            }
        }
    }
    
    private func containerIsEmpty() -> Bool {
        let request = Instruction.createFetchRequest()
        do {
            let instructions = try container.viewContext.fetch(request)
            if instructions.isEmpty {
                return true
            }
        } catch let error as NSError {
            print("could not fetch instructions \(error)")
        }
        return false
    }
    
    
    func getInstructions() -> [InstructionModel] {
        var list: [InstructionModel] = []
        let request = Instruction.createFetchRequest()
        request.includesSubentities = false
        do {
            let instructions: [Instruction] = try container.viewContext.fetch(request)
            for instruction in instructions {
                list.append(InstructionModel(name: instruction.name, text: instruction.text))
            }
        } catch let error as NSError {
            print("could not fetch instructions \(error)")
        }
        return list
    }
    
    func registerNewInstruction(instruction: InstructionModel, _ completion: (() -> Void)? = nil) {
        
        guard !isExist(instruction: instruction) else { return }
       
        let newInstruction = Instruction(context: container.viewContext)
        newInstruction.name = instruction.name
        newInstruction.text = instruction.text
        
        saveContext()
        
        if let completion = completion {
            completion()
        }
        
    }
    
    func removeInstruction(instruction: InstructionModel, _ completion: (() -> Void)? = nil) {
        guard isExist(instruction: instruction) else { return }
        
        let request = Instruction.createFetchRequest()
        let predicate = NSPredicate(format: "name == %@", instruction.name)
        request.predicate = predicate
        
        do {
            let results = try container.viewContext.fetch(request)
            results.forEach {container.viewContext.delete($0)}
            if containerIsEmpty() {
                registerNewInstruction(instruction: defaultInstruction)
            }
            saveContext()
            if let completion = completion {
                completion()
            }
        } catch let error as NSError {
            print ("Error while deleting the object \(instruction.name): \(error), \(error.userInfo)")
        }
       
        
    }
    
    private func isExist(instruction: InstructionModel) -> Bool {
        
        let request = Instruction.createFetchRequest()
        let predicate = NSPredicate(format: "name == %@", instruction.name)
        request.predicate = predicate
        if let instructions = try? container.viewContext.fetch(request) {
            return !instructions.isEmpty
        } else {
            print("Could not fetch instruction with name \(instruction.name)")
        }
        return true
    }
    
}
