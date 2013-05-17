# encoding: utf-8
require 'Qt4'
require 'net/http'
require 'date'
require 'rubygems'


require './config.rb'
require './metadata.rb'
require './register.rb'
require './upload.rb'



class MainWindow < Qt::MainWindow
    def initialize
        super
        self.window_title = 'Sermon Uploader'
        resize(600, 300)
        cw = Qt::Widget.new self
        self.central_widget = cw
        @@asd = self

        @@title = Qt::LineEdit.new
        @@preacher = Qt::LineEdit.new
        completer_p = Qt::Completer.new(getSpeakers, self)
        completer_p.setCaseSensitivity(Qt::CaseInsensitive)
        @@preacher.setCompleter(completer_p)
        
        @@cat = Qt::ComboBox.new
        @@cat.addItems($catNames.keys)
        @@ref = Qt::LineEdit.new
        completer_r = Qt::Completer.new(getBookNames, self)
        completer_r.setCaseSensitivity(Qt::CaseInsensitive)
        @@ref.setCompleter(completer_r)
        @@date = Qt::DateTimeEdit.new Qt::Date.currentDate()
        @@serie = Qt::LineEdit.new

        completer_s = Qt::Completer.new(getSeries, self)
        completer_s.setCaseSensitivity(Qt::CaseInsensitive)
        completer_s.setCompletionMode(Qt::Completer::UnfilteredPopupCompletion)
        
        @@serie.setCompleter(completer_s)
        
        @@audioFile = Qt::LineEdit.new
        @@videoFile = Qt::LineEdit.new
        @@extraFile = Qt::LineEdit.new
        
        @@progress = Qt::ProgressBar.new
        

        button = Qt::PushButton.new('Upload') do
            connect(SIGNAL :clicked) { 
                $options[:title] = @@title.text
                $options[:preacher] = @@preacher.text
                $options[:cat] = @@cat.currentText
                $options[:ref] = @@ref.text
                $options[:date] = @@date.date.toString(Qt::ISODate)
                $options[:serie] = @@serie.text
                $options[:files]  = []
                ($options[:files] << @@audioFile.text) if @@audioFile.text != ""
                ($options[:files] << @@videoFile.text) if @@videoFile.text != ""
                ($options[:files] << @@extraFile.text) if @@extraFile.text != ""
                ret = do_stuff(@@asd)
                if ret != nil
                    msgBox = Qt::MessageBox.new;
                    msgBox.setText("Upload erfolgreich");
                    msgBox.exec();
                    $w.close()
                else
                    msgBox = Qt::MessageBox.new;
                    msgBox.setText("Upload fehlgeschlagen");
                    msgBox.exec();
                end
            }
        end
        
        cw.layout = Qt::FormLayout.new do
            layout.addRow(tr("Titel"),  @@title);
            layout.addRow(tr("Prediger"),  @@preacher);
            layout.addRow(tr("Kategorie"),  @@cat);
            layout.addRow(tr("Bibelstelle"),  @@ref);
            layout.addRow(tr("Datum"),  @@date);
            layout.addRow(tr("Serie"),  @@serie);
            layout.addRow(tr("Audio"),  f(cw, @@audioFile));
            layout.addRow(tr("Video"),  f(cw, @@videoFile));
            layout.addRow(tr("Extra"),  f(cw, @@extraFile));
            layout.addRow(tr("Upload"),  button);
            layout.addRow(tr("Progress"), @@progress)
        end
    end
    
    def update(name,sent,total)
        @@progress.setMaximum(total)
        @@progress.setValue(sent)
    end
end

def getSpeakers()
    res = Net::HTTP.get URI($options[:api] + "action=list_speakers")
    json = JSON.parse(res)
    json.map { |x| x[1]}
    
end

def getSeries()
    res = Net::HTTP.get URI($options[:api] + "action=list_series")
    json = JSON.parse(res)
    puts json
    json.map { |x| x[2]}
end

def f(parent, widget)
        w = Qt::Widget.new parent
        button = Qt::PushButton.new('Select') do
            connect(SIGNAL :clicked) { widget.text = Qt::FileDialog.getOpenFileName(parent, tr("Open file"), "", "*.*") }
        end
        w.layout = Qt::HBoxLayout.new do
            layout.addWidget(widget);
            layout.addWidget(button);
        end
        w.layout.setContentsMargins(0, 0, 0, 0)
        return w
end
  
def do_stuff(progressHandler)
    # some error checking
    return if error_check($options) == :failed
    names = do_meta()
    up(names, progressHandler)
end
class Gui
    def main
        getOptions()
        a = Qt::Application.new(ARGV)
        $w = MainWindow.new
        $w.show
        a.exec
    end
end
# run programm
Gui.main() 
