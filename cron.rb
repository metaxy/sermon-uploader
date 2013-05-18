# encoding: utf-8
require 'rubygems'

require './config.rb'
require './metadata.rb'
require './upload.rb'
require './api.rb'
require './parts/local.rb'

def main

    getOptions()
    # some error checking
    return if error_check($options) == :failed
    
    names = do_meta()

    api = Api.new(LocalPipe.new)
    u = Upload.new(api)
    u.up(names)
end
main()