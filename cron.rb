# encoding: utf-8
require 'rubygems'
require 'logger'
require 'time'
require 'fileutils'

require_relative 'config'
require_relative 'upload'
require_relative 'api'
require_relative 'parts/local'

# download/new/cat/lang/[serie]/title/date = stelle = preacher.mp3
$logger = Logger.new('logfile.log')
    
# a folder
def addFile(path)
    $logger.debug "add file: #{path}"
    mp3 = nil
    files = []
    Dir.foreach(path) do |item|
        next if item == '.' or item == '..'
        mp3 = path + '/' + item if (File.extname(item) == ".mp3")
        files <<  path + '/' + item
    end
    return :failed if mp3 == nil
    
    mp32 = mp3.dup
    reg = /\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)(\s*)=(\s*)([^\/=]+)(\s*)=(\s*)([^\/)=]+).mp3/
    #cat/lang/title/date = ref = preacher.mp3
    reg2 = /\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)(\s*)=(\s*)([^\/=]+)(\s*)=(\s*)([^\/)=]+).mp3/
    #      cat          /lang       /serie      /title  /  date         =       ref         =  preacher.mp3
    puts "cron.rb::addFile to match #{mp3}";
    mp32[$options[:newHome]] = "/"
    puts "cron.rb::addFile new to match #{mp32} #{mp3}";
    if(reg2 =~ mp32) 
        y = mp32.scan(reg2)[0]
        $options[:cat] = y[0]
        $options[:lang] = translateLang y[1]
        $options[:serie] = y[2]
        $options[:title] = y[3].strip
        $options[:date] = y[4].strip
        $options[:ref] = y[7].strip
        $options[:preacher] = y[10]
    elsif(reg =~ mp32) 
        y = mp32.scan(reg)[0]
        $options[:cat] = y[0]
        $options[:lang] = translateLang y[1]
        $options[:title] = y[2].strip
        $options[:date] = y[3].strip
        $options[:ref] = y[6].strip
        $options[:preacher] = y[9]
    else
        $logger.warn "didnt't match regexp"
        $logger.debug "failed to add #{path}"
        return :failed
    end
    $options[:mp3] = mp3
    $options[:files] = files
    $logger.debug "found one #{path}"
    return :ok
end
def translateLang(x)
    x.gsub("de", "de-DE").gsub("ru","ru-RU").gsub("en", "en-GB")
end

def addVideo(mp3File);
    resu = 10000
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
   # puts `ffmpeg -i '#{mp3File}' -acodec libopus '#{folder}ogg.ogg'`
    puts "executing ./fft_bin --file '#{folder}out.wav'"
    
    e = `./fft_bin --file '#{folder}out.wav'`
    puts e
    e = e.split(";");
    if(e.size != 3)
        $logger.debug "fft gave strange output #{e}"
        return
    end
    file = files[e[2].to_i]
    secs = e[0].to_i;
    len = e[1].to_i;

    mm1, ss1 = secs.divmod(60)
    hh1, mm1 = mm1.divmod(60)
    
    mm2, ss2 = len.divmod(60)
    hh2, mm2 = mm2.divmod(60)
    puts "cut from #{hh1}:#{mm1}:#{ss1}  whith length: #{hh2}:#{mm2}:#{ss2}"
    #filter  -vf pp=\"md|a/al|a/dr|a/tmpnoise|1|2|3\" -strict experimental 
    puts "../bin/ffmpeg -i '#{file}' -ss #{secs} -t #{len}  -acodec libfdk_aac -ab 64k -vcodec copy #{folder + "res.mp4"}"
    #  puts `../bin/ffmpeg -ss #{secs} -t #{len} -i '#{file}' -acodec libfdk_aac -ab 64k -vcodec copy #{folder + "res.mp4"}`
    puts `../bin/ffmpeg -i '#{file}' -ss #{secs} -t #{len}  -acodec libfdk_aac -ab 64k -vcodec copy #{folder + "res.mp4"}`
    if(not File.exists? folder + "res.mp4")
         $logger.warn "ffmpeg failed #{folder}"
         return
    else
    
    puts `qtfaststart #{folder + "res.mp4"} #{folder + "res2.mp4"}`
    puts `chmod +r #{folder + "res2.mp4"}`
    if(File.exists? folder + "res2.mp4")
         $options[:files] << folder + "res2.mp4";
    else
        $logger.warn "qtfaststart failed #{folder}"
    end
 #   $options[:files] << folder + "ogg.ogg";
    $deleteFolders << folder
end
def main
    
    getOptions()
    
    # scan
    $logger.debug "start"
    Dir.glob($options[:newHome] + "**/*").each do |item| # scan all folders
       
        next if item == '.' or item == '..' # skip
        next if(not File.directory? item) # skip files
        cleanOptions() # new option
        next if addFile(item) != :ok # add all files in this dir
        next if error_check($options) == :failed
        
        # add audio files
        # add Video file
        puts "has key #{$options[:videoPath].has_key? $options[:cat]} autoVideo = #{$options[:autoVideo]}"
        
        # check first for videos
        mp4 = nil

        Dir.foreach(item) do |i|
            next if i == '.' or i == '..'
            if (File.extname(i) == ".mp4")
                $options[:files] << path + '/' + i
                
                puts `../bin/ffmpeg -i '#{i}'  -acodec libfdk_aac -ab 64k -vcodec copy #{item + "res.mp4"}`
                if(not File.exists? i + "res.mp4")
                    $logger.warn "ffmpeg failed #{item}"
                    return
                else
                
                puts `qtfaststart #{item + "res.mp4"} #{item + "res2.mp4"}`
                puts `chmod +r #{item + "res2.mp4"}`
                if(File.exists? item + "res2.mp4")
                    $options[:files] << item + "res2.mp4";
                else
                    $logger.warn "qtfaststart failed #{item}"
                end
    
                mp4 = true
                break
            end
        end
    
        if($options[:videoPath].has_key?($options[:cat]) && $options[:autoVideo] == true && mp4 != nil)
            $logger.debug "add videos from wowza"
            addVideo($options[:mp3])
        end
        api = Api.new(LocalPipe.new)
        names = api.do_meta
        u = Upload.new(api)
        u.up(names)
        $deleteFolders << item
    end
    $logger.debug "done"
    
     $deleteFolders.each do |folder|
        if(File.exists? folder)
            puts "delete #{folder}"
            FileUtils.rm_rf(folder)
        end
     end
end
main()
