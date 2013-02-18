require 'json'
require 'net/ssh'

def near(res, name)
    puts "register.rb :::: got resp " + res;
    json = JSON.parse(res)
    json.each do |x|
        if(name == x[0])
            return x[0]
        end
    end
    json.each do |x|
        if(name == x[2])
            return x[0]
        end
    end
    json.each do |x|
        if(name == x[1])
            return x[0]
        end
    end
    return "0"
end
def getSpeakerID(name)
    res = Net::HTTP.get URI($options[:api] + "action=list_speakers")
    return near(res,name)
end

def getSeriesID(name)
    res = Net::HTTP.get URI($options[:api] + "action=list_series")
    return near(res,name)
end

def getCatID(name)
    res = Net::HTTP.get URI($options[:api] + "action=list_cats")
    return near(res,name)
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
    data = Hash["speaker_id" => speaker_id,
                'series_id' => series_id,
                'audiofile' => audiofile,
                'videofile' => videofile,
                'sermon_title' => $options[:title],
                'alias' => $options[:title],
                'addfile' => addfile,
                'addfileDesc' => "Notizen",
                'catid' => cat_id,
                'language' => '*',
                'sermon_date' => $options[:date],
                'sermon_time' => ""
             ]
    j = data.to_json.to_s
    # puts "audio.rb :::: json = " + j
    puts ssh.exec!("echo '" + j + "' > #{$options[:home]}data.txt");
    puts ssh.exec!("php #{$options[:home]}components/com_sermonspeaker/api/insert.php");
end 
