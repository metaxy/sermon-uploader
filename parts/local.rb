# encoding: utf-8
require 'fileutils'
class LocalPipe
     def initialize()
    end
    
    def init()
        #puts "local.rb init()"
    end
    
    def upload(localName, remoteName)
        #puts "local.rb upload()"
        if(not File.exists?(File.dirname(remoteName)))
           FileUtils.mkdir_p(File.dirname(remoteName))
        end
        
        FileUtils.cp localName, remoteName
    end
    
    def close()
        #puts "local.rb close()"
    end
end
 
