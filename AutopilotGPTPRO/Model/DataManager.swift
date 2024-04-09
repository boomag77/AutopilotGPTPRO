
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
        """
//        1. Quickly Process Each Segment: As you receive conversation
//        pieces in 10-second intervals, swiftly understand the context
//        and questions asked.
//        2. Deliver Prompt Concise Advice: Provide immediate, bullet-point
//        suggestions to the candidate, relevant to the last segment
//        heard.
//        3. Highlight Relevant Skills: Emphasize skills crucial for a QA
//        Engineer, like testing methodologies and tools.
//        4. Clear Communication Tips: Advise on thorough, thoughtful
//        clearly, demonstrating teamwork, and effective collaboration.
//        5. Technical Query Responses: Offer succinct answers to
//        technical questions, focusing on QA principles and practices.
//        6. Encourage Insightful Questions: Remind the candidate to ask
//        meaningful questions about the company and role.
//        7. End on a Strong Note: Suggest a powerful closing
//        statement, highlighting the candidate's interest and fit for
//        the role.
//        Notye: The advice should adapt to the conversation's pace and
//        content. Be prepared to shift focus quickly based on the
//        interviewer's questions and the candidate's responses.
//        """
        
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
    
}

// MARK: Insrtructions methods

extension DataManager {
    
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
    
    func getAllInstructions() -> [InstructionModel] {
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
    
    private func updateInstruction(oldName: String,
                                   oldText: String,
                                   newName: String,
                                   newText: String,
                                   comletion: (() -> Void)? = nil) {
        
        
        
    }
    
    private func fetchInstruction(name: String) -> Instruction? {
        
        let request: NSFetchRequest<Instruction> = Instruction.createFetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        do {
            let instruction = try container.viewContext.fetch(request).first
            return instruction
        } catch {
            print("Fetch instruction with name: \(name) failed \(error)")
        }
        return nil
    }
    
    func registerNewInstruction(instruction: InstructionModel, _ completion: (() -> Void)? = nil) {
        
        if let existedInstruction: Instruction = fetchInstruction(name: instruction.name) {
            if existedInstruction.text == instruction.text {
                return
            } else {
                existedInstruction.text = instruction.text
            }
        } else {
            let newInstruction = Instruction(context: container.viewContext)
            newInstruction.name = instruction.name
            newInstruction.text = instruction.text
        }
        
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

// MARK: Messages methods

extension DataManager {
    
    func getMessagesCount(for sessionID: Int) -> Int {
        
        guard let session: Session = getSession(id: sessionID) else { return 0 }
        
        return session.messages?.count ?? 0
    }
    
    func getMessages(for sessionID: Int) -> [MessageModel] {
        
        guard let session = getSession(id: sessionID) else {
            print("Session not found")
            return []
        }
        
        guard let messagesSet: Set<Message> = session.messages as? Set<Message> else {
            return []
        }

        let sortedMessages: [Message] = messagesSet.sorted { $0.date < $1.date }
        
        let messages: [MessageModel] = sortedMessages.compactMap { message -> MessageModel? in
            guard let sender = MessageSender(rawValue: message.sender) else {return nil}
            return MessageModel(date: message.date, sender: sender, text: message.text)
        }
        
        return messages
    }
    
    func registerNewMessage(message: MessageModel, in sessionID: Int) {
        
        guard let session = getSession(id: sessionID) else {
            print("Session not found")
            return
        }
        let newMessage = Message(context: container.viewContext)
        newMessage.date = Date()
        newMessage.sender = message.sender.rawValue
        newMessage.text = message.text
        newMessage.session = session
        session.addToMessages(newMessage)
        
        saveContext()
    }
    
}

// MARK: Sessions methods

extension DataManager {
    
    func getSessionsCount() -> Int {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Session")
        request.resultType = .countResultType
        
        do {
            let result = try container.viewContext.fetch(request)
            let count = result.first as? Int ?? 0
            return count
        } catch let error as NSError {
            print("Could not fetch sessions count: \(error), \(error.userInfo)")
            return 0
        }
    }
    
    private func getSession(id: Int) -> Session? {
        
        let request = Session.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let sessions = try container.viewContext.fetch(request)
            return sessions.first
        } catch let error as NSError {
            print("Could not fetch session: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func registerNewSession(session: SessionModel) {
        
        let newSession = Session(context: container.viewContext)
        newSession.date = session.date
        newSession.tokensUsed = Int64(session.tokensUsed ?? 0)
        newSession.id = newSessionID()
        newSession.position = session.position
        
        saveContext()
    }
    
    func removeSession(withID id: Int, completion: (() -> Void)? = nil) {
        
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", NSNumber(value: Int64(id)))
        
        do {
            let sessionsForRemove = try container.viewContext.fetch(request)
            sessionsForRemove.forEach { session in
                container.viewContext.delete(session)
            }
        } catch {
            print("Fetching session with ID: \(id) failed \(error)")
        }
        saveContext()
        if let completion = completion {
            completion()
        }
    }
    
    
    // Returns SessionModels without their Messages
    func getSessions(sortKey: String, ascending: Bool) -> [SessionModel] {
        
        let requset: NSFetchRequest<Session> = Session.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending)
        requset.sortDescriptors = [sortDescriptor]
        
        do {
            let sessions = try container.viewContext.fetch(requset)
            let sessionModels = sessions.map { session -> SessionModel in
                
                return SessionModel(id: Int(session.id),
                                    date: session.date,
                                    position: session.position,
                                    tokensUsed: nil)
            }
            return sessionModels
        } catch let error as NSError {
            print("Could not fetch sessions: \(error), \(error.userInfo)")
        }
        return []
    }
    
    private func newSessionID() -> Int64 {
        
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1
        do {
            let results: [Session] = try container.viewContext.fetch(request)
            if let lastSession = results.first {
                return lastSession.id + 1
            }
        } catch let error as NSError {
            print("Could not fetch sessions: \(error), \(error.userInfo)")
        }
        return 1
    }
    
}
