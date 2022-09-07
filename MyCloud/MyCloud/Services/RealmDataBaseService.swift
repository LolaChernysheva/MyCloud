//
//  RealmDataBaseService.swift
//  MyCloud
//
//  Created by Лолита Чернышева on 02.09.2022.
//

import Foundation
import RealmSwift

class RealmDataBaseService: DataBaseService {
    
    let realm = try! Realm()
    
    init(user: User, rootFolder: FolderModel) {
        if getUserData(user: user) == nil {
            let userData = UserDataRealm()
            userData.login = user.login
            userData.folders.append(.init(folderModel: rootFolder))
            guard saveUserData(userData: userData) != false else { fatalError("Не удалось сохранить пользователя") }
        }
    }
    
    func getFolders(user: User, folderId: String) -> [FolderModel] {
        guard let userData = getUserData(user: user),
              let folder = userData.folders.first(where: { $0.id == folderId }) else { return [] }
        return folder.subfoldersIds.compactMap { subfolderId in
            userData.folders.first(where: { $0.id == subfolderId })?.makeFolderModel()
        }
    }
    
    func getFiles(user: User, folderId: String) -> [FileModel] {
        guard let userData = getUserData(user: user),
              let folder = userData.folders.first(where: { $0.id == folderId })
        else { return [] }
        return folder.files.map { fileRealm in
            fileRealm.makeFileModel()
        }
    }
    
    func addFile(user: User, folderId: String, file: FileModel) -> FileModel? {
        guard let userData = getUserData(user: user),
              let folder = userData.folders.first(where: { $0.id == folderId }) else { return nil }
    
        do {
            realm.beginWrite()
            folder.files.append(.init(fileModel: file))
            try realm.commitWrite()
            return file
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func addFolder(user: User, folderId: String, folder: FolderModel) -> FolderModel? {
        guard let userData = getUserData(user: user),
              let parentFolder = userData.folders.first(where: { $0.id == folderId }) else { return nil }
        
        do {
            realm.beginWrite()
            parentFolder.subfoldersIds.append(folder.id)
            userData.folders.append(.init(folderModel: folder))
            try realm.commitWrite()
        } catch {
            print(error.localizedDescription)
            return nil
        }
        return nil
    }
    
    func deleteFile(user: User, fileId: String, folderId: String) -> Bool {
        guard let userData = getUserData(user: user),
              let folder = userData.folders.first(where: { $0.id == folderId }) else { return false }

        do {
            if let fileIndexRealm = folder.files.firstIndex(where: { $0.id == fileId }) {
                realm.beginWrite()
                folder.files.remove(at: fileIndexRealm)
                try realm.commitWrite()
                return true
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
        return false
    }
    
    func deleteFolder(user: User, folderId: String) -> Bool {
        guard let userData = getUserData(user: user) else { return false }
        do {
            if let folderRealmIndex = userData.folders.firstIndex(where: { $0.id == folderId }) {
                realm.beginWrite()
                userData.folders.remove(at: folderRealmIndex)
                if let parentFolder = userData.folders.first(where: { $0.subfoldersIds.contains(folderId) }),
                   let subfolderIndex = parentFolder.subfoldersIds.firstIndex(where: { $0 == folderId }) {
                    parentFolder.subfoldersIds.remove(at: subfolderIndex)
                }
                try realm.commitWrite()
                return true
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
        return false
    }
    
    func changeFolder(user: User, folder: FolderModel) -> FolderModel? {
        guard let userData = getUserData(user: user) else { return nil }
        do {
            if let folderRealm = userData.folders.first(where: { $0.id == folder.id }) {
                realm.beginWrite()
                
                let newFolderRealm = FolderModelRealm(folderModel: folder)
                folderRealm.name = newFolderRealm.name
                
                try realm.commitWrite()
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
        return nil
    }
    
    func changeFile(user: User, fileId: String, folderId: String, file: FileModel) -> FileModel? {
        guard let userData = getUserData(user: user),
              let folder = userData.folders.first(where: { $0.id == folderId }) else { return nil }

        do {
            realm.beginWrite()
            
            let fileRealm = folder.files.first(where: { $0.id == fileId })
            fileRealm?.name = file.name
            
            fileRealm?.fileExtension = file.extention
            fileRealm?.data = file.data
            
            try realm.commitWrite()
            return file
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func getUserData(user: User) -> UserDataRealm? {
        realm.object(ofType: UserDataRealm.self, forPrimaryKey: user.login)
    }
    
    private func saveUserData(userData: UserDataRealm) -> Bool {
        do {
            realm.beginWrite()
            realm.add(userData)
            try realm.commitWrite()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}

class UserDataRealm: Object {
    @Persisted(primaryKey: true) var login: String = ""
    @Persisted var folders = List<FolderModelRealm>()
}

class FileModelRealm: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var name: String = ""
    @Persisted var fileExtension: String = ""
    @Persisted var data: Data = Data()
    
    convenience init(fileModel: FileModel) {
        self.init()
        id = fileModel.id
        name = fileModel.name
        fileExtension = fileModel.extention
        data = fileModel.data
    }
    
    func makeFileModel() -> FileModel {
        FileModel(name: name,
                  id: id,
                  extention: fileExtension,
                  data: data)
    }
}

class FolderModelRealm: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var name: String = ""
    @Persisted var subfoldersIds = List<String>()
    @Persisted var files = List<FileModelRealm>()
    
    convenience init(folderModel: FolderModel) {
        self.init()
        self.id = folderModel.id
        self.name = folderModel.name
        folderModel.subfoldersIds.forEach { subfolderId in
            self.subfoldersIds.append(subfolderId)
        }
        folderModel.files.forEach { fileModel in
            self.files.append(FileModelRealm(fileModel: fileModel))
        }
    }
    
    func makeFolderModel() -> FolderModel {
        FolderModel(name: name,
                    id: id,
                    subfoldersIds: subfoldersIds.map({ $0 }),
                    files: files.map({ $0.makeFileModel() }))
    }
}
