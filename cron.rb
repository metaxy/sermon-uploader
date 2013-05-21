# encoding: utf-8
require 'rubygems'

require './config.rb'
require './metadata.rb'
require './upload.rb'
require './api.rb'
require './parts/local.rb'
# download/new/cat/title/date - stelle - preacher.mp3

# a folder
def addFile(path)
    puts "cron.rb addFile #{path}"
    mp3 = nil
    files = []
    Dir.foreach(path) do |item|
        next if item == '.' or item == '..'
        mp3 = item if (File.extname(item) == ".mp3")
        files << item
    end
    return :failed if mp3 == nil
    reg = /\/(\w+)\/(\w+)\/(\w+)(\s*)-(\s*)(\w+)(\s*)-(\s*)(\w+).mp3/
    if(reg =~ mp3) 
        y = mp3.scan(reg)   
        $options[:cat] = y[0]
        $options[:title] = y[1]
        $options[:date] = y[2]
        $options[:ref] = y[5]
        $options[:preacher] = y[8]
    else
        return :failed
    end
    $options[:files] = files
    return :ok
end

def main
    
    getOptions()
    
    # scan
    
    Dir.glob($options[:newHome] + "/**/*").each do |item|
        puts "item #{item}"
        next if item == '.' or item == '..'
        next if(not File.directory? item)
        cleanOptions()
        puts item
        
        next if addFile(item) != :ok
        next if error_check($options) == :failed
    
        names = do_meta()

        api = Api.new(LocalPipe.new)
        u = Upload.new(api)
        u.up(names)
    end
    puts "done"
    # some error checking
   
end
main()