# In command "python -m pip install selenium" #

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
import time
from time import sleep

# Initialize the WebDriver
driver = webdriver.Chrome("path/to/chromedriver")
driver.get("https://digimap.edina.ac.uk/")

# Locate and click the "I'm ok with that" button in the cookies banner
try:
    wait = WebDriverWait(driver, 10)
    accept_cookies_button = wait.until(EC.element_to_be_clickable((By.XPATH, '//button[contains(text(), "I\'m OK with that")]')))
    accept_cookies_button.click()
except Exception as e:
    print("Could not find the 'I'm OK with that' button:", e)

# Locate and click the "Log In" button
try:
    wait = WebDriverWait(driver, 10)
    login_button = wait.until(EC.presence_of_element_located((By.XPATH, '//a[contains(@href, "shibb-login") and contains(@class, "login-btn")]')))
    # Click the "Log In" button using JavaScript
    driver.execute_script("arguments[0].click();", login_button)
except Exception as e:
    print("Could not find the 'Log In' button:", e)

# Enter the college name
try:
    wait = WebDriverWait(driver, 10)
    college_input = wait.until(EC.element_to_be_clickable((By.ID, 'SearchInput')))
    college_input.click()
    college_input.send_keys("Imperial College London")
except Exception as e:
    print("Could not find the search bar for college name:", e)

# Press the down arrow key and then the enter key using ActionChains
try:
    actions = ActionChains(driver)
    actions.move_to_element(college_input)
    actions.send_keys(Keys.ARROW_DOWN)
    time.sleep(1)
    actions.send_keys(Keys.ENTER)
    actions.perform()
except Exception as e:
    print("Could not press the down arrow key and enter key:", e)

# Click the "Continue" button
try:
    wait = WebDriverWait(driver, 10)
    continue_button = wait.until(EC.element_to_be_clickable((By.XPATH, '//button[contains(text(), "Continue")]')))
    continue_button.click()
except Exception as e:
    print("Could not find the 'Continue' button:", e)


# Enter the email address
try:
    wait = WebDriverWait(driver, 10)
    email_input = wait.until(EC.element_to_be_clickable((By.ID, 'i0116')))
    email_input.send_keys("sy1122@ic.ac.uk")
    continue_button = wait.until(EC.element_to_be_clickable((By.ID, 'idSIButton9')))
    continue_button.click()
except Exception as e:
    print("Could not find the email input field:", e)

# Enter the password
try:
    wait = WebDriverWait(driver, 10)
    email_input = wait.until(EC.element_to_be_clickable((By.ID, 'i0118')))
    email_input.send_keys("Ysr112605010727!")
    continue_button = wait.until(EC.element_to_be_clickable((By.ID, 'idSIButton9')))
    continue_button.click()
except Exception as e:
    print("Could not find the password input field:", e)

# Click the "Don't show this again" option
try:
    wait = WebDriverWait(driver, 10)
    dont_show_again_element = wait.until(EC.element_to_be_clickable((By.XPATH, '//span[contains(text(), "Don\'t show this again")]')))
    dont_show_again_element.click()
except Exception as e:
    print("Could not find the 'Don't show this again' option:", e)

# Click "Yes"
try:
    continue_button = wait.until(EC.element_to_be_clickable((By.ID, 'idSIButton9')))
    continue_button.click()
except Exception as e:
    print("Could not find the yes button:", e)

# Click "Ordnance Survey"
try:
    wait = WebDriverWait(driver, 10)
    ordnance_survey_button = wait.until(EC.element_to_be_clickable((By.ID, 'coll-tab-os')))
    ordnance_survey_button.click()
except Exception as e:
    print("Could not find the ordnance survey button", e)

# Click "Data Download"
try:
    wait = WebDriverWait(driver, 10)
    data_download_button = wait.until(EC.element_to_be_clickable((By.ID, 'app-DATADOWNLOAD')))
    data_download_button.click()
except Exception as e:
    print("Could not find the data download button", e)

