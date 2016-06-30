# Introducing the Rack_dwsregistry gem

The Rack_dwsregistry gem runs within a Rack webserver which provides access to the XML based registry. The benefit of hosting the XML registry as a web service is that the key/value pairs can be retrieved or set easily from an HTTP request.

## Running the XML registry web service

Here's an example Rackup file used:

    # file: reg.ru

    require 'rack_dwsregistry'

    run RackDwsRegistry.new('/tmp/registry.xml')

The above would then be executed using the command `rackup reg.ru -p 9292 -o`. The port number is set to 9292, but any unreserved port can be used. The -o switch instructs the Rack web server to bind to all ports, not just localhost.

## Creating a new key

To create a new entry you can use the remote_dwsregistry gem or for convenience you can open a web browser and add the key through the URL e.g. http://127.0.0.1:9292/app/colour?v=red

## Resources

* rack_dwsregistry https://rubygems.org/gems/rack_dwsregistry

rack_dwsregistry registry rack rackdwsregistry dwsregistry
