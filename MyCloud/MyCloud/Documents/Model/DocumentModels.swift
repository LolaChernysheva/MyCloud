//
//  DocumentModels.swift
//  MyCloud
//
//  Created by Лолита Чернышева on 02.09.2022.
//

import Foundation

struct FileModel {
    var name: String
    let id: String
    let extention: String
    let data: Data
}

struct FolderModel {
    var name: String
    let id: String
    var files: [FileModel]
}
