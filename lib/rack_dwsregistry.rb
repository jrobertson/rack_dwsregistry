#!/usr/bin/env ruby

# file: rack_dwsregistry.rb


require 'json'
require 'app-routes'
require 'dws-registry'


class RackDwsRegistry
  include AppRoutes


  def initialize(filename='registry.xml')

    super() # required for app-routes initialize method to exectue
    @reg = DWSRegistry.new(filename)

  end

  def call(env)
    
    @env = env
    request = env['REQUEST_URI'][/https?:\/\/[^\/]+(.*)/,1]

    req = Rack::Request.new(env)

    default_routes(env, req.params)
    content, content_type = run_route(request, env['REQUEST_METHOD'])

    error = $!

    page_content, status_code = if error then
      [error, 500]
    elsif content.nil? then
      ["404: page not found", 404]
    else
      [content, 200]
    end
    
    content_type ||= 'text/html'
    
    [status_code, {"Content-Type" => content_type}, [page_content]]

  end

  
  protected

  def default_routes(env, params={})

    get '/hello' do |package,job|
      Time.now.to_s + ': hello'
    end
    
    post /^\/(.*)$/ do |key|
      
      val = params['v']
      
      begin
        e = @reg.set_key(key, val)
      rescue
        [{set_key: ($!)}.to_json, 'application/json']
      end
      
      [e.xml, 'application/xml']
      
    end            
    
    get /^\/(.*)\?/ do |key|

      val = params['v']
      
      begin
        e = @reg.set_key(key, val)
      rescue
        [{set_key: ($!)}.to_json, 'application/json']
      end
      
      [e.xml, 'application/xml']

    end    
    
    get /^\/(.*)$/ do |key|
      
      e = @reg.get_key(key)
      
      if e then
        [e.xml, 'application/xml']
      else
        [{get_key: 'key not found'}.to_json, 'application/json']
      end
      
    end    

  end
 
end