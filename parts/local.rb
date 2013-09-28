# encoding: utf-8
require 'fileutils'
class LocalPipe
     def initialize()
    end
    
    def init()
        puts "local.rb init()"
    end
    
    def upload(localName, remoteName)
        puts "local.rb upload()"
        if(not File.exists?(File.dirname(remoteName)))
           Dir.mkdir(File.dirname(remoteName))
        end
        
        FileUtils.cp localName, remoteName
    end
    
    def writeData(data)
        puts "local.rb writeData()"
        puts data
        File.open($options[:home] + '/data.txt', 'w') {|f| f.write(data) }
    end
    def writeDataVerse(data)
        puts "local.rb writeDataVerse()"
        puts data
        File.open($options[:home] + 'data_verse.txt', 'w') {|f| f.write(data) }
    end
    def execInsert()
        puts "local.rb execInsert()"
        puts system("php #{$options[:home]}api/insert.php"); # insert in the db
    end
    
    def close()
        puts "local.rb close()"
    end
end
 
