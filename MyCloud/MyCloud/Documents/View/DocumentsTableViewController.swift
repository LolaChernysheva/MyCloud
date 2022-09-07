//
//  DocumentsTableViewController.swift
//  MyCloud
//
//  Created by Лолита Чернышева on 02.09.2022.
//

import UIKit

enum FilterType: CaseIterable {
    case files
    case images
    case folders
    
    var description: String {
        switch self {
        case .files:
            return "Файлы"
        case .images:
            return "Изображения"
        case .folders:
            return "Папки"
        }
    }
}

class DocumentsTableViewController: UITableViewController {
    
    //MARK: - properties
    
    private var menuBarButton = UIBarButtonItem()
    private var filterBarButton = UIBarButtonItem()
    private var cells = [DocumentsCellViewModel]()
    
    private var viewModel: DocumentViewModelProtocol?
    
    //MARK: - life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(DocumentsTableViewCell.self, forCellReuseIdentifier: DocumentsTableViewCell.cellIdentifier)
        self.navigationItem.title = viewModel?.title ?? "-"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        tableView.delegate = self
        tableView.dataSource = self
        navBarConfigure()
        loadCells()
    }
    
    // MARK: - tableViewDataSource and tableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = cells[indexPath.row]
        if cell.isFolder {
            let documentsViewController = DocumentsTableViewController()
            guard var viewModel = self.viewModel else { return }
            viewModel.title = cell.name
            viewModel.folderId = cell.id
            documentsViewController.viewModel = viewModel
            self.navigationController?.pushViewController(documentsViewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DocumentsTableViewCell.cellIdentifier, for: indexPath) as? DocumentsTableViewCell
        guard let cell = cell else { return UITableViewCell() }
        cell.viewModel = cells[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Rename action
        let rename = UIContextualAction(style: .normal,
                                        title: "Переименовать") { [weak self] (action, view, completionHandler) in
            self?.handleMarkAsRename(indexPath: indexPath)
            completionHandler(true)
        }
        rename.backgroundColor = Colors.ButtonAppearance.buttonIsActive
        
        // Delete action
        let delete = UIContextualAction(style: .normal,
                                        title: "Удалить") { [weak self] (action, view, completionHandler) in
            self?.handleMarkAsDelete(indexPath: indexPath)
            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, rename])
        
        return configuration
    }
    
    //MARK: - private
    
    private func handleMarkAsDelete(indexPath: IndexPath) {
        let id = cells[indexPath.row].id
        self.viewModel?.delete(id: id)
        self.cells.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    private func handleMarkAsRename(indexPath: IndexPath) {
        let cell = cells[indexPath.row]
        let alert = UIAlertController(title: "Переименовать", message: nil, preferredStyle: .alert)
        var newName: String = ""
        alert.addTextField { textField in
            textField.delegate = self
            textField.placeholder = "Введите имя"
        }
        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
            newName = alert.textFields![0].text ?? cell.name
            if newName.isEmpty {
                newName = cell.name
            }
            self.viewModel?.rename(id: cell.id, value: newName)
            self.reload()
        })
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func navBarConfigure() {
        menuBarButton = UIBarButtonItem(title: nil, image: Images.menu, primaryAction: nil, menu: menuItems())
        filterBarButton = UIBarButtonItem(title: nil, image: Images.filter, primaryAction: nil, menu: filterMenuItems())
        menuBarButton.tintColor = Colors.backgroundColor
        filterBarButton.tintColor = Colors.backgroundColor
        navigationItem.setRightBarButtonItems([menuBarButton, filterBarButton], animated: true)
    }
    
    private func filterMenuItems() -> UIMenu {
        var uiActions: [UIAction] = FilterType.allCases.map { type in
            UIAction(title: type.description, image: nil, handler: { [weak self] _ in
                self?.viewModel?.applyingFilter = type
                self?.reload()
            })
        }
        uiActions.append(UIAction(title: "Сбросить", image: nil, handler: {[weak self] _ in
            self?.viewModel?.applyingFilter = nil
            self?.reload()
        }))
        
        return UIMenu(title: "", options: .displayInline, children: uiActions)
    }
    
    private func menuItems() -> UIMenu {
        let addMenuItems = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Выход \(UserDefaultsManager.shared.activeUser?.login ?? "")", image: Images.exit, handler: {[ weak self ] _ in
                guard let self = self else { return }
                self.logoutButtonPressed()
                
            }),
            
            UIAction(title: "Добавить файл", image: Images.addFile, handler: { [ weak self ]_ in
                guard let self = self else { return }
                self.addItemBarButtonPressed()
            }),
            
            UIAction(title: "Добавить папку", image: Images.addFolder, handler: { [ weak self ] _ in
                guard let self = self else { return }
                self.addFolderButtonPressed()
            }),
            
            UIAction(title: "Добавить фото", image: Images.photo, handler: { [weak self] _ in
                guard let self = self else { return }
                self.showImagePickerController()
            })
        ])
        
        return addMenuItems
    }
    
    private func loadCells() {
        cells = viewModel?.cells ?? []
    }
    
    private func reload() {
        loadCells()
        tableView.reloadData()
    }
    
    private func addItemBarButtonPressed() {
        showDocumentsPickerController()
    }
    
    private func addFolderButtonPressed() {
        var folderName: String = ""
        let alert = UIAlertController(title: "Имя папки", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.delegate = self
            textField.placeholder = "Новая папка"
        }
        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
            folderName = alert.textFields![0].text ?? "Новая папка"
            if folderName.isEmpty {
                folderName = "Новая папка"
            }
            self.viewModel?.addFolder(name: folderName)
            self.reload()
        })
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func logoutButtonPressed() {
        UserDefaultsManager.shared.deleteActiveUser()
        self.window?.rootViewController = SignInViewController()
    }
}

