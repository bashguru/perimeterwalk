#!/usr/bin/python3

import sys
import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from fake_useragent import UserAgent

ua = UserAgent()
user_agent = ua.random

options = webdriver.ChromeOptions()
options.headless = True
options.add_argument(f'user-agent={user_agent}')
options.add_argument("--ignore-certificate-errors")
caps = DesiredCapabilities().CHROME
caps["acceptInsecureCerts"] = True
browser = webdriver.Chrome(options=options, desired_capabilities=caps)

URL = sys.argv[1]

browser.get(URL)

S = lambda X: browser.execute_script('return document.body.parentNode.scroll'+X)
browser.set_window_size(S('Width'),S('Height')) # May need manual adjustment                                                                                                                
browser.find_element(By.TAG_NAME, 'body')
wait = WebDriverWait(browser, 20)
wait.until(EC.presence_of_element_located((By.TAG_NAME, "body")))
browser.save_screenshot(sys.argv[2])


browser.quit()

