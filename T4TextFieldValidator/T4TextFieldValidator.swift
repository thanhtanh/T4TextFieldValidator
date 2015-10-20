//
//  T4TextFieldValidator.swift
//  CustomTextField
//
//  Created by SB 3 on 10/16/15.
//  Copyright © 2015 T4nhpt. All rights reserved.
//

import UIKit

public class T4TextFieldValidator: UITextField {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    var strLengthValidationMsg = ""
    var supportObj:TextFieldValidatorSupport = TextFieldValidatorSupport()
    var strMsg = ""
    var arrRegx:NSMutableArray = []
    var popUp :IQPopUp?
    
    @IBInspectable var isMandatory:Bool = true   /**< Default is YES*/
    
    @IBOutlet var presentInView:UIView?    /**< Assign view on which you want to show popup and it would be good if you provide controller's view*/
    
    @IBInspectable var popUpColor:UIColor?   /**< Assign popup background color, you can also assign default popup color from macro "ColorPopUpBg" at the top*/
    
    private var _validateOnCharacterChanged  = false
    @IBInspectable var validateOnCharacterChanged:Bool { /**< Default is YES, Use it whether you want to validate text on character change or not.*/
        
        get {
            return _validateOnCharacterChanged
        }
        set {
            supportObj.validateOnCharacterChanged = newValue
            _validateOnCharacterChanged = newValue
        }
    }
    
    private var _validateOnResign = false
    @IBInspectable var validateOnResign:Bool {
        get {
            return _validateOnResign
        }
        set {
            supportObj.validateOnResign = newValue
            _validateOnResign = newValue
        }
    }
    
    private var ColorPopUpBg = UIColor(red: 0.702, green: 0.000, blue: 0.000, alpha: 1.000)
    private var MsgValidateLength = NSLocalizedString("THIS_FIELD_CANNOT_BE_BLANK", comment: "This field can not be blank")
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override var delegate:UITextFieldDelegate? {
        didSet {
            supportObj.delegate = delegate
            super.delegate=supportObj
        }
    }
    
    func setup() {
        validateOnCharacterChanged = true
        isMandatory = true
        validateOnResign = true
        popUpColor = ColorPopUpBg
        strLengthValidationMsg = MsgValidateLength.copy() as! String
        
        supportObj.validateOnCharacterChanged = validateOnCharacterChanged
        supportObj.validateOnResign = validateOnResign
        let notify = NSNotificationCenter.defaultCenter()
        notify.addObserver(self, selector: "didHideKeyboard", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    public func addRegx(strRegx:String, withMsg msg:String) {
        let dic:NSDictionary = ["regx":strRegx, "msg":msg]
        arrRegx.addObject(dic)
    }
    
    public func updateLengthValidationMsg(msg:String){
        strLengthValidationMsg = msg
    }
    
    public func addConfirmValidationTo(txtConfirm:T4TextFieldValidator, withMsg msg:String) {
        let dic = [txtConfirm:"confirm", msg:"msg"]
        arrRegx.addObject(dic)
    }
    
    public func validate() -> Bool {
        if isMandatory {
            if self.text?.characters.count == 0 {
                self.showErrorIconForMsg(strLengthValidationMsg)
                return false
            }
        }
        
        for var i = 0; i < arrRegx.count; i++ {
            
            let dic = arrRegx.objectAtIndex(i)
            
            if dic.objectForKey("confirm") != nil {
                let txtConfirm = dic.objectForKey("confirm") as! T4TextFieldValidator
                if txtConfirm.text != self.text {
                    self.showErrorIconForMsg(dic.objectForKey("msg") as! String)
                    return false
                }
            } else if dic.objectForKey("regx") as! String != "" &&
                self.text?.characters.count != 0 &&
                !self.validateString(self.text!, withRegex:dic.objectForKey("regx") as! String) {
                    self.showErrorIconForMsg(dic.objectForKey("msg") as! String)
                    return false
            }
        }
        self.rightView=nil
        return true
    }
    
    public func dismissPopup() {
        popUp?.removeFromSuperview()
    }
    
    // MARK: Internal methods
    
    func didHideKeyboard() {
        popUp?.removeFromSuperview()
    }
    
    func tapOnError() {
        self.showErrorWithMsg(strMsg)
    }
    
    func validateString(stringToSearch:String, withRegex regexString:String) ->Bool {
        let regex = NSPredicate(format: "SELF MATCHES %@", regexString)
        return regex.evaluateWithObject(stringToSearch)
    }
    
    func showErrorIconForMsg(msg:String) {
        let btnError = UIButton(frame: CGRectMake(0, 0, 25, 25))
        btnError.addTarget(self, action: "tapOnError", forControlEvents: UIControlEvents.TouchUpInside)
        btnError.setBackgroundImage(UIImage(named: "icon_error"), forState: .Normal)
        
        self.rightView = btnError
        self.rightViewMode = UITextFieldViewMode.Always
        strMsg = msg
    }
    
    func showErrorWithMsg(msg:String) {
        
        if (presentInView == nil) {
            
            //            [TSMessage showNotificationWithTitle:msg type:TSMessageNotificationTypeError]
            print("Should set `Present in view` for the UITextField")
            return
        }
        
        popUp = IQPopUp(frame: CGRectZero)
        popUp!.strMsg = msg
        popUp!.popUpColor = popUpColor
        popUp!.showOnRect = self.convertRect(self.rightView!.frame, toView: presentInView)
        
        popUp!.fieldFrame = self.superview?.convertRect(self.frame, toView: presentInView)
        
        popUp!.backgroundColor = UIColor.clearColor()
        
        presentInView!.addSubview(popUp!)
        
        popUp!.translatesAutoresizingMaskIntoConstraints = false
        let dict = ["v1":popUp!]
        
        popUp?.superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v1]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: dict))
        
