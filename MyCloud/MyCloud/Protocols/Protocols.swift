//
//  Protocols.swift
//  MyCloud
//
//  Created by Лолита Чернышева on 02.09.2022.
//

import Foundation

protocol DataBaseService: GetDocumentsDataBaseService, SaveDocumentsDataBaseService, DeleteDocumentsDataBaseService, ChangeDocumentsDataBaseService  {
}

protocol GetDocumentsDataBaseService {
    func getFolders(user: User) -> [FolderModel]
    func getRootFolderFiles(user: User) -> [FileModel]
}

protocol SaveDocumentsDataBaseService {
    func addFile(user: User, folderId: String?, file: FileModel) -> FileModel?
    func addFolder(user: User, folder: FolderModel) -> FolderModel?
}

protocol DeleteDocumentsDataBaseService {
    func deleteFile(user: User, fileId: String, folderId: String?) -> Bool
    func deleteFolder(user: User, folderId: String) -> Bool
}

protocol ChangeDocumentsDataBaseService {
    func changeFolder(user: User, folder: FolderModel) -> FolderModel?
    func changeFile(user: User, fileId: String, folderId: String?, file: FileModel) -> FileModel?
}
