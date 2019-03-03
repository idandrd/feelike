require File.expand_path '../server.rb', __FILE__

run Rack::URLMap.new({
  "/" => Public,
  "/admin" => Protected
})