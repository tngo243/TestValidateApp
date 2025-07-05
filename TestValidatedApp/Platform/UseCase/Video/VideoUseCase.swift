//
//  VideoUseCase.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 5/7/25.
//
import CoreData
import UIKit

class VideoUseCase {

    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    init() {
    }
    
    // MARK: - Save Video
    @MainActor
    func saveVideo(_ videoModel: VideoModel) {
        guard let entity = NSEntityDescription.entity(forEntityName: "VideoEntity", in: context) else { return }
        let video = NSManagedObject(entity: entity, insertInto: context)
        video.setValue(videoModel.name, forKey: "name")
        video.setValue(videoModel.url, forKey: "url")
        video.setValue(videoModel.thumbnailPath, forKey: "thumbnailPath")
        video.setValue(videoModel.createdAt, forKey: "createdAt")
        do {
            try context.save()
        } catch {
            print("Failed to save video: \(error)")
        }
    }
    
    // MARK: - Fetch Videos
    @MainActor
    func fetchVideos() -> [VideoModel] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoEntity")
        do {
            let result = try context.fetch(fetchRequest) as? [NSManagedObject] ?? []
            print(" Fetched \(result.count) videos from Core Data:")
            return result.compactMap { obj in
                let name = obj.value(forKey: "name") as? String ?? ""
                let url = obj.value(forKey: "url") as? String ?? ""
                let thumbnailPath = obj.value(forKey: "thumbnailPath") as? String ?? ""
                let createdAt = obj.value(forKey: "createdAt") as? Date ?? Date()
                print("   📹 Video: \(name) - Downloaded at: \(createdAt)")
                return VideoModel(name: name,
                                  url: url,
                                  thumbnailPath: thumbnailPath,
                                  createdAt: createdAt)
            }
        } catch {
            debugPrint("Failed to fetch videos: \(error)")
            return []
        }
    }
    
    // MARK: - Delete Video
    @MainActor
    func deleteVideo(name: String) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoEntity")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let result = try context.fetch(fetchRequest) as? [NSManagedObject] ?? []
            for obj in result {
                context.delete(obj)
            }
            try context.save()
        } catch {
            debugPrint("Failed to delete video: \(error)")
            throw error
        }
    }
}
