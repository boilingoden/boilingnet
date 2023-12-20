# BoilingNet
check disconnections and interrupts using `cURL` (>= 7.70.0) and `dig`

## Usage:
`bash [bash file name] -u [URI of the target] [optional -a at the end for any cURL arguments]`
```sh
bash netector.bash -u https://www.gmail.com/generate_204
```
```sh
bash netector.bash -u https://self-signed.example.com/robots.txt -a -k
```

* `-u` or `--url` to set a new URI instead of default one (https://gmail.com/generate_204)
* `-a` or `--argument` to set arguments for CURL commands. (e.g. `-I`) **NOTE**: this command must be used at the end.
* `-m` or `--mute` to mute the alarms from the start. (you can unmute it anytime in run time by pressing `m` key)
* `-g` or `--no-graph` to start with no graph. (you can see the graph anytime by pressing the `g` key at run time.
* `-h` or `--help` to see the usage.


#### NOTE: all arguments after `-a` will be considered for `curl` command. therefore you **MUST** use it at the _end_

## Requirements

### Debian-based distributions:
```sh
sudo apt install dnsutils curl jq -y
```

### Red-Hat-based distributions:
```sh
sudo dnf install dnsutils curl jq -y
```

### macOS:
```sh
brew install jq
```
Note: usually macOS has the latest version of cURL and `dig`. if not, try:
```sh
brew install bind curl jq
```

![boiling net demo](https://raw.githubusercontent.com/boilingoden/boilingnet/main/demo.png)

#### charts bars: Total time* , DNS query time , TCP Handshake time , TLS handshake time
[*] Total time = (`curl`'s `time_total` - `curl`'s `time_namelookup`) + `dig`'s `Query time` to domain's NS server

#### in the chart above:
- first bar = `-1` :  DNS is working - TCP handshake is working very fast (because we have TLS handshake) - TLS handshake is working - but after that, there is timeout
- second bar = `-2` : DNS is not working - TCP handshake is working very late - TLS handshake is working very late - there is timeout after that. (HTTP exchange)
- third bar = `-1` : We now have the Total time's bar - DNS is not working - TCP handshake is working - TLS handshake is working - there is no timeout after that, because we have the Total time's bar
- forth bar = `1046` : which means we had successful connection in both `dig` and `curl`. the +0 values like `1046` means Total time
