# encoding: utf-8
require 'optparse'
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
$options[:api] = "http://media.ecg-berlin.de/api/get.php?"
$options[:home] = "/var/www/vhosts/ecg-berlin.de/media/"
$options[:username] = "technik_upload"
$options[:host] = "5.9.58.75"
$options[:addfileDesc] = "Notizen"

def getOptions()
    optparse = OptionParser.new do|opts|
    opts.banner = "Usage: main.rb [options]"
    
    $options[:files] = Array.new
    opts.on( '-f', '--file FILENAMES', 'Which files to upload' ) do |file|
        $options[:files] << File.expand_path(file)
    end
    $options[:title] = ""
    opts.on( '-t', '--title TITLE', 'Title' ) do |x|
        $options[:title] = x
    end
    $options[:preacher] = ""
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
    

    $options[:ref] = ""
    opts.on( '-r', '--ref PATH', 'Bibelstelle' ) do |x|
        $options[:ref] = x
    end
    
    $options[:date] = ""
    opts.on( '-d', '--date DATUM', 'Aufnahmedatum' ) do |x|
        $options[:date] = x
    end


    $options[:serie] = ""
    opts.on( '-s', '--serie PATH', 'Alias der Serie' ) do |x|
        $options[:serie] = x
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

    # This displays the help screen, all programs are
    # assumed to have this option.
        opts.on( '-h', '--help', 'Display this screen' ) do
            puts opts
            exit
        end
    end.parse! 
end

def error_check(options)
    neededOptions = [:title, :preacher, :date, :cat, :files, :host, :username, :api, :home]
    
    neededOptions.each do |x|
        if(options[x] == nil) 
            puts "Die Variable #{x} fehlt" 
            return :failed
        end
    end
    options[:files].each do |x|
        if(!File.exists?(x)) 
            puts "Die Datei #{x} existiert nicht" 
            return :failed
        end
    end
    return :ok
end