# List of reference grid codes
reference_grid_codes = ["tl00sw", "tl00se", "tl10sw", "tl10se", "tl20sw", "tl20se", "tl30sw", "tl30se", "tl40sw", "tl40se", "tl50sw", "tl50se", "tl60sw",
                        "tq09nw", "tq09ne", "tq19nw", "tq19ne", "tq29nw", "tq29ne", "tq39nw", "tq39ne", "tq49nw", "tq49ne", "tq59nw", "tq59ne", "tq69nw",
                        "tq09sw", "tq09se", "tq19sw", "tq19se", "tq29sw", "tq29se", "tq39sw", "tq39se", "tq49sw", "tq49se", "tq59sw", "tq59se", "tq69sw",
                        "tq08nw", "tq08ne", "tq18nw", "tq18ne", "tq28nw", "tq28ne", "tq38nw", "tq38ne", "tq48nw", "tq48ne", "tq58nw", "tq58ne", "tq68nw",
                        "tq08sw", "tq08se", "tq18sw", "tq18se", "tq28sw", "tq28se", "tq38sw", "tq38se", "tq48sw", "tq48se", "tq58sw", "tq58se", "tq68sw",
                        "tq07nw", "tq07ne", "tq17nw", "tq17ne", "tq27nw", "tq27ne", "tq37nw", "tq37ne", "tq47nw", "tq47ne", "tq57nw", "tq57ne", "tq67nw",
                        "tq07sw", "tq07se", "tq17sw", "tq17se", "tq27sw", "tq27se", "tq37sw", "tq37se", "tq47sw", "tq47se", "tq57sw", "tq57se", "tq67sw",
                        "tq06nw", "tq06ne", "tq16nw", "tq16ne", "tq26nw", "tq26ne", "tq36nw", "tq36ne", "tq46nw", "tq46ne", "tq56nw", "tq56ne", "tq66nw",
                        "tq06sw", "tq06se", "tq16sw", "tq16se", "tq26sw", "tq26se", "tq36sw", "tq36se", "tq46sw", "tq46se", "tq56sw", "tq56se", "tq66sw",
                        "tq05nw", "tq05ne", "tq15nw", "tq15ne", "tq25nw", "tq25ne", "tq35nw", "tq35ne", "tq45nw", "tq45ne", "tq55nw", "tq55ne", "tq65nw",
                        "tq05sw", "tq05se", "tq15sw", "tq15se", "tq25sw", "tq25se", "tq35sw", "tq35se", "tq45sw", "tq45se", "tq55sw", "tq55se", "tq65sw"]

# Click "OS Mastermap"
wait = WebDriverWait(driver, 20)
os_mastermap_element = driver.find_element(By.XPATH, "//mat-row[contains(@class, 'category-header')]/mat-cell/span[contains(text(), 'OS MasterMap')]")
os_mastermap_element.click()

for code in reference_grid_codes:
    #code = reference_grid_codes[0]
    # Click on "Use Tile Name" button
    use_tile_name_button = driver.find_element(By.XPATH, '//button[@data-test="Use Tile Name"]')
    use_tile_name_button.click()

    # Switch to the pop-up window
    driver.switch_to.active_element

    # Wait for the input field to be clickable and find it using its data-test attribute
    tile_name_input = wait.until(EC.element_to_be_clickable((By.XPATH, '//input[@data-test="Tile Name Input"]')))

    # Enter the reference grid code
    tile_name_input.send_keys(code)

    # Find the Go button and click it, here same as "tile_name_input.send_keys(Keys.ENTER)"
    wait = WebDriverWait(driver, 10)
    go_button = driver.find_element(By.XPATH, '//button/span[contains(text(), "Go")]')
    go_button.click()

    # Switch back to the main window
    wait = WebDriverWait(driver, 10)
    driver.switch_to.default_content()

    # Tick "Building Height Attribute"
    wait = WebDriverWait(driver, 10)
    building_height_attribute_checkbox = wait.until(EC.element_to_be_clickable((By.ID, 'mat-checkbox-4-input')))
    driver.execute_script("arguments[0].click();", building_height_attribute_checkbox)

    # Click "Add to basket"
    wait = WebDriverWait(driver, 10)
    add_to_basket = driver.find_element(By.XPATH, "//div[@data-test='Add To Basket']")
    add_to_basket.click()

    # Select "File Geodatabase" as format
    wait = WebDriverWait(driver, 30)
    driver.switch_to.active_element # Switch to the pop-up window

    # Click on the 'Select Format' dropdown
    wait = WebDriverWait(driver, 10)
    select_format_dropdown = driver.find_element(By.XPATH, "//mat-select[.//span[contains(text(), 'Select Format')]]")
    select_format_dropdown.click()

    # Wait for the options to be visible
    wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, ".mat-option-text")))

    # Select 'File Geodatabase' option
    file_geodatabase_option = driver.find_element(By.XPATH, "//span[contains(text(), 'File Geodatabase')]")
    file_geodatabase_option.click()

    # Enter the download name
    download_name_input = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "input[data-placeholder='Give this download a name: [Optional]']")))
    download_name_input.click()
    download_name_input.send_keys(code)

    # Click "Request to download"
    request_to_download = driver.find_element(By.XPATH, "//div[@data-test='Order Map Data']")
    request_to_download.click()

    # Wait for the "Ok" button after order and click it
    after_order_ok_button = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "button[data-test='Message Dialog Ok']")))
    driver.execute_script("arguments[0].click();", after_order_ok_button)

    # Switch back to the main window
    driver.switch_to.default_content()

    # Switch back to the main window
    driver.switch_to.default_content()
driver.quit()