//MARK: - DocumentsPickerController

extension DocumentsTableViewController: UIDocumentPickerDelegate {
    private func showDocumentsPickerController() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.archive, .pdf, .data, .mp3, .svg, .video, .fileURL])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .overFullScreen
        documentPicker.allowsMultipleSelection = false
        
        present(documentPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        var fileName: String = ""
        let ext = url.pathExtension
        
        do {
            let resources = try url.resourceValues(forKeys:[.fileSizeKey, .nameKey, .localizedNameKey])
            
            guard let resourceFileName  = resources.name,
                  let fileSize = resources.fileSize,
                  let viewModel = viewModel else { return }
            
            
            fileName = resourceFileName
            if let errorMessage = viewModel.validate(fileExtention: ext, fileSize: fileSize) {
                alertOk(title: "Что-то не так", message: errorMessage)
                return
            }
            
        } catch {
            print("Error: \(error)")
        }
        
        guard let data = try? Data(contentsOf: url) else { return }
        self.viewModel?.addFile(data: data, name: fileName, extension: ext)
        reload()
        dismiss(animated: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true)
    }
}

//MARK: - ImagePickerController

extension DocumentsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = ["public.image"]
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var fileExtention: String
        
        let assetPath = info[UIImagePickerController.InfoKey.referenceURL] as? NSURL
        
        guard let assetPath = assetPath else { return }
        if (assetPath.absoluteString?.hasSuffix("JPG"))! {
            fileExtention = "JPG"
        }
        else if (assetPath.absoluteString?.hasSuffix("PNG"))! {
            fileExtention = "PNG"
        }
        else if (assetPath.absoluteString?.hasSuffix("GIF"))! {
            fileExtention = "GIF"
        }
        else if (assetPath.absoluteString?.hasSuffix("HEIC"))! {
            fileExtention = "HEIC"
        }
        else {
            print("Недопустимый формат")
            return
        }
        
        if let choosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let data: Data? = {
                if fileExtention == "PNG" {
                    return choosenImage.pngData()
                } else {
                    return choosenImage.jpegData(compressionQuality: 1)
                }
            }()
            guard let data = data else {
                print("Не удалось преобразовать изображение в data")
                return
            }
            viewModel?.addFile(data: data, name: "image.\(fileExtention)", extension: fileExtention)
            reload()
            dismiss(animated: true)
        } else {
            return
        }
    }
}

extension DocumentsTableViewController {
    static func create() -> DocumentsTableViewController {
        let documentsViewController = DocumentsTableViewController()
        let rootFolder = FolderModel(name: "Документы", id: "root", subfoldersIds: [], files: [])
        let dataBase = RealmDataBaseService(user: UserDefaultsManager.shared.activeUser!, rootFolder: rootFolder)
        documentsViewController.viewModel = DocumentViewModel(dataBaseService: dataBase,
                                                              folderId: rootFolder.id)
        return documentsViewController
    }
}

//MARK: - TextFieldDelegate
extension DocumentsTableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if Constants.disallowedChars.contains(string) {
            return false
        }
        return true
    }
}
