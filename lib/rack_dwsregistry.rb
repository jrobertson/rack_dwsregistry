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
    
    # set_key
    #
    post /^\/(.*)$/ do |key|
      
      val = params['v']
      
      begin
        e = @reg.set_key(key, val)
      rescue
        [{set_key: ($!)}.to_json, 'application/json']
      end
      
      [e.xml, 'application/xml']
      
    end
    
    # delete_key
    #
    get /^\/(.*)\?action=delete_key$/ do |key|

      r = @reg.delete_key(key)
      msg = r ? 'key deleted' : 'key not found'
      [{delete_key: msg}.to_json, 'application/json']

    end
    
    # get_keys
    #
    get /^\/(.*)\?action=get_keys$/ do |key|
        
      recordset = @reg.get_keys(key)

      if recordset then
        [recordset.to_doc(root: 'recordset').root.xml, 'application/xml'] 
      else
          [{get_keys: 'empty'}.to_json, 'application/json']
      end
  
    end        
    
    # set_key
    #
    get /^\/(.*)\?v=/ do |key|

      val = params['v']
      
      begin
        e = @reg.set_key(key, val)
      rescue
        [{set_key: ($!)}.to_json, 'application/json']
      end
      
      [e.xml, 'application/xml']

    end    
    
    
    # get_key
    #
    get /^\/(.*)$/ do |key|

      begin
        e = @reg.get_key(key)
        [e.xml, 'application/xml'] 
      rescue
        [{get_key: 'key not found'}.to_json, 'application/json']
      end
      
    end    

  end
 
end