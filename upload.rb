# encoding: utf-8
require 'net/scp'
require './cmd.rb'

def remotePath(local)
    ext = File.extname(local)
    cat = $paths[$options[:cat]]
    type =  case ext
                when ".mp3"
                    "audio"
                when ".mp4"
                    "video"
                else
                    "extra" 
            end
    
    year = Date.parse($options[:date]).year.to_s
    
    return "#{cat}/#{type}/#{year}"
end

def uploadFile(file, ssh, call)
    puts "upload.rb :::: Uploading";
    puts "from #{file} to #{remotePath(file) + File.basename(file)}"
    rem = $options[:home] + remotePath(file)
    
    ssh.scp.upload!(file, rem, :chunk_size => 2048 * 32) do|ch, name, sent, total|
        call.update(name, sent, total)
    end
    
    return (remotePath(file) + "/" + File.basename(file))
end 
