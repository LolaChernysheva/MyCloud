//
//  DocumentsViewModel.swift
//  MyCloud
//
//  Created by Лолита Чернышева on 03.09.2022.
//

import Foundation
import UIKit

typealias ErrorMessage = String

protocol DocumentViewModelProtocol {
    var folderId: String { get set}
    var title: String { get set }
    var cells: [DocumentsCellViewModel] { get }
    var applyingFilter: FilterType? { get set }
    
    func addFile(data: Data, name: String, extension: String)
    func addFolder(name: String)
    func delete(id: String)
    func rename(id: String, value: String)
    func validate(fileExtention: String, fileSize: Int) -> ErrorMessage?
}

struct DocumentViewModel: DocumentViewModelProtocol {
    
    var activeUser = UserDefaultsManager.shared.activeUser!
    let maximumAllowedFileSize: Int = 20000000
    var folderId: String
    var title: String = "Документы"
    
    var cells: [DocumentsCellViewModel] {
        let displayingFolders = dataBaseService.getFolders(user: activeUser, folderId: folderId)
        let displayingFiles = dataBaseService.getFiles(user: activeUser, folderId: folderId)
        
        return filter(folders: displayingFolders, files: displayingFiles)
    }
    
    var applyingFilter: FilterType?
    
    let dataBaseService: DataBaseService
    
    init(dataBaseService: DataBaseService, folderId: String) {
        self.dataBaseService = dataBaseService
        self.folderId = folderId
    }
    
    private func filter(folders: [FolderModel], files: [FileModel]) -> [DocumentsCellViewModel] {
        let photoExtensions = ["JPG", "PNG", "GIF", "HEIC"]
        guard let applyingFilter = applyingFilter else {
            return converFolders(folders: folders) + convertFiles(files: files)
        }
        
        switch applyingFilter {
        case .files:
            let filtredFiles = files.filter({ !photoExtensions.contains($0.extention) })
            return convertFiles(files: filtredFiles)
        case .images:
            let filtredFiles = files.filter({ photoExtensions.contains($0.extention) })
            return convertFiles(files: filtredFiles)
        case .folders:
            return converFolders(folders: folders)
        }
    }
    
    private func converFolders(folders: [FolderModel]) -> [DocumentsCellViewModel] {
        var cells = [DocumentsCellViewModel]()
        folders.forEach { folder in
            cells.append(.init(id: folder.id, photo: Images.folder!, name: folder.name, isFolder: true))
        }
        return cells
    }
    
    private func convertFiles(files: [FileModel]) -> [DocumentsCellViewModel] {
        var cells = [DocumentsCellViewModel]()
        files.forEach { file in
            let image:  UIImage = {
                switch file.extention {
                case "PNG", "JPG", "HEIC", "GIF" :
                    return UIImage(data: file.data) ?? Images.photo!
                default:
                    return Images.file!
                }
            }()
            cells.append(.init(id: file.id, photo: image, name: file.name, isFolder: false))
            
        }
        return cells
    }
    
    func validate(fileExtention: String, fileSize: Int) -> ErrorMessage? {
        if fileExtention == "txt" {
            return "Формат txt не поддерживается"
        }
        if fileSize >= maximumAllowedFileSize {
            return "Превышен размер файла. Максимальный размер файла - 20Mb"
        }
        return nil
    }
    
    func addFile(data: Data, name: String, extension: String) {
        let file = FileModel(name: name, id: UUID().uuidString, extention: `extension`, data: data)
        _ = dataBaseService.addFile(user: activeUser, folderId: folderId, file: file)
    }
    
    func addFolder(name: String) {
        let folder = FolderModel(name: name, id: "\(folderId)/\(UUID().uuidString)",subfoldersIds: [], files: [])
        _ = dataBaseService.addFolder(user: activeUser, folderId: folderId, folder: folder)
    }
    
    func delete(id: String) {
        let folders = dataBaseService.getFolders(user: activeUser, folderId: folderId)
        if folders.first(where: { $0.id == id }) != nil {
            _ = dataBaseService.deleteFolder(user: activeUser, folderId: id)
        } else {
            _ = dataBaseService.deleteFile(user: activeUser, fileId: id, folderId: folderId)
        }
    }
    
    func rename(id: String, value: String) {
        let folders = dataBaseService.getFolders(user: activeUser, folderId: folderId)
        let files = dataBaseService.getFiles(user: activeUser, folderId: folderId)
        
        if var folder = folders.first(where: { $0.id == id }) {
            folder.name = value
            _ = dataBaseService.changeFolder(user: activeUser, folder: folder)
        } else if var file = files.first(where: { $0.id == id }) {
            file.name = "\(value).\(file.extention)"
            _ = dataBaseService.changeFile(user: activeUser, fileId: file.id, folderId: folderId, file: file)
        }
    }
}

