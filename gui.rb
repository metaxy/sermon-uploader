# encoding: utf-8
require 'Qt4'
require 'net/http'
require 'date'
require 'rubygems'


require_relative 'config'
require_relative 'metadata'
require_relative 'upload'
require_relative 'api'
require_relative 'parts/ssh'

class MainWindow < Qt::MainWindow
    slots :upload
    def initialize
        super
        self.window_title = 'Sermon Uploader'
        resize(600, 300)
       
        @@w = self

        createWidgets()
        completer()
        @@button = Qt::PushButton.new('Upload')
        
        Qt::Object.connect(@@button, SIGNAL('clicked()'), self, SLOT('upload()'))

        createLayout()
    end
    def upload()
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
                ret = do_stuff(@@w)
                @@w.msgBox(ret)
    end
    def createLayout()
        cw = Qt::Widget.new self
        self.central_widget = cw
        cw.layout = Qt::FormLayout.new do
            layout.addRow(tr("Titel"),  @@title);
            layout.addRow(tr("Prediger"),  @@preacher);
            layout.addRow(tr("Kategorie"),  @@cat);
            layout.addRow(tr("Bibelstelle"),  @@ref);
            layout.addRow(tr("Datum"),  @@date);
            layout.addRow(tr("Serie"),  @@serie);
            layout.addRow(tr("Audio"),  @@w.fileWidget(cw, @@audioFile));
            layout.addRow(tr("Video"),  @@w.fileWidget(cw, @@videoFile));
            layout.addRow(tr("Extra"),  @@w.fileWidget(cw, @@extraFile));
            layout.addRow(tr("Upload"),  @@button);
            layout.addRow(tr("Progress"), @@progress)
        end
    end
    def createWidgets()
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
        @@progress = Qt::ProgressBar.new
    end
    
    def completer()
        completer_p = Qt::Completer.new($api.getSpeakers(), self)
        completer_p.setCaseSensitivity(Qt::CaseInsensitive)
        @@preacher.setCompleter(completer_p)
        
        
        completer_r = Qt::Completer.new($api.getBookNames(), self)
        completer_r.setCaseSensitivity(Qt::CaseInsensitive)
        @@ref.setCompleter(completer_r)
        
        completer_s = Qt::Completer.new($api.getSeries(), self)
        completer_s.setCaseSensitivity(Qt::CaseInsensitive)
        completer_s.setCompletionMode(Qt::Completer::UnfilteredPopupCompletion)
        @@serie.setCompleter(completer_s) 
    end
    def update(name,sent,total)
        @@progress.setMaximum(total)
        @@progress.setValue(sent)
    end
    
    def msgBox(ret)
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
    end
    
    def fileWidget(parent, widget)
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
  
end



class GuiBar 
    def update(name, sent, total)
        $w.update(send.to_i, total.to_i)
        print "\r#{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
    end
end

def do_stuff(progressHandler)
    # some error checking
    return if error_check($options) == :failed
    names = do_meta()
    u = Upload.new($api)
    u.up(names)

end

def main
    getOptions()
    $api = Api.new(SshPipe.new(GuiBar.new))
    a = Qt::Application.new(ARGV)
    $w = MainWindow.new
    $w.show
    a.exec
end

# run programm
main() 
