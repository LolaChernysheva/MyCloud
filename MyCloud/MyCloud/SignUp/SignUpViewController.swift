//
//  SignUpViewController.swift
//  MyCloud
//
//  Created by Лолита Чернышева on 02.09.2022.
//

import UIKit
import SnapKit

class SignUpViewController: UIViewController {

    private let loginTextField = UITextField()
    private let passwordTextField = UITextField()
    private let signUpButton = UIButton(type: .system)
    private let signInButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        registerForKeyboardNotifications()
        loginTextField.delegate = self
        passwordTextField.delegate = self
        let hideAction = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(hideAction)
        view.backgroundColor = Colors.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginTextField.isEnabled = true
        passwordTextField.isEnabled = true
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    private func configureViews() {
        view.backgroundColor = Colors.AppAppearence.backgroundColor
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.trailing.equalToSuperview()
            maker.leading.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        let logoImage = Images.logo
        let logoImageView = UIImageView(image: logoImage)
        scrollView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.height.equalTo(Constants.logoHeightWidthSize)
            maker.width.equalTo(Constants.logoHeightWidthSize)
            maker.top.equalToSuperview().inset(Constants.logoTopInset)
        }
        
        loginTextField.backgroundColor = Colors.AppAppearence.textFieldBackgroundColor
        loginTextField.placeholder = "Логин"
        loginTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        loginTextField.font = UIFont.systemFont(ofSize: Constants.textFieldFontSize)
        loginTextField.layer.cornerRadius = Constants.textFieldCornerRadius
        loginTextField.textColor = UIColor.lightGray
        scrollView.addSubview(loginTextField)
        loginTextField.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.leading.trailing.equalToSuperview().inset(Constants.textFieldLeadingTrailingInsets)
            maker.height.equalTo(Constants.textFieldHeight)
            maker.top.equalTo(logoImageView).inset(300)
        }
        
        passwordTextField.backgroundColor = Colors.AppAppearence.textFieldBackgroundColor
        passwordTextField.placeholder = "Пароль"
        passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        passwordTextField.font = UIFont.systemFont(ofSize: Constants.textFieldFontSize)
        passwordTextField.layer.cornerRadius = Constants.textFieldCornerRadius
        passwordTextField.textColor = UIColor.lightGray
        scrollView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.leading.trailing.equalToSuperview().inset(Constants.textFieldLeadingTrailingInsets)
            maker.height.equalTo(Constants.textFieldHeight)
            maker.top.equalTo(loginTextField).inset(Constants.textFieldButtonTopInsets)
        }
        
        signUpButton.setTitle("Зарегистрироваться", for: .normal)
        signUpButton.tintColor = Colors.ButtonAppearance.buttonIsActive
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: Constants.buttonTextBigSize)
        scrollView.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.leading.trailing.equalToSuperview().inset(Constants.buttonLeadingTrailingInsets)
            maker.height.equalTo(Constants.buttonHeight)
            maker.top.equalTo(passwordTextField).inset(Constants.textFieldButtonTopInsets)
        }
        
        signInButton.setTitle("У меня есть аккаунт", for: .normal)
        signInButton.tintColor = Colors.ButtonAppearance.buttonIsActive
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: Constants.buttonTextMediumSize)
        scrollView.addSubview(signInButton)
        signInButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.leading.trailing.equalToSuperview().inset(Constants.buttonLeadingTrailingInsets)
            maker.height.equalTo(Constants.buttonHeight)
            maker.top.equalTo(signUpButton).inset(Constants.textFieldButtonTopInsets)
            maker.bottom.equalToSuperview()
        }
        
        signUpButton.addTarget(self,
                               action: #selector(goToDocumentsViewController),
                               for:.touchUpInside)
        
        signInButton.addTarget(self, action: #selector(signInBtnPressed), for: .touchUpInside)
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(kbWillShow),
                                               name: UIResponder.keyboardWillShowNotification ,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(kbWillHide),
                                               name: UIResponder.keyboardWillHideNotification ,
                                               object: nil)
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification ,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification ,
                                                  object: nil)
    }
    
    //при появлении клавиатуры
    @objc private func kbWillShow(_ notification: NSNotification) {
        //получение размеров клавиатуры
        let userInfo = notification.userInfo
        let kbFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
    }
    
    //при скрытии клавиатуры
    @objc private func kbWillHide() {
        scrollView.contentOffset = CGPoint.zero
    }
    
    //обработка события нажатия на кнопку
    @objc private func buttonPressed() {
    }
    
    //скрытие клавиатуры по нажатию на контейнер
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func signInBtnPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func goToDocumentsViewController(sender: UIButton) {

        if let loginText = loginTextField.text,
           let passwordText = passwordTextField.text {
        
            if !loginText.isEmpty && !passwordText.isEmpty {
                UserDefaultsManager.shared.saveUser(login: loginText, password: passwordText)
                UserDefaultsManager.shared.saveActiveUser(user: .init(login: loginText, password: passwordText))
                let nc = UINavigationController(rootViewController: DocumentsTableViewController.create())
                nc.modalPresentationStyle = .fullScreen
                present(nc, animated: true, completion: nil)
            } else {
                alertOk(title: "Ошибка", message: "Необходимо заполнить все поля")
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if Constants.disallowedChars.contains(string) {
            return false
          }
          return true
    }
}

