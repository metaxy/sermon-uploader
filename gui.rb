require './main.rb'
require 'Qt4'

class MainWindow < Qt::MainWindow
    
        @@title = nil
        @@preacher = nil
        @@cat = nil
        @@ref = nil
        @@date = nil
        @qserie = nil
        
    def initialize
        super
        self.window_title = 'Hello QtRuby v1.0'
        resize(600, 300)
        cw = Qt::Widget.new self
        self.central_widget = cw

        button = Qt::PushButton.new('Upload') do
        connect(SIGNAL :clicked) { read; do_stuff }
        end
        
        @@title = Qt::LineEdit.new
        @@preacher = Qt::LineEdit.new
        @@cat = Qt::ComboBox.new
        @@cat.addItems($catNames.keys)
        @@ref = Qt::LineEdit.new
        @@date = Qt::DateTimeEdit.new Qt::Date.currentDate()
        @@serie = Qt::LineEdit.new
            
        
        cw.layout = Qt::FormLayout.new do
            layout.addRow(tr("Titel"),  @@title);
            layout.addRow(tr("Prediger"),  @@preacher);
            layout.addRow(tr("Kategorie"),  @@cat);
            layout.addRow(tr("Bibelstelle"),  @@ref);
            layout.addRow(tr("Datum"),  @@date);
            layout.addRow(tr("Serie"),  @@serie);
            layout.addRow(tr("Upload"),  button);
        end
    
  end
      
end
def do_stuff
     # some error checking
    return if error_check() == :failed
    
    names = do_meta()
    upload(names)
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