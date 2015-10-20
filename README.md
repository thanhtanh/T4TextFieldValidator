# T4TextFieldValidator
Rewrite Dhawaldawar's TextFieldValidator library to Swift language

> A lightweight, customizable subclass of UITextField that supports multiple regex validations and provides a simple UI to provide validation feedback.

Dhawaldawar has written a great libray, which is named `TextFieldValidator` at https://github.com/dhawaldawar/TextFieldValidator

He doesn't seem to update his repository from a year ago. So this library is still a `objective-C` library. We can also use this by using `bridged-header` file, but it's more better if we use this library in Swift language.

See his description at [his blog][1], and from [thinkotech][2] with more example and how to use.

How to use (basic):

- Download and import the `T4TextFieldValidator.swift` file to anywhere in your project
- Add the `icon_error` to your `Assets.xcassets` 
- Use custom class `T4TextFieldValidator` instead the default `UITextField`
- Assign a view to `presentInView` data member of `T4TextFieldValidator` class on which you want to show error popup. If you are managing text field from storyboard/xib then you can directly assign outlet of “presentInView” to any view.
- Assign `delegate` of the text field
- Add regex to validate
- Call `validate` method when you need to validate the text field

For more information and detail, visit [this post][2]. Or, you can see my demo, with some textfield type such as *email*, *phone number*, *password*...

Thank you, Dhawaldawar







[1]:https://dhawaldawar.wordpress.com/2014/06/11/uitextfield-validation-ios/
[2]:http://www.thinkotech.com/ios/uitextfield-validation-for-ios/
