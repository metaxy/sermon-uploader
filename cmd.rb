# encoding: utf-8
require 'rubygems'

require './config.rb'
require './metadata.rb'
require './register.rb'
require './upload.rb'



def main

    getOptions()
    # some error checking
    return if error_check() == :failed
    names = do_meta()
    up(names, CmdBar.new)
    
end
main()