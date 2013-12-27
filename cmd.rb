# encoding: utf-8
require 'rubygems'

require_relative 'config'
require_relative 'upload'
require_relative 'api'
require_relative 'parts/ssh'
require_relative 'file'
require_relative 'register'

def konsole_update(name, sent, total)
    total += 0.0000000001
    print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
end

def main
    getOptions()
    # some error checking
    return if error_check_options($options) == :failed
    $options = prepare_files($options)
    $options = upload($options, method(:ssh_upload), method(:konsole_update))
    register($options)
end
main()