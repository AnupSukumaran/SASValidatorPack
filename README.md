# SASValidatorPack

A description of this package.

## Steps on how to use this pack

1) import SASValidatorPack
2) Create a variable in your preffered view controller - > 

```
    var sasValidator: SASValidator!
```
3) In ViewDidLoad() function initialize the SASValidator class -> 
```
    sasValidator = SASValidator(viewController: self, textfields: textfields)
```
4) At the login button or some button that calls the textfield set up the validator ->

```
@IBAction func buttonAction(_ sender: Any) {
    ...     
    
    sasValidator.setValidator()
    
}
```
This calls the delegates to sort out if the textfield text are in the right format.

5) Conform the ViewController to  SASValidatorDelegate and function stubs will appear -> 

```
    extension ViewController: SASValidatorDelegate {
        func validationSuccessful() {
            print("Validation Success!")
        }
        
        func validationFailed(_ errors: [(Validatable, ValidationError)]) {
            print("Validation FAILED!")
        }
        
        func setValidatorAndRulesForTextFields(_ validator: Validator) {
        
            validator.registerField(textfields[0], rules: [RequiredRule(message: "Please enter your email"), EmailRule(message: "Email is not valid")])

            validator.registerField(textfields[1], rules: [RequiredRule(message: "Please enter password")])
            
        }
        
        
    }

```
and at the 'setValidatorAndRulesForTextFields' protocol function give different rules to each textfields as show above. And also give necessary functions for events when validation is succesfull and when failed. 


