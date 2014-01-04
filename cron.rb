# encoding: utf-8
require 'rubygems'
require 'time'
require 'fileutils'

require_relative 'config'
require_relative 'upload'
require_relative 'api'
require_relative 'file'
require_relative 'parts/local'

# download/new/cat/lang/[serie]/title/date = stelle = preacher.mp3
def find_all_files(path)
    files = []
    Dir.foreach(path) do |item|
        next if item == '.' or item == '..'
        files <<  path + '/' + item
    end
    return files
end
# a folder
def add_file(path)
    file_info = Hash[]
    files = find_all_files(path)
    files = files.keep_if { |f| File.extname(f).downcase != ".mp4" }
    puts "all files #{files}"
    mp3s = files.keep_if { |f| File.extname(f).downcase == ".mp3" }                  
    return nil if mp3s.empty?
    mp3 = mp3s.first
    mp3_ = mp3.dup
    
    reg = /\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)(\s*)=(\s*)([^\/=]+)(\s*)=(\s*)([^\/)=]+).mp3/
    #cat/lang/title/date = ref = preacher.mp3
    reg_serie = /\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)\/([^\/=]+)(\s*)=(\s*)([^\/=]+)(\s*)=(\s*)([^\/)=]+).mp3/
    #      cat          /lang       /serie      /title  /  date         =       ref         =  preacher.mp3
    
    mp3_[$options[:newHome]] = "/"
    if(reg_serie =~ mp3_) 
        y = mp3_.scan(reg_serie)[0]
        file_info[:group_name] = y[0]
        file_info[:lang] = translate_lang y[1]
        file_info[:serie] = y[2]
        file_info[:title] = y[3].strip
        file_info[:date] = y[4].strip
        file_info[:ref] = y[7].strip
        file_info[:speaker] = fix_speaker y[10]
    elsif(reg =~ mp3_) 
        y = mp3_.scan(reg)[0]
        file_info[:group_name] = y[0]
        file_info[:lang] = translate_lang y[1]
        file_info[:title] = y[2].strip
        file_info[:date] = y[3].strip
        file_info[:ref] = y[6].strip
        file_info[:speaker] = fix_speaker y[9]
    else
        $logger.warn "didnt't match regexp #{path}"
        return nil
    end
    file_info[:mp3] = mp3
    file_info[:files] = files
    make_backup(path, file_info)
    return file_info
end

def make_backup(path, file_info)
    b = "#{$options[:backup_path]}#{$options[:user]}/#{file_info[:group_name]}/"
    FileUtils.mkpath(b);
    FileUtils.cp_r(path, b)
end

def translate_lang(x)
    x.split(",")
end

def add_video(file_info);
    mp3File = file_info[:mp3]
   # $logger.debug "addVideo #{path}"
    folder = $options[:tmp] + file_info[:date] + "/";
    clear_folder(folder)
    files = parse_livestreams(file_info, Date.parse(file_info[:date]), folder)
    return nil if files.length == 0
        
    $logger.debug `ffmpeg -i '#{mp3File}' -ar 5000 -ac 1 '#{folder}out.wav'`
    
    (file,secs,len) = run_fft(folder)
    file = files[file]
    return nil if file.nil?
    cut_file(file, secs, len, folder)
    
    if(not File.exists? folder + "res.mp4")
         $logger.warn "ffmpeg failed #{folder}"
         return
    end
    $deleteFolders << folder
    
    file = faststart(folder + "res.mp4", folder + "res2.mp4")
    if(file.nil?)
        file = folder + "res.mp4";
    end
    file_info[:files] << file
    return file
end
def clear_folder(folder)
     if(File.exists? folder)
        FileUtils.rm_rf(folder) # remove everything
    end
    Dir.mkdir(folder)
end
def faststart(file, new_file)
    puts `qtfaststart '#{file}' '#{new_file}'`
    if(File.exists? new_file)
        puts `chmod +r '#{new_file}'`
        return new_file;
    else
        $logger.warn "qtfaststart failed #{new_file}"
        return nil;
    end
end
def parse_livestreams(file_info, date, new_folder)
    files = []
    path_to_videos =  $options[:videoPath][file_info[:group_name]]
    i = 0
    Dir.foreach(path_to_videos).each do |item|
        fullItem = path_to_videos + "/" + item
        fileTime = File.mtime(fullItem)
        
        next if !item.include? "source" or !item.include? ".mp4" # filter by source and .mp4
        
        if(fileTime.year == date.year && fileTime.yday == date.yday)
            $logger.debug `ffmpeg -y -i '#{fullItem}' -ar 5000 -ac 1 '#{new_folder}out.wav#{i}.wav'`
            files << fullItem
            i += 1
        end
    end
    return files
end

def run_fft(folder)
    $logger.debug "#{$options[:binhome]}sermon-uploader/fft_bin --file '#{folder}out.wav'"
    e = `#{$options[:binhome]}sermon-uploader/fft_bin --file '#{folder}out.wav'`
    #puts e
    e = e.split(";");
    if(e.size != 3)
        $logger.debug "fft gave strange output #{e}"
        return nil
    end
    file = e[2].to_i
    secs = e[0].to_i;
    len = e[1].to_i;
    
    return [file,secs,len]
end
def cut_file(file,start,length, folder)
    #  puts `../bin/ffmpeg -ss #{secs} -t #{len} -i '#{file}' -acodec libfdk_aac -ab 64k -vcodec copy #{folder + "res.mp4"}`
    $logger.debug `ffmpeg -i '#{file}' -ss #{start} -t #{length}  -acodec libfaac -ab 64k -vcodec copy '#{folder + "res.mp4"}'`
end

def parse_videos(file_info, item)
    Dir.foreach(item) do |i|
        ii = item + "/" + i;
        next if i == '.' or i == '..'
        if (File.extname(ii) == ".mp4")
            $logger.debug `qtfaststart '#{ii}' '#{item + "/res2.mp4"}'`
            if(File.exists? item + "/res2.mp4")
                $logger.debug `chmod +r '#{item + "/res2.mp4"}'`
                file_info[:files] << item + "/res2.mp4";
            else
                file_info[:files] << ii;
                $logger.warn "qtfaststart failed #{item}"
            end

            return :yes
            break
        end
   end
   return :no
end

def main
    getOptions()
    return if error_check_options($options) == :failed
    #puts $options.to_yaml
    Dir.glob($options[:newHome] + "**/*").each do |item| # scan all folders
        next if item == '.' or item == '..' 
        next if not File.directory? item # skip files
        
        cleanOptions() # new option
        
        file_info = add_file(item)
        next if file_info.nil?
        next if error_check_file(file_info) == :failed
        
        # check first for videos
        has_videos = parse_videos(file_info, item)
        if($options[:videoPath].has_key?(file_info[:group_name]) && $options[:autoVideo] == true && has_videos == :no)
            add_video(file_info)
        end
        
        file_info = prepare_files(file_info)
        file_info = upload(file_info, method(:local_upload), nil)
        register(file_info)
        
        $deleteFolders << item
    end
    
    delete_folders()
end

def delete_folders()
    $deleteFolders.each do |folder|
        if(File.exists? folder)
           $logger.debug "delete #{folder}"

            puts "delete #{folder}"
            FileUtils.rm_rf(folder)
        end
     end
end
main()
