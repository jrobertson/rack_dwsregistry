#!/usr/bin/env ruby

# file: rack_dwsregistry.rb


require 'json'
require 'app-routes'
require 'dws-registry'


class RackDwsRegistry
  include AppRoutes


  def initialize(filename='registry.xml')

    super() # required for app-routes initialize method to exectue
    @filename = filename
    load_reg()

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
      
      recordset = @reg.xpath(xpath)

      if recordset then
        [recordset.to_doc(root: 'recordset').root.xml, 'application/xml'] 
      else
          [{xpath: 'empty'}.to_json, 'application/json']
      end
      
    end         
    
    # get_key('.')
    #
    get '/' do |key|

      reg_get '.'
      
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

      reg_set key, params

    end    
    
    
    # get_key
    #
    get /^\/(.*)$/ do |key|

      reg_get key
      
    end    

  end
  
  private
  
  def load_reg()
    @reg = DWSRegistry.new(@filename)    
  end
  
  alias refresh load_reg
  
  def reg_get(key)
    
    begin
      e = @reg.get_key(key)
      [e.xml, 'application/xml'] 
    rescue
      [{get_key: 'key not found'}.to_json, 'application/json']
    end
    
  end
  
  def reg_set(key, params)
    
    val = params['v']
    
    begin
      e = @reg.set_key(key, val)
    rescue
      [{set_key: ($!)}.to_json, 'application/json']
    end
    
    [e.xml, 'application/xml']
    #{key: key, val: val}.inspect
    
    
  end  
  
end