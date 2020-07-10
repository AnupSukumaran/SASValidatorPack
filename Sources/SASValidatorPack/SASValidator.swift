//
//  SASValidator.swift
//  SASValidator
//
//  Created by Manu Puthoor on 07/04/20.
//  Copyright © 2020 Manu Puthoor. All rights reserved.
//

import Foundation
import UIKit

public protocol SASValidatorDelegate: class {
    func setValidatorAndRulesForTextFields(_ validator: Validator)
    func validationSuccessful()
    func validationFailed(_ errors: [(Validatable, ValidationError)])
}

public class SASValidator: NSObject {
    
    var viewController = UIViewController()
    var textfields = [UITextField]()
    var textFieldBaseView = [UIView]()
    var view = UIView()
    public var views = [UIView]()
    var errorTexts = [String]()
    let validator = Validator()
    weak var delegate: SASValidatorDelegate?
    var delayTimer = Timer()
    var textColor: UIColor = .black
    var bgc: UIColor = .white
    
    static var customAlertWindow: UIWindow = {
        let win = UIWindow(frame: UIScreen.main.bounds)
        win.windowLevel = UIWindow.Level.alert + 1
        return win
    }()
    
    var tapGesture:  UITapGestureRecognizer  {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        return tap
    }
    
//    public init(viewController: UIViewController, textfields: [UITextField], errorImage: UIImage, alertImgInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), textColor: UIColor = .black, bgc: UIColor = .white) {
//        super.init()
//        self.viewController = viewController
//        self.textfields = textfields
//        guard let view = viewController.view else {return}
//        self.view = view
//        delegate = viewController as? SASValidatorDelegate
//        validatingTextFields()
//        setUpValidator(errorImage, alertImgInset)
//        self.textColor = textColor
//        self.bgc = bgc
//    }
    
