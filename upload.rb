# encoding: utf-8
require 'net/scp'
require 'date'

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
    full = remotePath(file) + "/" + File.basename(file)
    puts "upload.rb :::: Uploading";
    puts "from #{file} to #{full}"
    
    rem = $options[:home] + remotePath(file)
    
    ssh.scp.upload!(file, rem, :chunk_size => 2048 * 32) do|ch, name, sent, total|
        call.update(name, sent, total)
    end
    
    return (full)
end
def trying(t, func, *args)
    ret = nil
    t.times do
        begin
            return func.call(*args)
        rescue
            puts "It failed"
        end
    end
    puts "its failed complete"
    return ret
end
def up(names, call)
    newPaths = []
    Net::SSH.start( $options[:host], $options[:username], :auth_methods => ['publickey','password'],  :keys => [$options[:key]]) do |ssh|
        names.each do |name|
            newPaths << trying(3, method(:uploadFile), name, ssh, call)
        end
        puts newPaths
        register(newPaths, ssh)
    end
    return newPaths
end