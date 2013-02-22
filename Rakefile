require "rake"

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "shopsapi"
    gem.summary = "JSON response for eBay FindingAPI, ShoppingApi and Amazon Product Advertising API"
    gem.homepage = "https://github.com/mcmbrest/shopsapi.git"
    gem.authors = ["MCM"]
    gem.files = Dir["*", "{lib}/**/*"]
    gem.add_dependency("json")
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end