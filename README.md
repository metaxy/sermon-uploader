sermon-uploader
===============
needs ruby >= 1.9

##install
sudo zypper in libtag-devel ruby-devel
usdo gem install json net-scp taglib-ruby qtbindings russian rest-client

#test run#

touch test.mp3 && ruby cmd.rb --title="asd" --speaker="Paul Walger" --date="1-2-2013" --group="hellersdorf-predigt" --file test.mp3 --user="git_lightplanke"
