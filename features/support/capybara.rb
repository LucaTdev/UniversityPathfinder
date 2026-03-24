require "selenium/webdriver"

Selenium::WebDriver.logger.level = :warn

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

Capybara.default_max_wait_time = 15

Capybara.register_driver :faq_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  unless ENV["SHOW_BROWSER"] == "1"
    options.add_argument("--headless=new")
  end

  options.add_argument("--window-size=1400,1400")
  options.add_argument("--disable-gpu")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--no-sandbox") if RUBY_PLATFORM.include?("linux")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :faq_chrome
