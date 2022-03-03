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
for form in br.forms():
    print("Form name:", form.name)
    print(form)

'''for control in br.form.controls:
    print(control)
    print("type=%s, name=%s value=%s" %
          (control.type, control.name, br[control.name]))'''

# select first form and 'search' to 'computer'
br.select_form(nr=0)

# prints out the control type, name, and value for each control in the form
for control in br.form.controls:
    print(control)
    print("type=%s, name=%s value=%s" %
          (control.type, control.name, br[control.name]))

#br.form['search'] = 'computer'

#req = br.submit()

# print(req.read)
# br.back()
