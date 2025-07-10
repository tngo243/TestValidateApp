import Foundation

final class ValidationServices {
    static let shared = ValidationServices()
    
    private init() {}
    
    func validateUrl(_ url: String) -> Bool {
        let pattern = "http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&=]*)?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: url)
    }
    
    func checkVideoExists(_ fileName: String) -> Bool {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
} 