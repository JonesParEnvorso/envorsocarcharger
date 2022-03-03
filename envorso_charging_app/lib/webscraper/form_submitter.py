# IMPORTANT:
# run 'pip install beautifulsoup4' and pip install mechanize' before running this code

# import statements
from bs4 import BeautifulSoup

from pprint import pprint
from urllib.parse import urljoin
import webbrowser
import sys
import requests

from form_extractor import get_all_forms, get_form_details, session

# get URL from command line
url = sys.argv[1]
all_forms = get_all_forms(url)
# get the first form (edit this as you wish)
# first_form = get_all_forms(url)[0]

# prints form info to screen
for i, f in enumerate(all_forms, start=1):
    form_details = get_form_details(f)
    print(f"{i} #")
    pprint(form_details)
    print("="*50)

choice = int(input("Enter form indice: "))
# extract all form details
form_details = get_form_details(all_forms[choice - 1])

# the data body we want to submit
data = {}
for input_tag in form_details["inputs"]:
    if input_tag["type"] == "hidden":
        # if it's hidden, use the default value
        data[input_tag["name"]] = input_tag["value"]
    elif input_tag["type"] == "select":
        for i, option in enumerate(input_tag["values"], start=1):
            # iterate over available select options
            if option == input_tag["value"]:
                print(f"{i} # {option} (default)")
            else:
                print(f"{i} # {option}")

        choice = input(
            f"Enter the option for the select field '{input_tag['name']}' (1-{i}): ")
        try:
            choice = int(choice)
        except:
            # choice invalid, take the default
            value = input_tag["value"]

        else:
            value = input_tag["values"][choice-1]
        data[input_tag["name"]] = value
    elif input_tag["type"] != "submit":
        # all others except submit, prompt the user to set it
        value = input(
            f"Enter the value of the field '{input_tag['name']}' (type: {input_tag['type']}): ")
        data[input_tag["name"]] = value

# join the url with the action (form request URL)
url = urljoin(url, form_details["action"])
# pprint(data)
# can be expanded for PUT and DELETE
if form_details["method"] == "post":
    res = session.post(url, data=data)
elif form_details["method"] == "get":
    res = session.get(url, params=data)

# the below code is only for replacing relative URLs to absolute ones
soup = BeautifulSoup(res.content, "html.parser")
for link in soup.find_all("link"):
    try:
        link.attrs["href"] = urljoin(url, link.attrs["href"])
    except:
        pass
for script in soup.find_all("script"):
    try:
        script.attrs["src"] = urljoin(url, script.attrs["src"])
    except:
        pass
for img in soup.find_all("img"):
    try:
        img.attrs["src"] = urljoin(url, img.attrs["src"])
    except:
        pass
for a in soup.find_all("a"):
    try:
        a.attrs["href"] = urljoin(url, a.attrs["href"])
    except:
        pass

# write the page content to a file
# when entering in evgo, it just loads the first page of signup, which is blank
open("page.html", "w", encoding="utf-8").write(str(soup))

webbrowser.open("page.html")


# maybe this is due to the captcha not being filed out?
# look into mechanize
# http://toddhayton.com/2014/12/08/form-handling-with-mechanize-and-beautifulsoup/
# http://wwwsearch.sourceforge.net/mechanize/

# In the EVgo site, the form does not have a name, so run the following command: br.select_form(nr=0)
# https://stackoverflow.com/questions/2582580/python-mechanize-select-a-form-with-no-name
