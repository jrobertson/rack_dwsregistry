#!/usr/bin/env ruby

# file: rack_dwsregistry.rb


require 'drb'
require 'json'
require 'rexle'
require 'app-routes'


class RackDwsRegistry
  include AppRoutes


  def initialize(host: 'localhost', port: '59500')
    
    super() # required for app-routes initialize method to exectue
    DRb.start_service

    # attach to the DRb server via a URI given on the command line
    @reg = DRbObject.new nil, "druby://#{host}:#{port}"
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
    
    # xpath
    #
    get /\/\?xpath=/ do

      xpath = params['xpath']
      
      r = @reg.xpath(xpath)

      return [{xpath: 'empty'}.to_json, 'application/json'] if r.empty?
      
      [r, 'application/xml'] 
      
    end         
    
    # get_key('.')
    #
    get '/' do |key|

      reg_get '.'
      
    end
    
    # import
    #
    post '/import' do
      
      reg_import params['s']
      
    end    
    
    get '/refresh' do

      refresh()
      'refreshed'
      
    end       
    
    # set_key
    #
    post /^\/(.*)$/ do |key|
      
      reg_set key, params      
      
    end
    
    # delete_key
    #
    get /^\/(.*)\?action=delete_key$/ do |key|

      msg = @reg.delete_key(key)
      [{delete_key: msg}.to_json, 'application/json']

    end
    
    # get_keys
    #
    get /^\/(.*)\?action=get_keys$/ do |key|

      begin
        
        r = @reg.get_keys(key)
        return [{get_keys: 'empty'}.to_json, 'application/json'] unless r
        
        [r, 'application/xml']         
      
      rescue
        
        return [{get_keys: 'key not found'}.to_json, 'application/json'] unless r
        
      end
  
    end        
    
    # set_key
    #
    get /^\/(.*)\?v=/ do |key|

      reg_set key, params

    end    
    
    
    # get_key
    #
    get /^\/(.*)$/ do |key|

      reg_get key
      
    end    

  end
  
  private
  
  
  def refresh()
    @reg.refresh
  end
  
  def reg_get(key)
    
    begin
      
      r = @reg.get_key(key)          
      return [{get_key: 'key not found'}.to_json, 'application/json'] if r.empty?
      
      [r, 'application/xml']       
      
    rescue
      
      return [{get_key: 'key not found'}.to_json, 'application/json']
      
    end
    
  end
  
  def reg_import(s)
    
    r, status = @reg.import(s)
    return [{import_key: (status)}.to_json, 'application/json'] unless r
    
    ['<import>success</import>', 'application/xml']
    
  end
  
  def reg_set(key, params)
    
    val = params['v']
    
    r, status = @reg.set_key(key, val)    
    return [{set_key: (status)}.to_json, 'application/json'] unless r
    
    [r, 'application/xml']
    
  end  
  
end