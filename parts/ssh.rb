# encoding: utf-8
require 'net/scp'
require 'net/ssh'
class SshPipe
    
    def initialize(call)
        @call = call
    end
    
    def init()
        @ssh = Net::SSH.start( $options[:host], $options[:username], :auth_methods => ['publickey','password'],  :keys => [$options[:key]]);
    end
    
    def upload(localName, remoteName)
        @ssh.scp.upload!(file, $options[:home] +  full, :chunk_size => 2048 * 32) do|ch, name, sent, total|
            call.update(name, sent, total)
        end
    end
    
    def writeData(data)
        File.open('data.txt', 'w') {|f| f.write(data) }
        puts ssh.scp.upload!('data.txt', $options[:home])
        File.delete('data.txt')
    end
    def writeDataVerse(data)
        File.open('data_verse.txt', 'w') {|f| f.write(data) }
        puts ssh.scp.upload!('data_verse.txt', $options[:home])
        File.delete('data_verse.txt')
    end
    def execInsert()
        puts ssh.exec!("php #{$options[:home]}api/insert.php"); # insert in the db
    end
    
    def execute(command)
    end
    def close()
        @ssh.close()
    end
end 
