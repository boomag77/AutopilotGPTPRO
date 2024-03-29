
import Foundation

final class DataManager {
    
    func registerNewInstruction(instruction: InstructionModel) {
        
        if isExist(instruction: instruction) {
            return
        }
        let newInstruction = Instruction(context: AppDelegate.shared.container.viewContext)
        newInstruction.name = instruction.name
        newInstruction.text = instruction.text
        
        AppDelegate.shared.saveContext()
    }
    
    private func isExist(instruction: InstructionModel) -> Bool {
        
        let request = Instruction.createFetchRequest()
        let predicate = NSPredicate(format: "name == %@", instruction.name)
        request.predicate = predicate
        if let instructions = try? AppDelegate.shared.container.viewContext.fetch(request) {
            return !instructions.isEmpty
        } else {
            print("Could not fetch instruction with name \(instruction.name)")
        }
        return true
    }
    
}
