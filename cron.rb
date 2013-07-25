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
    if(reg =~ mp3) 
        y = mp3.scan(reg)[0]
        $options[:cat] = y[0]
        $options[:title] = y[1]
        $options[:date] = y[2].strip
        $options[:ref] = y[5]
        $options[:preacher] = y[8]
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
    puts "executing ffmpeg -y -i '#{mp3File}' -ar 5000 -ac 1 '#{folder}out.wav'"
    puts `ffmpeg -i '#{mp3File}' -ar 5000 -ac 1 '#{folder}out.wav'`
    date = Date.parse($options[:date])
    i = 0
    files = []
    Dir.foreach($options[:videoPath]).each do |item|#
        fullItem = $options[:videoPath] + "/" + item
        next if !item.include? "360p" or !item.include? ".mp4" # filter by 320p or source and .mp4
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
    puts "executing ./fft_bin --file '#{folder}out.wav'"
    
    e = `./fft_bin --file '#{folder}out.wav'`
    puts e
    e = e.split(";");
    file = files[e[2]]
    secs = e[0];
    len = e[1];
    
    # todo secs and len from "sec" to "hour" convert
    mm1, ss1 = secs.divmod(60)
    hh1, mm1 = mm1.divmod(60)
    
    mm2, ss2 = len.divmod(60)
    hh2, mm2 = mm2.divmod(60)
    
    puts "ffmpeg -ss #{hh1}:#{mm1}:#{ss1} -t #{hh2}:#{mm2}:#{ss2} -i '#{file}' -acodec copy -vcodec copy #{folder + "res.mp4"}"

    puts `ffmpeg -ss #{hh1}:#{mm1}:#{ss1} -t #{hh2}:#{mm2}:#{ss2} -i '#{file}' -acodec copy -vcodec copy #{folder + "res.mp4"}`
    
    puts file
end
def main
    
    getOptions()
    
    # scan
    
    Dir.glob($options[:newHome] + "**/*").each do |item|
        next if item == '.' or item == '..'
        next if(not File.directory? item)
        cleanOptions()
        $logger.debug  item
        
        next if addFile(item) != :ok
        $logger.debug  $options
        next if error_check($options) == :failed
        
        # add audio files
        names = []
       # names << do_meta()
        # add Video file
        if($options[:autoVideo])
            $logger.debug "add videos"
            puts "add videos"
            names << addVideo($options[:mp3])
        end
     #   api = Api.new(LocalPipe.new)
  #      u = Upload.new(api)
  #      u.up(names)
    end
    $logger.debug "done"
    # some error checking
   
end
main()
