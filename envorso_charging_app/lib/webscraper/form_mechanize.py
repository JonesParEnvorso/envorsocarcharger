import webbrowser
import mechanize
import ssl

# using mechanize to fill out a form

ssl._create_default_https_context = ssl._create_unverified_context
br = mechanize.Browser()
br.set_handle_robots(False)
br.open("https://account.evgo.com/signUp")

response = br.response()

# print(response.geturl())  # url of page
# print(response.info())  # headers
# print(response.read())  # body


# print out forms in the page
# for form in br.forms():
#    print("Form name:", form.name)
#    print(form)


# select first form
br.select_form(nr=0)

# prints out the control type, name, and value for each control in the form


'''for control in br.form.controls:
    print(control)
    print("type=%s, name=%s value=%s" %
          (control.type, control.name, br[control.name]))'''

br.form['firstName'] = 'Peter'
br.form['lastName'] = 'Johnson'
br.form['email'] = 'peter.john@myemail.com'
br.form['mobilePhone'] = '1234567980'
br.form['billingAddressAddress1'] = '17534 112th W Ave'
br.form['billingAddressCity'] = 'Ellensburg'
#br.find_control('billingAddressUsaStateId').get('55').select = True
br['billingAddressUsaStateId'] = ['55']
#br.form['billingAddressUsaStateId'] = 55
br.form['billingAddressZipCode'] = '98926'
#br.find_control('billingAddressCountryId').get('235').select = True
br['billingAddressCountryId'] = ['235']
br.form['shippingAddressSameAsBillingAddress'] = ['1']
br.form['userPassword'] = 'Password1!'
br.form['confirmUserPassword'] = 'Password1!'
#br.find_control('userAcceptedTermsAndConditions').get('on').selected = True
br.form['userAcceptedTermsAndConditions'] = ['on']

br.select_form(nr=1)
# Captcha goes here

# go to second form

br.form['nameOnCard'] = 'Peter Johnson'
br.form['cardNumber'] = '4988 4388 4388 4305'
br.form['expiryMonth'] = '03'
br.form['expiryYear'] = '2030'
br.form['cvv'] = '737'

req = br.submit()

print(req.read)
# print(br.form)
# br.back()
