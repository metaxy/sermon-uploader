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
$options[:api] = "http://media.ecg-berlin.de/components/com_sermonspeaker/api/get.php?"
$options[:home] = "/var/www/vhosts/ecg-berlin.de/media/"
$options[:username] = "git_lightplanke"
$options[:host] = "5.9.58.75"