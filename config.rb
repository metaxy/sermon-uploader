# encoding: utf-8
require 'optparse'
require 'logger'
require_relative 'strings'
require 'yaml'

$logger = Logger.new('logfile.log')

$options = {}
$options[:key] = "~/.ssh/id_rsa"
$options[:home] = "/var/www/vhosts/ecg-berlin.de/httpdocs/"
$options[:binhome] = "/var/www/vhosts/ecg-berlin.de/bin/"
$options[:filesHome] = $options[:home]
$options[:visible_path] = $options[:filesHome]

$options[:locale] = "de"
$options[:tmp] = $options[:filesHome] +"tmp/"

$options[:username] = ""
$options[:host] = ""

$options[:autoVideo] = true
$options[:fft_resolution] = 1024
$options[:fft_path] = $options[:binhome] +"findPartWav/findPartWav"
$options[:vaudio_codec] = "libvo_aacenc"
$options[:vaudio_resolution] = "64k"
$deleteFolders = []

def cleanOptions()
    $options[:files] = Array.new
    $options[:title] = ""
    $options[:preacher] = ""
    $options[:lang] = ["de","ru"]
    $options[:ref] = ""
    $options[:date] = ""
    $options[:serie] = ""
end

def getOptions()
    optparse = OptionParser.new do|opts|
    opts.banner = "Usage: main.rb [options]"
    cleanOptions();
   
    opts.on( '-u', '--user NAME', 'Username for m8' ) do |x|
        $options[:user] = x
        config = YAML.load_file "#{File.dirname(__FILE__)}/#{x}.yml"
        $options.merge! config
        $options[:newHome] = $options[:filesHome] + "downloads/new/#{x}/"
        $options[:backup_path] = $options[:filesHome] + "downloads/bu/#{x}/"
    end
    
    opts.on( '-f', '--file FILENAMES', 'Which files to upload' ) do |file|
        $options[:files] << File.expand_path(file)
    end

    opts.on( '-t', '--title TITLE', 'Title' ) do |x|
        $options[:title] = x
    end

    opts.on( '-s', '--speaker PREACHER', 'Der Prediger' ) do |x|
        $options[:speaker] = x
    end
    
    opts.on( '-g', '--group_name NAME', 'Name der Gruppe' ) do |x|
        $options[:group_name] = x
    end
    
    opts.on( '-l', '--lang NAME', 'Sprache' ) do |x|
        $options[:lang] = x
    end
    

    opts.on( '-r', '--ref SCRIPTURE', 'Bibelstelle' ) do |x|
        $options[:ref] = x
    end
    
    opts.on( '-d', '--date DATUM', 'Aufnahmedatum' ) do |x|
        $options[:date] = x
    end


    opts.on( '-s', '--series NAME', 'Name der Serie' ) do |x|
        $options[:series] = x
    end
    
    opts.on( '-a', '--api PATH', 'Path zur API' ) {|x| $options[:api] = x}
  
    
    opts.on('--home PATH', 'Homepath on the server' ) do |x|
        $options[:home] = x
    end
    
    opts.on('--username NAME', 'Username' ) do |x|
        $options[:username] = x
    end
    
    
    opts.on( '-o', '--host NAME', 'Hostname' ) do |x|
        $options[:host] = x
    end

    opts.on( '-k', '--key PATH', 'Path to your keyfile.' ) do |x|
        $options[:key] = x
    end
    opts.on( '-v', '--autoVideo', 'Add automatically the video file' ) do |x|
        $options[:autoVideo] = true
    end
    # This displays the help screen, all programs are
    # assumed to have this option.
        opts.on( '-h', '--help', 'Display this screen' ) do
            puts opts
            exit
        end
    end.parse! 
end

def error_check(hash, neededOptions)
    neededOptions.each do |x|
        if(hash[x] == nil) 
            puts "Die Variable #{x} fehlt in der Configuration"
            return :failed
        end
    end
    return :ok
end

def error_check_options(hash)
    error_check(hash, [:host, :username, :api, :home])
end

def error_check_file(hash)
    return :failed if error_check(hash, [:title, :speaker, :date, :group_name, :files]) == :failed
    
     hash[:files].each do |x|
        if(not File.exists?(x)) 
            puts "Die Datei #{x} existiert nicht" 
            return :failed
        end
    end
    return :ok
end

