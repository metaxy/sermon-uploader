# encoding: utf-8
class LocalPipe
     def initialize()
    end
    
    def init()
        puts "local.rb init()"
    end
    
    def upload(localName, remoteName)
        puts "ssh.rb upload()"
        File.rename localName, remoteName
        # copy
    end
    
    def writeData(data)
        puts "local.rb writeData()"
        File.open($options[:home] + '/data.txt', 'w') {|f| f.write(data) }
    end
    def writeDataVerse(data)
        puts "local.rb writeDataVerse()"
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
 
