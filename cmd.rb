# encoding: utf-8
require 'rubygems'

require './config.rb'
require './metadata.rb'
require './upload.rb'
require './api.rb'
require './parts/ssh.rb'

class CmdBar 
    def update(name, sent, total)
        print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
    end
end

def main

    getOptions()
    # some error checking
    return if error_check($options) == :failed
    
    names = do_meta()

    api = Api.new(SshPipe.new(CmdBar.new))
    u = Upload.new(api)
    u.up(names)
    
end
main()