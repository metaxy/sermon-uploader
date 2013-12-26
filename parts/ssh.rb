# encoding: utf-8
require 'net/scp'
require 'net/ssh'
class SshPipe
    
    def initialize(call)
        puts "SshPipe.initialize";
        @call = call
    end
    
    def init()
        puts "ssh.rb init()"
        @ssh = Net::SSH.start( $options[:host], $options[:username], :auth_methods => ['publickey','password'],  :keys => [$options[:key]]);
    end
    
    def upload(localName, remoteName)
        puts "ssh.rb upload()"
        @ssh.scp.upload!(localName, remoteName, :chunk_size => 2048 * 32) do|ch, name, sent, total|
            @call.update(name, sent, total)
        end
    end
    
    def close()
        puts "ssh.rb close()"
        @ssh.close()
    end
end 