    public init(delegate: SASValidatorDelegate, textfields: [UITextField],textFieldBaseView: [UIView]? = nil, errorImage: UIImage, alertImgInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), textColor: UIColor = .black, bgc: UIColor = .white) {
        super.init()
        //self.viewController = viewController
        self.textfields = textfields
//        guard let view = viewController.view else {return}
//        self.view = view
        if let vis = textFieldBaseView {
             self.textFieldBaseView = vis
        }
       
        self.delegate = delegate
        validatingTextFields()
        setUpValidator(errorImage, alertImgInset)
        self.textColor = textColor
        self.bgc = bgc
    }
    
    
    
    func show(_ sender: UIButton, _ text: String, bgc: UIColor = .white, textColor: UIColor = .black) {

        if #available(iOS 13.0, *) {
            //guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let windowScene = UIApplication.shared
                                .connectedScenes
                                .filter { ($0.activationState == .foregroundActive) || ($0.activationState == .foregroundInactive) }
                                .first
            
            let vc = UIViewController()
            vc.view.backgroundColor = .clear
            
            var win: UIWindow!
            
            if let windowScene = windowScene as? UIWindowScene {
                win = UIWindow(windowScene: windowScene)

                win.frame = UIScreen.main.bounds
                win.windowLevel = UIWindow.Level.alert + 1

            }

           
            win.rootViewController = vc
            win.makeKeyAndVisible()
            Self.customAlertWindow = win
            guard let v = vc.view else {return}
            view = v
            view.addGestureRecognizer(tapGesture)
            errorAlertV2(vc: vc, text, bgc: bgc, textColor: textColor)
            //vc.present(viewController, animated: true) {}


        } else {
           // guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let vc = UIViewController()

            vc.view.backgroundColor = .clear
            Self.customAlertWindow.rootViewController = vc
            Self.customAlertWindow.makeKeyAndVisible()
            guard let v = vc.view else {return}
            view = v
    
            view.addGestureRecognizer(tapGesture)
//            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//            view.addGestureRecognizer(tap)
            errorAlertV2(vc: vc, text, bgc: bgc, textColor: textColor)
           // vc.present(viewController, animated: true) {}
        }


    }
    
    @objc func handleTap() {
        delayTimer.invalidate()
        removeAlert()
    }
    
    func validatingTextFields() {
        validator.styleTransformers(success: { (validationRule) -> Void in
    
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            
        }) { (validationError) -> Void in
      
        }
    
        delegate?.setValidatorAndRulesForTextFields(validator)
        
    }
    
    public func setValidator() {
        removeAlert()
        errorTexts.removeAll()
        validator.validate(self)
    }
    
    func setUpValidator(_ errorImage: UIImage,_ alertImgInset: UIEdgeInsets) {
        
        if !textFieldBaseView.isEmpty {
            marksAddedOnViews(errorImage,alertImgInset)
        } else {
            marksAddedOnTextFields(errorImage,alertImgInset)
        }
 
    }
    
    func marksAddedOnViews(_ errorImage: UIImage,_ alertImgInset: UIEdgeInsets) {
        for (i,v) in textFieldBaseView.enumerated() {
            
            let subView = UIView()
            subView.backgroundColor = .clear
            subView.isHidden = true
            
            let btn = UIButton()
            btn.tag = i
            btn.setImage(errorImage, for: .normal)
            btn.tintColor = .red
            btn.imageEdgeInsets = alertImgInset //UIEdgeInsets(top: 2, left: 10, bottom: 10, right: 10)
            btn.imageView?.contentMode = .scaleAspectFit
            btn.backgroundColor = .clear
            views.append(subView)
            
            btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
            subView.addSubview(btn)
            
            v.addSubview(subView)
            
            btn.translatesAutoresizingMaskIntoConstraints = false
            subView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: subView, attribute: .trailing, relatedBy: .equal, toItem: v, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: subView, attribute: .centerY, relatedBy: .equal, toItem: v, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: subView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
            
            NSLayoutConstraint(item: subView, attribute: .height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: v.frame.height).isActive = true

            NSLayoutConstraint(item: btn, attribute: .centerX, relatedBy: .equal, toItem: subView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: btn, attribute: .centerY, relatedBy: .equal, toItem: subView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: subView, attribute: .height, multiplier: 1, constant: subView.frame.height).isActive = true
            
             NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: subView, attribute: .width, multiplier: 1, constant: subView.frame.width ).isActive = true
            
        }
    }
    
    func marksAddedOnTextFields(_ errorImage: UIImage,_ alertImgInset: UIEdgeInsets) {
        for (i,v) in textfields.enumerated() {
            let subView = UIView()
            subView.backgroundColor = .clear
            subView.isHidden = true
            let btn = UIButton()
            btn.tag = i
            btn.setImage(errorImage, for: .normal)
            btn.tintColor = .red
            btn.imageEdgeInsets = alertImgInset //UIEdgeInsets(top: 2, left: 10, bottom: 10, right: 10)
            btn.imageView?.contentMode = .scaleAspectFit
            views.append(subView)
            btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
            subView.addSubview(btn)
            
            v.addSubview(subView)
            
            btn.translatesAutoresizingMaskIntoConstraints = false
            subView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: subView, attribute: .trailing, relatedBy: .equal, toItem: v, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: subView, attribute: .centerY, relatedBy: .equal, toItem: v, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: subView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
            
            NSLayoutConstraint(item: subView, attribute: .height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: v.frame.height).isActive = true

            NSLayoutConstraint(item: btn, attribute: .centerX, relatedBy: .equal, toItem: subView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: btn, attribute: .centerY, relatedBy: .equal, toItem: subView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: subView, attribute: .height, multiplier: 1, constant: subView.frame.height).isActive = true
            
             NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: subView, attribute: .width, multiplier: 1, constant: subView.frame.width ).isActive = true
            
        }
    }
    
    func errorAlertV2(vc: UIViewController,_ text: String, bgc: UIColor = .white, textColor: UIColor = .black) {
           
           let errorSubview = UIView()
           errorSubview.tag = 500
           
           errorSubview.backgroundColor = bgc
           errorSubview.layer.cornerRadius = 15
           errorSubview.layer.shadowRadius = 5
           errorSubview.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
           errorSubview.layer.masksToBounds = false
           errorSubview.layer.shadowOpacity = 0.8
           
           let label = UILabel()
           label.backgroundColor = .clear
           label.numberOfLines = 0
           label.text = text
           label.textAlignment = .center
           label.textColor = textColor
           label.alpha = 0
           
           errorSubview.addSubview(label)
           
            vc.view.addSubview(errorSubview)
           
           errorSubview.translatesAutoresizingMaskIntoConstraints = false
           label.translatesAutoresizingMaskIntoConstraints = false
       
           let padding: CGFloat = 20
           
           NSLayoutConstraint(item: errorSubview, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true

           NSLayoutConstraint(item: errorSubview, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.9, constant: 0).isActive = true
           
           NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: errorSubview, attribute: .top, multiplier: 1, constant: padding).isActive = true
           
           NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: errorSubview, attribute: .bottom, multiplier: 1, constant: -(padding)).isActive = true
           
           NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: errorSubview, attribute: .leading, multiplier: 1, constant: padding).isActive = true
           
            NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: errorSubview, attribute: .trailing, multiplier: 1, constant: -(padding)).isActive = true
           
           
           UIView.animate(withDuration: 0.4, animations: {
               NSLayoutConstraint(item: errorSubview, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -40).isActive = true
               
               errorSubview.layoutIfNeeded()
           }) { (arg) in
               UIView.animate(withDuration: 0.2) {
                   label.alpha = 1
               }
           }

           delayTimer.invalidate()
           if #available(iOS 10.0, *) {
               delayTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
                   self.removeAlert()
               }
           }
    
       }
    
    func errorAlert(_ text: String, bgc: UIColor = .white, textColor: UIColor = .black) {
        
        let errorSubview = UIView()
        errorSubview.tag = 500
        
        errorSubview.backgroundColor = bgc
        errorSubview.layer.cornerRadius = 15
        errorSubview.layer.shadowRadius = 5
        errorSubview.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        errorSubview.layer.masksToBounds = false
        errorSubview.layer.shadowOpacity = 0.8
        
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.text = text
        label.textAlignment = .center
        label.textColor = textColor
        label.alpha = 0
        
        errorSubview.addSubview(label)
        
        view.addSubview(errorSubview)
        
        errorSubview.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
    
        let padding: CGFloat = 20
        
        NSLayoutConstraint(item: errorSubview, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true

        NSLayoutConstraint(item: errorSubview, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.9, constant: 0).isActive = true
        
        NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: errorSubview, attribute: .top, multiplier: 1, constant: padding).isActive = true
        
        NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: errorSubview, attribute: .bottom, multiplier: 1, constant: -(padding)).isActive = true
        
        NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: errorSubview, attribute: .leading, multiplier: 1, constant: padding).isActive = true
        
         NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: errorSubview, attribute: .trailing, multiplier: 1, constant: -(padding)).isActive = true
        
        
        UIView.animate(withDuration: 0.4, animations: {
            NSLayoutConstraint(item: errorSubview, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -40).isActive = true
            
            errorSubview.layoutIfNeeded()
        }) { (arg) in
            UIView.animate(withDuration: 0.2) {
                label.alpha = 1
            }
        }

        delayTimer.invalidate()
        if #available(iOS 10.0, *) {
            delayTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
                self.removeAlert()
            }
        } 
 
    }
    
    @objc func btnAction(_ sender: UIButton) {
        viewController.view.endEditing(true)
        removeAlert()
        show(sender, errorTexts[sender.tag], bgc: bgc, textColor: textColor)
        //errorAlert(errorTexts[sender.tag], bgc: bgc, textColor: textColor)
        
    }
    
    @objc public func removeAlert() {
        let subviews = view.subviews

        subviews.forEach { (subview) in
            if subview.tag == 500 {
                UIView.animate(withDuration: 0.2, animations: {
                    subview.alpha = 0
                }) { (arg) in
                    subview.removeFromSuperview()
                    SASValidator.customAlertWindow.isHidden = true
                }
            }
        }
    }
    
    func errorBtnHidden() {
        views.enumerated().forEach { (arg) in
            let v = arg.element
            let i = arg.offset
            v.isHidden = validator.errors[textfields[i]] == nil ? true : false
            errorTexts.append(validator.errors[textfields[i]]?.errorMessage ?? "nil")
        }
    }
    
    public func hidderErrorForThis(_ textField: UITextField) {
        
        textfields.enumerated().forEach { (arg) in
            let tf = arg.element
            let i = arg.offset
            if tf ==  textField {
                views[i].isHidden = true
            }
        }
    }
}

extension SASValidator: ValidationDelegate {
    public func validationSuccessful() {
        removeAlert()
        errorBtnHidden()
        delegate?.validationSuccessful()
    }
    
    public func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        errorBtnHidden()
        delegate?.validationFailed(errors)
    }
    
    
}


