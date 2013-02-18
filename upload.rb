require 'net/scp'
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
    
    return "#{cat}/#{type}/#{year}/"
end

def upload(file, ssh)
    puts "upload.rb :::: Uploading";

    ssh.scp.upload!(file, $otions[:home] + remotePath(file), :chunk_size => 2048 * 32) do|ch, name, sent, total|
        print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
    end
    
    return (remotePath(file) + File.basename(file))
end 
