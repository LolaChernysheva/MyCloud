//
//  DocumentsTableViewCell.swift
//  MyCloud
//
//  Created by Лолита Чернышева on 02.09.2022.
//

import UIKit
import SnapKit

class DocumentsTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "DocumentsTableViewCell"
    
    var documentImage = UIImageView()
    var documentName = UILabel()
    
    var viewModel: DocumentsCellViewModel? {
        didSet {
            documentName.text = viewModel?.name
            documentImage.image = viewModel?.photo
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell() {
        
        contentView.addSubview(documentName)
        contentView.addSubview(documentImage)
        
        documentImage.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.leading.top.bottom.equalToSuperview().inset(5)
            maker.width.height.equalTo(50)
        }
        
        documentName.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.leading.equalTo(documentImage.snp.trailing).inset(-5)
            maker.trailing.equalToSuperview().inset(20)
        }
        
    }

}
