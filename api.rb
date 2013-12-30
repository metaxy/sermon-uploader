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


end

