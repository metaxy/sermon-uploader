# encoding: utf-8
require 'rubygems'
require 'logger'
require 'time'
require 'fileutils'

require_relative 'config'
require_relative 'metadata'
require_relative 'upload'
require_relative 'api'
require_relative 'parts/local'

# download/new/cat/title/date = stelle = preacher.mp3
$logger = Logger.new('logfile.log')
    
# a folder
def addFile(path)
    mp3 = nil
    files = []
    Dir.foreach(path) do |item|
        next if item == '.' or item == '..'
        mp3 = path + '/' + item if (File.extname(item) == ".mp3")
        files <<  path + '/' + item
    end
    return :failed if mp3 == nil
    reg = /\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)(\s*)=(\s*)([^\/=]+)(\s*)=(\s*)([^\/)=]+).mp3/
    reg2 = /\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)(\s*)=(\s*)([^\/=]+)(\s*)=(\s*)([^\/)=]+).mp3/
    if(reg =~ mp3) 
        y = mp3.scan(reg)[0]
        $options[:cat] = y[0]
        $options[:title] = y[1]
        $options[:date] = y[2].strip
        $options[:ref] = y[5].strip
        $options[:preacher] = y[8]
    elsif(reg2 =~ mp3) 
        y = mp3.scan(reg)[0]
        $options[:cat] = y[0]
        $options[:serie] = y[1]
        $options[:title] = y[2]
        $options[:date] = y[3].strip
        $options[:ref] = y[6].strip
        $options[:preacher] = y[9]
    else
        $logger.warn "didnt't match regexp"
        return :failed
    end
    $options[:mp3] = mp3
    $options[:files] = files
    $logger.debug "found one #{path}"
    return :ok
end


def addVideo(mp3File);
    folder = $options[:tmp] + $options[:date] + "/";
    if(File.exists? folder)
        FileUtils.rm_rf(folder) # remove everything
    end
    Dir.mkdir(folder)
   
    date = Date.parse($options[:date])
    i = 0
    files = []
    Dir.foreach($options[:videoPath][$options[:cat]]).each do |item|#
        fullItem = $options[:videoPath][$options[:cat]] + "/" + item
        next if !item.include? "source" or !item.include? ".mp4" # filter source and .mp4
        fileTime = File.mtime(fullItem)
        if(fileTime.year == date.year && fileTime.yday == date.yday)
            $logger.debug "found right day #{item}"
            puts "found right day #{item}"           
            puts "executing ffmpeg -i '#{fullItem}' -ar 5000 -ac 1 '#{folder}out.wav#{i}.wav'" 
            puts `ffmpeg -y -i '#{fullItem}' -ar 5000 -ac 1 '#{folder}out.wav#{i}.wav'`
            files[i] = fullItem
            i += 1
        end
    end
    if(i == 0)
        $logger.debug "no videos found"
        return;
    end
    puts "executing ffmpeg -y -i '#{mp3File}' -ar 5000 -ac 1 '#{folder}out.wav'"
    puts `ffmpeg -i '#{mp3File}' -ar 5000 -ac 1 '#{folder}out.wav'`
    puts `ffmpeg -i '#{mp3File}'  '#{folder}ogg.ogg'`
    puts "executing ./fft_bin --file '#{folder}out.wav'"
    
    e = `./fft_bin --file '#{folder}out.wav'`
    puts e
    e = e.split(";");
    if(e.size != 3)
        $logger.debug "fft gave strange input"
        return
    end
    file = files[e[2].to_i]
    secs = e[0].to_i;
    len = e[1].to_i;
    
    
    # todo secs and len from "sec" to "hour" convert
    mm1, ss1 = secs.divmod(60)
    hh1, mm1 = mm1.divmod(60)
    
    mm2, ss2 = len.divmod(60)
    hh2, mm2 = mm2.divmod(60)
    
    puts "ffmpeg -ss #{hh1}:#{mm1}:#{ss1} -t #{hh2}:#{mm2}:#{ss2} -i '#{file}' -acodec copy -vcodec copy #{folder + "res.mp4"}"

    puts `ffmpeg -ss #{hh1}:#{mm1}:#{ss1} -t #{hh2}:#{mm2}:#{ss2} -i '#{file}'  -vf pp="md|a/al|a/dr|a/tmpnoise|1|2|3" -acodec aac -strict experimental -ab 128k -vcodec copy #{folder + "res.mp4"}`
    
    puts `qtfaststart #{folder + "res.mp4"} #{folder + "res2.mp4"}`
    puts `chmod +r #{folder + "res2.mp4"}`
    
    $options[:files] << folder + "res2.mp4";
    $options[:files] << folder + "ogg.ogg";
end
def main
    
    getOptions()
    
    # scan
    Dir.glob($options[:newHome] + "**/*").each do |item| # scan all folders
        next if item == '.' or item == '..' # skip
        next if(not File.directory? item) # skip files
        cleanOptions() # new option
        $logger.debug  item
        
        next if addFile(item) != :ok # add all files in this dir
        $logger.debug $options
        next if error_check($options) == :failed
        
        # add audio files
        # add Video file
        if($options[:videoPath].has_key? $options[:cat])
            $logger.debug "add videos"
            puts "add videos"
            addVideo($options[:mp3])
        end
        names = do_meta()
        api = Api.new(LocalPipe.new)
        u = Upload.new(api)
        u.up(names)
    end
    $logger.debug "done"
    # some error checking
   
end
main()
