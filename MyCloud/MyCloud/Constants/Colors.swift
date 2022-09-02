//
//  Colors.swift
//  MyCloud
//
//  Created by Лолита Чернышева on 02.09.2022.
//

import UIKit

final class Colors {
    static let backgroundColor = UIColor.init(_colorLiteralRed: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    
    enum AppAppearence {
        static let backgroundColor = UIColor(red: 255/255, green: 254/255, blue: 254/255, alpha: 1)
        static let textFieldBackgroundColor = UIColor(red: 241/255, green: 242/255, blue: 244/255, alpha: 1)
        static let customBlue = UIColor(red: 39/255, green: 135/255, blue: 245/255, alpha: 1)
    }

    enum ButtonAppearance {
        static let buttonIsActive = UIColor(red: 255/255, green: 209/255, blue: 108/255, alpha: 1)
        static let buttonIsInactive = UIColor.init(_colorLiteralRed: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        static let showMoreTextButtonColor = UIColor(red: 102/255, green: 159/255, blue: 212/255, alpha: 1)
    }
}
