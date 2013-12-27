# encoding: utf-8
require 'optparse'
require 'logger'
require_relative 'strings'

$logger = Logger.new('logfile.log')

$catNames = Hash[
        "hellersdorf-predigt" => "Predigt",
        "lichtenberg-predigt" => "Predigt",
        "wartenberg-predigt" => "Predigt",
        "spandau-predigt" => "Predigt",
        "hellersdorf-gemeindeseminar" => "Gemeindeseminar",
        "hellersdorf-jugend" => "Jugend",
        "lichtenberg-jugend" => "Jugend",
        "wartenberg-jugend" => "Jugend",
        "spandau-jugend" => "Jugend"]
$paths = Hash[
        "hellersdorf-predigt" => "downloads/hellersdorf/predigt",
        "Predigt" => "downloads/Test/predigt",
        "lichtenberg-predigt" => "downloads/lichtenberg/predigt",
        "wartenberg-predigt" => "downloads/wartenberg/predigt",
        "spandau-predigt" => "downloads/spandau/predigt",
        "hellersdorf-gemeindeseminar" => "downloads/hellersdorf/gemeindeseminar",
        "hellersdorf-jugend" => "downloads/hellersdorf/jugend",
        "lichtenberg-jugend" => "downloads/lichtenberg/jugend",
        "wartenberg-jugend" => "downloads/wartenberg/jugend",
        "spandau-jugend" => "downloads/spandau/jugend"]

$options = {}
$options[:key] = "~/.ssh/id_rsa"
$options[:api] = "http://localhost:3000/api/"
$options[:home] = "/var/www/vhosts/ecg-berlin.de/media/"
$options[:binhome] = "/var/www/vhosts/ecg-berlin.de/"
#$options[:filesHome] = "/home/ecg-media/"
$options[:filesHome] = "/home/paul/"
$options[:newHome] = $options[:filesHome] + "downloads/new/"
$options[:backup_path] = $options[:filesHome] + "downloads/bu/"
$options[:locale] = "de"
$options[:tmp] = $options[:filesHome] +"tmp/"

$options[:username] = "technik_upload"
$options[:host] = "5.9.58.75"
$options[:videoPath] = Hash["hellersdorf-predigt" => "/usr/local/WowzaMediaServer/content/live"]
#$options[:videoPath] = Hash[]

$options[:autoVideo] = true
$deleteFolders = []

def cleanOptions()
    $options[:files] = Array.new
    $options[:title] = ""
    $options[:preacher] = ""
    $options[:lang] = ["de","ru"]
    $options[:ref] = ""
    $options[:date] = ""
    $options[:serie] = ""
    $options[:autoVideo] = true
end

def getOptions()
    optparse = OptionParser.new do|opts|
    opts.banner = "Usage: main.rb [options]"
    cleanOptions();
 
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
    
    opts.on( '-u', '--username NAME', 'Username' ) do |x|
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

