# encoding: utf-8
require 'net/scp'
require 'net/ssh'

def ssh_upload(local_name, remote_name, call)
    puts "upload from #{local_name} to #{remote_name}"
    ssh = Net::SSH.start( $options[:host], $options[:username], :auth_methods => ['publickey','password'],  :keys => [$options[:key]]);
    dir = File.dirname(remote_name)
    ssh.exec "mkdir -p #{dir}"
    ssh.scp.upload!(local_name, remote_name, :chunk_size => 2048 * 32) do|ch, name, sent, total|
        call.call(name, sent, total) if call != nil
    end
    ssh.close()
end

