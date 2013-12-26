# encoding: utf-8
require 'rubygems'

require_relative 'config'
require_relative 'upload'
require_relative 'api'
require_relative 'parts/ssh'
require_relative 'file'
require_relative 'register'
class CmdBar 
    def update(name, sent, total)
        print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
    end
end

def main
    getOptions()
    # some error checking
    return if error_check($options) == :failed
    
    api = Api.new(SshPipe.new(CmdBar.new))
    $options[:new_file_names] = []
    $options[:files].each do |file|
        $options[:new_file_names] << prepare_file(file, $options)
    end
    register($options)
    
end
main()