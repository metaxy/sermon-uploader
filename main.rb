# encoding: utf-8
require 'rubygems'
require 'date'
require './config.rb'
require './cmd.rb'
require './metadata.rb'
require './register.rb'
require './upload.rb'

def error_check()

    neededOptions = [:title, :preacher, :date, :cat, :files]
    
    neededOptions.each do |x|
        if($options[x] == nil) 
            puts "Die Variable #{x} fehlt" 
            return :failed
        end
    end
    $options[:files].each do |x|
        if(!File.exists?(x)) 
            puts "Die Datei #{x} existiert nicht" 
            return :failed
        end
    end
    puts $options
    return :ok
end

def do_meta
    newNames = []
    $options[:files].each do |x|
        puts "main.tb :::: processing filename = " + x
            
        newName = rename(x)
        writeid3(newName) if File.extname(newName) == ".mp3"
        newNames << newName
    end
    newNames
end

class CmdBar 
    def update(name, sent, total)
        print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
    end
end

def main

    cmd()
    # some error checking
    return if error_check() == :failed
    
    names = do_meta()
    up(names, CmdBar.new)
    
end
