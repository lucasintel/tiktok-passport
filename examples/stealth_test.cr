require "../src/tiktok_passport"

marionette = TiktokPassport::Marionette.new(ENV["SELENIUM_BROWSER_URL"])

marionette.navigate_to("https://bot.sannysoft.com/")
marionette.screenshot("self-test-#{Time.utc.to_unix_ms}-01.jpg")

marionette.navigate_to("https://arh.antoinevastel.com/bots/areyouheadless")
marionette.screenshot("self-test-#{Time.utc.to_unix_ms}-02.jpg")

marionette.stop
