# encoding: utf-8
require 'date'
require 'net/http'
require 'json'
require 'taglib'


def trying(t, func, *args)
    t.times do
        begin
            return func.call(*args)
        rescue Exception => e  
            puts e.message  
            puts e.backtrace.inspect  
            puts "It failed"
        end
    end
    return nil
end

class Api
    
    def initialize(pipe)
        @pipe = pipe
        @pipe.init()
    end
    
    def getSpeakers()
        res = Net::HTTP.get URI($options[:api] + "sermons/listSpeaker")
        json = JSON.parse(res)
        json.map { |x| x[1]}
    end

    def getSeries()
        res = Net::HTTP.get URI($options[:api] + "sermons/listSeries")
        json = JSON.parse(res)
        #puts json
        json.map { |x| x[2]}
    end
    
    def remotePath(local)
        ext = File.extname(local)
        cat = $paths[$options[:cat]]
        type =  case ext.downcase
                    when ".mp3"
                        "audio"
                    when ".ogg"
                        "audio"
                    when ".mp4"
                        "video"
                    else
                        "extra" 
                end
        
        year = Date.parse($options[:date]).year.to_s
        
        return "#{cat}/#{type}/#{year}"
    end

    def upload(file)
        full = remotePath(file) + "/" + File.basename(file)
        #puts "api.rb upload :::: Uploading";
        #puts "from #{file} to #{full}"
        
        @pipe.upload(file, $options[:filesHome] +  full)
        
        return full
    end
    
    def closePipe()
        @pipe.close();
    end
end

