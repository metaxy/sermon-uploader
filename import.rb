 #encoding: utf-8
require 'csv'
require 'ftools'

$csvFile = "./jos_predigtenFile.csv";
$folder = "/home/ecg-media/downloads/todo/";
$newpath = "/home/ecg-media/downloads/import/";
$id = 0;
$prediger = 2;
$title = 3;
$path = 4;
$date = 5;



def main()
    out = ""
    CSV.foreach($csvFile) do |row|
        next if row[$id].to_i < 600 or row[$id].to_i >= 700
        puts "id : #{row[$id]}"
        puts "prediger : #{row[$prediger]}"
        puts "title : #{row[$title]}"
        puts "path : #{row[$path]}"
        puts "date : #{row[$date]}"
        row[$title] = "#{row[$date]} von #{row[$prediger]}" if row[$title] == "" or row[$title] == nil
        folder = "#{$newpath}#{row[$title]}/"
        row[$path] = File.basename(row[$path])
        puts "new row path #{row[$path]}"
        if not File.exists? "#{$folder}#{row[$path]}"
            puts "File not found: #{$folder}#{row[$path]} title:  #{row[$title]}\n"
            out += "File not found: #{row[$path]} title:  #{row[$title]}\n"
            next
        end
        Dir.mkdir(folder)
        row[$prediger] = "Alexander Arzer" if row[$prediger] == "Alex Arzer"
        row[$prediger] = "Wilhelm Walger" if row[$prediger] == "Willi Walger"
        row[$prediger] = "Wadim Ruff" if row[$prediger] == "Wadim Ruf"
   
        File.copy("#{$folder}#{row[$path]}", "#{folder}#{row[$date]} =  = #{row[$prediger]}.mp3")
    end
    File.open("not_found.log", 'a+') {|f| f.write(out) }
end

main();
