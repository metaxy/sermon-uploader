# encoding: utf-8
require 'json'
require 'net/ssh'
require 'net/http'
require './cmd.rb'
def near(res, name)
    #puts "register.rb :::: got resp " + res;
    # id, name, alias
    json = JSON.parse(res)
    json.each do |x|
        if(name == x[0])
            return x[0]
        end
    end
    json.each do |x|
        if(name.downcase == x[2].downcase)
            return x[0]
        end
    end
    json.each do |x|
        if(name.downcase == x[1].downcase)
            return x[0]
        end
    end
    puts "didn't found #{name}"
    return "0"
end
def getSpeakerID(name)
    res = Net::HTTP.get URI($options[:api] + "action=list_speakers")
    return near(res, name)
end

def getSeriesID(name)
    res = Net::HTTP.get URI($options[:api] + "action=list_series")
    return near(res, name)
end

def getCatID(name)
    res = Net::HTTP.get URI($options[:api] + "action=list_cats")
    return near(res, name)
end
def refToJson()
    if(/(\w+)\s(\d+)\:(\d+)/ =~ $options[:ref])
        y = $options[:ref].scan(/(\w+)\s(\d+)\:(\d+)/) # BookName 1:1
        x = y[0]
        return Hash['book' => bookName(x[0]),
                    'cap1' => x[1],
                    'vers1' => x[2],
                    'cap2' => x[1],
                    'vers2' => x[2]].to_json.to_s
    end
    
    if(/(\w+)\s(\d+)\:(\d+)-(\d+)/ =~ $options[:ref]) # BookName 1:1-12
        y = $options[:ref].scan(/(\w+)\s(\d+)\:(\d+)/)   
        x = y[0]
        return Hash['book' => bookName(x[0]), 
                'cap1' => x[1],
                'vers1' => x[2],
                'cap2' => x[1],
                'vers2' => x[3]].to_json.to_s
    end
    
    if(/(\w+)\s(\d+)\:(\d+)-(\d+)\:(\d+)/ =~ $options[:ref]) # BookName 1:1-2:12
        y = $options[:ref].scan(/(\w+)\s(\d+)\:(\d+)-(\d+)\:(\d+)/)  
        x = y[0]
        return Hash['book' => bookName(x[0]),
                'cap1' => x[1],
                'vers1' => x[2],
                'cap2' => x[3],
                'vers2' => x[4]].to_json.to_s
    end
    
    return nil
end
                                                     
def bookName(bookName)
    return 1
end

def haveRef?
    return $options[:ref] != nil
end

def register(newPaths, ssh)
    speaker_id = getSpeakerID($options[:preacher])
    series_id = getSeriesID($options[:serie])
    cat_id = getCatID($options[:cat])

    audiofile = ""
    videofile = ""
    addfile = ""
    newPaths.each do |x|
        ext = File.extname(x)
        case ext
            when ".mp3"
                audiofile = x
            when ".mp4"
                videofile = x
            else
                addfile = x
        end
    end
    data = Hash['speaker_id' => speaker_id,
                'series_id' => series_id,
                'audiofile' => audiofile,
                'videofile' => videofile,
                'sermon_title' => $options[:title],
                'alias' => $options[:title],
                'addfile' => addfile,
                'addfileDesc' => $options[:addfileDesc],
                'catid' => cat_id,
                'language' => $options[:lang],
                'sermon_date' => $options[:date],
                'sermon_time' => ""
             ]
    j = data.to_json.to_s

    puts ssh.exec!("echo '" + j + "' > #{$options[:home]}data.txt"); # write all the data
    
    if haveRef?
        puts "ref json = " + refToJson()
        puts ssh.exec!("echo '" + refToJson() + "' > #{$options[:home]}data_verse.txt"); # write all the data
    end
    puts ssh.exec!("php #{$options[:home]}components/com_sermonspeaker/api/insert.php"); # insert in the db
end 
