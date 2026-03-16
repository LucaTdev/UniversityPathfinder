require "test_helper"
require "selenium/webdriver"

slow_mo_delay = ENV.fetch("SLOW_MO", "0").to_f

if slow_mo_delay.positive?
  slow_mo_patch = Module.new do
    define_method(:execute) do |*args, **kwargs, &block|
      result = if kwargs.empty?
        super(*args, &block)
      else
        super(*args, **kwargs, &block)
      end

      sleep slow_mo_delay
      result
    end
  end

  Selenium::WebDriver::Remote::Bridge.prepend(slow_mo_patch)
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  browser = ENV["SHOW_BROWSER"] == "1" ? :chrome : :headless_chrome
  driven_by :selenium, using: browser, screen_size: [ 1400, 1400 ]
end
