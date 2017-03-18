#!/home/smason/.virtualenvs/py36/bin/python

import sys
import time
import json
import signal
import traceback

import psycopg2

from selenium import webdriver

# from http://stackoverflow.com/a/22348885/1358308
class timeout:
    def __init__(self, seconds=1, error_message='Timeout'):
        self.seconds = seconds
        self.error_message = error_message
    def handle_timeout(self, signum, frame):
        raise TimeoutError(self.error_message)
    def __enter__(self):
        signal.signal(signal.SIGALRM, self.handle_timeout)
        signal.alarm(self.seconds)
    def __exit__(self, type, value, traceback):
        signal.alarm(0)

def getHostStats(url, username, password):
    driver = webdriver.PhantomJS()

    driver.get(url)

    driver.find_element_by_id('userName').send_keys(username)
    driver.find_element_by_id('pcPassword').send_keys('{}\n'.format(password))
    time.sleep(0.5)

    driver.switch_to.frame('bottomLeftFrame')
    driver.find_element_by_id('a63').click()
    driver.find_element_by_id('a72').click()
    time.sleep(0.5)

    driver.switch_to_default_content()
    driver.switch_to.frame('mainFrame')
    elem_npp = driver.find_element_by_name('Num_per_page')
    elem_npp.find_elements_by_tag_name('option')[-1].click()
    elem_npp.submit()

    stats = driver.execute_script("return statList")

    # nasty hack to reset data!
    js = driver.execute_script("return Resetall")
    driver.execute_script(js.splitlines()[3])

    return stats

if __name__ == '__main__':
    dbcon = psycopg2.connect(database='netusage')
    stats = None

    # Selenium sometimes hangs while talking to PhantomJS, not sure
    # why but we just kill it after a few seconds, retrying a few
    # times
    for attempt in range(5):
        try:
            with timeout(seconds=5):
                stats = getHostStats("http://192.168.0.1/", 'admin', 'FR[kD3fYend#JVX4]')
                break
        except TimeoutError as err:
            if attempt > 2:
                print(err)
                traceback.print_exc()

    if stats is None:
        print("too many attempts!")
        sys.exit(1)

    with dbcon:
        with dbcon.cursor() as cur:
            cur.execute("INSERT INTO netusage (code) VALUES (%s);", [json.dumps(stats)])
