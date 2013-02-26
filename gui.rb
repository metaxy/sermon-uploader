require './main.rb'
require 'Qt4'

class MainWindow < Qt::MainWindow
    
        @@title = nil
        @@preacher = nil
        @@cat = nil
        @@ref = nil
        @@date = nil
        @serie = nil
        
        @@audioFile = nil
        @@videoFile = nil
        @@extraFile = nil
        
    def initialize
        super
        self.window_title = 'Hello QtRuby v1.0'
        resize(600, 300)
        cw = Qt::Widget.new self
        self.central_widget = cw

        button = Qt::PushButton.new('Upload') do
            connect(SIGNAL :clicked) { 
                $options[:title] = @@title.text
                $options[:preacher] = @@preacher.text
                $options[:cat] = @@cat.currentText
                $options[:ref] = @@ref.text
                $options[:date] = @@date.date.toString(Qt::ISODate)
                $options[:serie] = @@serie.text
                ($options[:files] << @@audioFile.text) if @@audioFile.text != nil && @@audioFile.text != ""
                ($options[:files] << @@videoFile.text) if @@videoFile.text != nil && @@videoFile.text != ""
                ($options[:files] << @@extraFile.text) if @@extraFile.text != nil && @@extraFile.text != ""
                do_stuff
            
            }
        end
        
        @@title = Qt::LineEdit.new
        @@preacher = Qt::LineEdit.new
        @@cat = Qt::ComboBox.new
        @@cat.addItems($catNames.keys)
        @@ref = Qt::LineEdit.new
        @@date = Qt::DateTimeEdit.new Qt::Date.currentDate()
        @@serie = Qt::LineEdit.new
        
        @@audioFile = Qt::LineEdit.new
        @@videoFile = Qt::LineEdit.new
        @@extraFile = Qt::LineEdit.new

        cw.layout = Qt::FormLayout.new do
            layout.addRow(tr("Titel"),  @@title);
            layout.addRow(tr("Prediger"),  @@preacher);
            layout.addRow(tr("Kategorie"),  @@cat);
            layout.addRow(tr("Bibelstelle"),  @@ref);
            layout.addRow(tr("Datum"),  @@date);
            layout.addRow(tr("Serie"),  @@serie);
            layout.addRow(tr("Audio"),  f(cw,@@audioFile));
            layout.addRow(tr("Video"),  f(cw,@@videoFile));
            layout.addRow(tr("Extra"),  f(cw,@@extraFile));
            layout.addRow(tr("Upload"),  button);
        end
    end
    
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
        return w
end
  
def do_stuff
     # some error checking
    return if error_check() == :failed
    
    names = do_meta()
    up(names)
end
def main

    cmd()
    a = Qt::Application.new(ARGV)
    w = MainWindow.new
    w.show
    a.exec
    
end
# run programm
main() 