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

module CapybaraBrowserSupport
  module_function

  BROWSER_SPECS = [
    {
      name: :chrome,
      browser: :chrome,
      browser_execs: [
        "google-chrome",
        "google-chrome-stable",
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        "/usr/bin/google-chrome",
        "/usr/bin/google-chrome-stable"
      ],
      driver_execs: %w[chromedriver]
    },
    {
      name: :chromium,
      browser: :chrome,
      browser_execs: [
        "chromium",
        "chromium-browser",
        "/Applications/Chromium.app/Contents/MacOS/Chromium",
        "/usr/bin/chromium",
        "/usr/bin/chromium-browser",
        "/snap/bin/chromium"
      ],
      driver_execs: %w[chromedriver]
    },
    {
      name: :firefox,
      browser: :firefox,
      browser_execs: [
        "firefox",
        "/Applications/Firefox.app/Contents/MacOS/firefox",
        "/usr/bin/firefox",
        "/snap/bin/firefox"
      ],
      driver_execs: %w[geckodriver]
    }
  ].freeze

  def preferred_browser_name
    ENV["BROWSER"].to_s.strip.downcase.presence&.to_sym
  end

  def find_executable(*candidates)
    candidates.flatten.compact.each do |candidate|
      value = candidate.to_s.strip
      next if value.empty?

      paths =
        if value.include?(File::SEPARATOR)
          [value]
        else
          ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).map { |dir| File.join(dir, value) }
        end

      paths.each do |path|
        return path if File.file?(path) && File.executable?(path)
      end
    end

    nil
  end

  def browser_candidates
    specs = BROWSER_SPECS.dup
    preferred = preferred_browser_name
    return specs if preferred.blank?

    preferred_spec, others = specs.partition { |spec| spec[:name] == preferred }
    preferred_spec + others
  end

  def resolve_browser
    browser_override = find_executable(ENV["BROWSER_BINARY"])
    driver_override = find_executable(ENV["WEBDRIVER_PATH"])

    browser_candidates.each do |spec|
      browser_path = browser_override || find_executable(spec[:browser_execs])
      next if browser_path.nil?

      driver_path = driver_override || find_executable(spec[:driver_execs])
      return spec.merge(browser_path: browser_path, driver_path: driver_path)
    end

    nil
  end

  def chrome_options(browser_path:, visible:)
    options = Selenium::WebDriver::Chrome::Options.new
    options.binary = browser_path if browser_path
    options.add_argument("--headless=new") unless visible
    options.add_argument("--window-size=1400,1400")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--no-sandbox") if RUBY_PLATFORM.include?("linux")
    options
  end

  def firefox_options(browser_path:, visible:)
    options = Selenium::WebDriver::Firefox::Options.new
    options.binary = browser_path if browser_path
    options.add_argument("-headless") unless visible
    options.add_argument("--width=1400")
    options.add_argument("--height=1400")
    options
  end

  def selenium_service(spec)
    return nil if spec[:driver_path].nil?

    case spec[:browser]
    when :chrome
      Selenium::WebDriver::Service.chrome(path: spec[:driver_path])
    when :firefox
      Selenium::WebDriver::Service.firefox(path: spec[:driver_path])
    end
  end

  def build_driver(app, visible:)
    spec = resolve_browser

    raise <<~MSG if spec.nil?
      Nessun browser supportato disponibile per i test Cucumber.
      Browser cercati: chrome, chromium, firefox.
      Driver cercati: chromedriver, geckodriver.
    MSG

    options =
      case spec[:browser]
      when :chrome
        chrome_options(browser_path: spec[:browser_path], visible: visible)
      when :firefox
        firefox_options(browser_path: spec[:browser_path], visible: visible)
      else
        raise "Browser non supportato: #{spec[:browser]}"
      end

    puts "[Capybara] Browser selezionato: #{spec[:name]}#{spec[:driver_path] ? " (driver esplicito)" : " (selenium-manager)"}"

    args = {
      browser: spec[:browser],
      options: options
    }

    service = selenium_service(spec)
    args[:service] = service if service

    Capybara::Selenium::Driver.new(app, **args)
  end
end

Capybara.default_max_wait_time = 15

Capybara.register_driver :faq_browser do |app|
  CapybaraBrowserSupport.build_driver(app, visible: ENV["SHOW_BROWSER"] == "1")
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :faq_browser
