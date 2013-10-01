 #encoding: utf-8
require 'csv'
require 'ftools'

$csvFile = "./jos_predigtenFile.csv";
$folder = "/var/www/vhosts/ecg-berlin.de/httpdocs/fileadmin/files/hellersdorf/predigten/";
$newpath = "/home/ecg-media/import/";
$id = 0;
$prediger = 2;
$title = 3;
$path = 4;
$date = 5;



def main()
    CSV.foreach($csvFile) do |row|
        next if row[$id].to_i < 750
        puts "id : #{row[$id]}"
        puts "prediger : #{row[$prediger]}"
        puts "title : #{row[$title]}"
        puts "path : #{row[$path]}"
        puts "date : #{row[$date]}"
        folder = "#{$newpath}#{row[$title]}/"
        Dir.mkdir(folder)
        row[$prediger] = "Alexander Arzer" if row[$prediger] == "Alex Arzer"
        row[$prediger] = "Wilhelm Walger" if row[$prediger] == "Willi Walger"
        row[$prediger] = "Wadim Ruff" if row[$prediger] == "Wadim Ruf"

        File.copy("#{$folder}#{row[$path]}", "#{folder}#{row[$date]} =  = #{row[$prediger]}.mp3")
    end
end

main();