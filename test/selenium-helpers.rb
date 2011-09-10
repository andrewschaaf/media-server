
require 'selenium-webdriver'

D = Selenium::WebDriver.for :chrome
PORT = 3000


def I(id)
  D.find_element :id => id
end

def IW(id, timeout = 5)
  wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
  wait.until {I(id)}
  I(id)
end

def type(x, y = false)
  if y
    I(y).send_keys x
  else
    body = D.find_element :xpath => "//body"
    body.send_keys x
  end
end

def click(x, timeout = 1)
  IW(x, timeout).click
end

def go(path)
  puts "GO"
  D.navigate.to "http://localhost:#{PORT}{path}"
end