        popUp?.superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[v1]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: dict))
        
        supportObj.popUp=popUp
    }
    
}


//  -----------------------------------------------


class TextFieldValidatorSupport : NSObject, UITextFieldDelegate {
    
    var delegate:UITextFieldDelegate?
    var validateOnCharacterChanged: Bool = false
    var validateOnResign = false
    var popUp :IQPopUp?
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if delegate!.respondsToSelector("textFieldShouldBeginEditing") {
            return delegate!.textFieldShouldBeginEditing!(textField)
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if delegate!.respondsToSelector("textFieldDidBeginEditing") {
            delegate!.textFieldDidEndEditing!(textField)
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        if delegate!.respondsToSelector("textFieldShouldEndEditing") {
            return delegate!.textFieldShouldEndEditing!(textField)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if delegate!.respondsToSelector("textFieldDidEndEditing") {
            delegate?.textFieldDidEndEditing!(textField)
            
        }
        popUp?.removeFromSuperview()
        if validateOnResign {
            (textField as! T4TextFieldValidator).validate()
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        (textField as! T4TextFieldValidator).dismissPopup()
        
        if validateOnCharacterChanged {
            
            (textField as! T4TextFieldValidator).performSelector("validate", withObject: nil, afterDelay:0.1)
        }
        else {
            (textField as! T4TextFieldValidator).rightView = nil
        }
        
        if delegate!.respondsToSelector("textField:shouldChangeCharactersInRange:replacementString:") {
            return delegate!.textField!(textField, shouldChangeCharactersInRange: range, replacementString: string)
        }
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        
        if delegate!.respondsToSelector("textFieldShouldClear"){
            delegate?.textFieldShouldClear!(textField)
        }
        return true
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if delegate!.respondsToSelector("textFieldShouldReturn") {
            delegate?.textFieldShouldReturn!(textField)
        }
        return true
    }
}

//  -----------------------------------------------

class IQPopUp : UIView {
    
    var showOnRect:CGRect?
    var popWidth:Int = 0
    var fieldFrame:CGRect?
    var strMsg:NSString = ""
    var popUpColor:UIColor?
    var FontSize:CGFloat = 15
    
    var PaddingInErrorPopUp:CGFloat = 5
    var FontName = "Helvetica-Bold"
    
    override func drawRect(rect:CGRect) {
        let color = CGColorGetComponents(popUpColor!.CGColor)
        
        UIGraphicsBeginImageContext(CGSizeMake(30, 20))
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetRGBFillColor(ctx, color[0], color[1], color[2], 1)
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 7.0, UIColor.blackColor().CGColor)
        let points = [ CGPointMake(15, 5), CGPointMake(25, 25), CGPointMake(5,25)]
        CGContextAddLines(ctx, points, 3)
        CGContextClosePath(ctx)
        CGContextFillPath(ctx)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imgframe = CGRectMake((showOnRect!.origin.x + ((showOnRect!.size.width-30)/2)),
            ((showOnRect!.size.height/2) + showOnRect!.origin.y), 30, 13)
        
        let img = UIImageView(image: viewImage, highlightedImage: nil)
        
        self.addSubview(img)
        img.translatesAutoresizingMaskIntoConstraints = false
        var dict:Dictionary<String, AnyObject> = ["img":img]
        
        
        img.superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(String(format:"H:|-%f-[img(%f)]", imgframe.origin.x, imgframe.size.width), options:NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:dict))
        img.superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(String(format:"V:|-%f-[img(%f)]",imgframe.origin.y,imgframe.size.height), options:NSLayoutFormatOptions.DirectionLeadingToTrailing,  metrics:nil, views:dict))
        
        let font = UIFont(name: FontName, size: FontSize)
        
        var size:CGSize = self.strMsg.boundingRectWithSize(CGSize(width: fieldFrame!.size.width - (PaddingInErrorPopUp*2), height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font!], context: nil).size
        
        
        size = CGSizeMake(ceil(size.width), ceil(size.height))
        
        
        let view = UIView(frame: CGRectZero)
        self.insertSubview(view, belowSubview:img)
        view.backgroundColor=self.popUpColor
        view.layer.cornerRadius=5.0
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowRadius=5.0
        view.layer.shadowOpacity=1.0
        view.layer.shadowOffset=CGSizeMake(0, 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        dict = ["view":view]
        
        view.superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(String(format:"H:|-%f-[view(%f)]",fieldFrame!.origin.x+(fieldFrame!.size.width-(size.width + (PaddingInErrorPopUp*2))),size.width+(PaddingInErrorPopUp*2)), options:NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:dict))
        
        view.superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(String(format:"V:|-%f-[view(%f)]",imgframe.origin.y+imgframe.size.height,size.height+(PaddingInErrorPopUp*2)), options:NSLayoutFormatOptions.DirectionLeadingToTrailing,  metrics:nil, views:dict))
        
        let lbl = UILabel(frame: CGRectZero)
        lbl.font = font
        lbl.numberOfLines=0
        lbl.backgroundColor = UIColor.clearColor()
        lbl.text=self.strMsg as String
        lbl.textColor = UIColor.whiteColor()
        view.addSubview(lbl)
        
        lbl.translatesAutoresizingMaskIntoConstraints = false
        dict = ["lbl":lbl]
        lbl.superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(String(format:"H:|-%f-[lbl(%f)]", PaddingInErrorPopUp, size.width), options:NSLayoutFormatOptions.DirectionLeadingToTrailing , metrics:nil, views:dict))
        lbl.superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(String(format:"V:|-%f-[lbl(%f)]", PaddingInErrorPopUp,size.height), options:NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:dict))
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        self.removeFromSuperview()
        return false
    }
}










