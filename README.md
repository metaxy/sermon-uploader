sermon-uploader
===============
needs ruby >= 1.9

##install
sudo zypper in libtag-devel ruby-devel
sudo gem install json net-scp taglib-ruby qtbindings russian rest-client

#test run#

touch test.mp3 && ruby cmd.rb --title="asd" --preacher="Paul Walger" --date="1-2-2013" --cat="hellersdorf-predigt" --file test.mp3 --user="git_lightplanke"

[![Code Climate](https://codeclimate.com/github/metaxy/sermon-uploader.png)](https://codeclimate.com/github/metaxy/sermon-uploader)
