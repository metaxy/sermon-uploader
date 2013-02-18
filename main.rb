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
        if(! File.exists?(x)) 
            puts "Die Datei #{x} existiert nicht" 
            return :failed
        end
    end
    return :ok
end

def main
    
    cmd()
    
    newPaths = []
    # some error checking
    return if error_check() == :failed
    
    Net::SSH.start( $options[:host], 
                     $options[:username], 
                     :auth_methods => ['publickey','password'], 
                     :keys => [$options[:key]]
                   ) do |ssh|
        $options[:files].each do |x|
            puts "main.tb :::: processing filename = " + x
            
            newName = rename(x)
            
            writeid3(newName) if File.extname(newName) == ".mp3"
            
            newPaths << upload(newName, ssh)
        end
        register(newPaths,ssh)
    end
    
end
# run programm
main() 
