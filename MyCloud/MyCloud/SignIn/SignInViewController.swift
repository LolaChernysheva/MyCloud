//
//  SignInViewController.swift
//  MyCloud
//
//  Created by Лолита Чернышева on 02.09.2022.
//

import UIKit
import SnapKit

class SignInViewController: UIViewController {
    
    lazy var signUpViewController = SignUpViewController()
    private let loginTextField = UITextField()
    private let passwordTextField = UITextField()
    private let signInButton = UIButton(type: .system)
    private let signUpButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginTextField.delegate = self
        passwordTextField.delegate = self
        configureViews()
        registerForKeyboardNotifications()
        let hideAction = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(hideAction)
        view.backgroundColor = Colors.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        signInButton.backgroundColor = Colors.ButtonAppearance.buttonIsActive
        signInButton.isEnabled = true
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
        
        signInButton.backgroundColor = Colors.ButtonAppearance.buttonIsActive
        signInButton.setTitle("Войти", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: Constants.buttonTextBigSize)
        signInButton.tintColor = Colors.backgroundColor
        signInButton.layer.cornerRadius = Constants.buttonCornerRadius
        scrollView.addSubview(signInButton)
        signInButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.leading.trailing.equalToSuperview().inset(Constants.textFieldLeadingTrailingInsets)
            maker.height.equalTo(Constants.buttonHeight)
            maker.top.equalTo(passwordTextField).inset(Constants.textFieldButtonTopInsets)
        }
        
        signUpButton.setTitle("Зарегистрироваться", for: .normal)
        signUpButton.tintColor = Colors.ButtonAppearance.buttonIsActive
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: Constants.buttonTextBigSize)
        scrollView.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.leading.trailing.equalToSuperview().inset(Constants.buttonLeadingTrailingInsets)
            maker.height.equalTo(Constants.buttonHeight)
            maker.top.equalTo(signInButton).inset(Constants.textFieldButtonTopInsets)
            maker.bottom.equalToSuperview()
        }
        
        signInButton.addTarget(self,
                               action: #selector(buttonPressed),
                               for:.touchUpInside)
        signInButton.addTarget(self,
                               action: #selector(goToSecondViewController),
                               for:.touchUpInside)
        
        signUpButton.addTarget(self,
                               action: #selector(goToSecondViewController),
                               for:.touchUpInside)
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
    
    private func findUser(login: String) -> User? {
        let userDefaultsManager = UserDefaultsManager.shared.users
        print(userDefaultsManager)
        
        for user in userDefaultsManager {
            if user.login == login {
                return user
            }
        }
        return nil
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
    
    @objc private func goToSecondViewController(sender: UIButton) {

        if (sender.isEqual(signInButton)) {
            
            let login = loginTextField.text ?? ""
            let password = passwordTextField.text ?? ""
            let user = findUser(login: login)
            
            if user == nil {
                let alert = UIAlertController(title: "Пользователь не найден", message: "Желаете зарегистрироваться?", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.signUpViewController.modalPresentationStyle = .fullScreen
                    self.present(self.signUpViewController, animated: true, completion: nil)
                }
                let cancel = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
                
                alert.addAction(ok)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            } else if user?.login == login &&  user?.password == password {
                guard let activeUser = user else { return }
                UserDefaultsManager.shared.saveActiveUser(user: activeUser)
                presentDocumentsViewController()
            } else {
                alertOk(title: "Ошибка", message: "Введен неверный пароль")
            }
        }
        
        if (sender.isEqual(signUpButton)) {
            signUpViewController.modalPresentationStyle = .fullScreen
            present(signUpViewController, animated: true, completion: nil)
        }
    }
    
    private func presentDocumentsViewController() {
        let documentsViewController = DocumentsTableViewController.create()
        let nc = UINavigationController(rootViewController: documentsViewController)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
}

extension SignInViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if Constants.disallowedChars.contains(string) {
            return false
          }
          return true
    }
}

