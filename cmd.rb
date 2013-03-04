# encoding: utf-8
require 'optparse'
def cmd
    optparse = OptionParser.new do|opts|
    opts.banner = "Usage: main.rb [options]"
    
    $options[:files] = Array.new
    opts.on( '-f', '--file FILENAMES', 'Which files to upload' ) do |file|
        $options[:files] << File.absolute_path(file)
    end
    $options[:title] = nil
    opts.on( '-t', '--title TITLE', 'Title' ) do |x|
        $options[:title] = x
    end
    $options[:preacher] = nil
    opts.on( '-p', '--preacher PREACHER', 'Der Prediger' ) do |x|
        $options[:preacher] = x
    end
    
    opts.on( '-c', '--cat FILETYPE', 'Kategorie' ) do |x|
        $options[:cat] = x
    end
    
    $options[:lang] = "*"
    opts.on( '-l', '--lang FILETYPE', 'Sprache' ) do |x|
        $options[:lang] = x
    end
    
    $options[:ref] = nil
    opts.on( '-r', '--ref PATH', 'Bibelstelle' ) do |x|
        $options[:ref] = x
    end
    
    $options[:date] = nil
    opts.on( '-d', '--date DATUM', 'Aufnahmedatum' ) do |x|
        $options[:date] = x
    end


    $options[:serie] = nil
    opts.on( '-s', '--serie PATH', 'Alias der Serie' ) do |x|
        $options[:serie] = x
    end

    opts.on( '-k', '--key PATH', 'Path to your keyfile.' ) do |x|
        $options[:key] = x
    end

    # This displays the help screen, all programs are
    # assumed to have this option.
        opts.on( '-h', '--help', 'Display this screen' ) do
            puts opts
            exit
        end
    end.parse! 
end