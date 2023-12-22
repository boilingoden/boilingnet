# BoilingNet
check disconnections and interrupts using `cURL` (>= 7.70.0) and `dig`

see the [methodology](#methodology) section to see what we actually do.

**Note**: we send requests with a [unique User-Agent](https://github.com/boilingoden/boilingnet/blob/21a025446d425141734f361a4fefb1705779f4d2/netector.bash#L370), if the server doesn't welcome our requests ([indicated by HTTP Code **420** or **429**](https://github.com/boilingoden/boilingnet/blob/21a025446d425141734f361a4fefb1705779f4d2/netector.bash#L436)), the script will automatically exit.

### Table of Content
- [Usage](#usage)
- [Hotkeys](#hotkeys)
- [Requirements](#requirements)
  - [Debian-based distributions](#debian-based-distributions)
  - [Red-Hat-based distributions](#red-hat-based-distributions)
  - [macOS](#macos)
- [Demo](#demo)
- [Methodology](#methodology)

## Usage:
`bash [bash file name] -u [URI of the target] [optional -a at the end for any cURL arguments]`
```sh
bash netector.bash -u https://www.gmail.com/generate_204
```
```sh
bash netector.bash -u https://self-signed.example.com/robots.txt -a -k
```

* `-u` or `--url` to set a new URI instead of default one (i.e. `https://gmail.com/generate_204`)
* `-a` or `--argument` to set arguments for CURL commands. (e.g. `-I`) **NOTE**: this command must be used at the end.
* `-m` or `--mute` to mute the alarms from the start. (you can unmute it anytime in run time by pressing `m` key)
* `-g` or `--no-graph` to start with no graph. (you can see the graph anytime by pressing the `g` key at run time.
* `-r` or `--resolver` to change the default public resolver (i.e. 8.8.8.8)
* `-s` or `--sleep` to wait more between each requests to avoid being rate limited or blocked
* `-t` or `--timeout` to change the default timeout in dig and curl commands (i.e. 2 seconds)
* `-h` or `--help` to see the usage.


#### NOTE: all arguments after `-a` will be considered for `curl` command. therefore you **MUST** use it at the _end_

### Hotkeys

* press `m` or `M` to mute/unmute
* press `g` or `G` to show or hide the graph
* press `q` or `Q` to exit


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
## Demo
![BoilingNet Demo](https://raw.githubusercontent.com/boilingoden/boilingnet/main/demo.png)

#### charts bars: Total time* , DNS query time , TCP Handshake time , TLS handshake time
[*] Total time = (`curl`'s `time_total` - `curl`'s `time_namelookup`) + `dig`'s `Query time` to domain's NS server

#### in the chart above:
- first bar = `-1` :  DNS is working - TCP handshake is working very fast (less to show in graph --> fixed now) - TLS handshake is working - but after that, there is timeout
- second bar = `-2` : DNS is not working - TCP handshake is working very late - TLS handshake is working very late - there is timeout after that. (HTTP exchange)
- third bar = `-1` : We now have the Total time's bar - DNS is not working - TCP handshake is working - TLS handshake is working - there is no timeout after that, because we have the Total time's bar
- forth bar = `1046` : which means we had successful connection in both `dig` and `curl`. the +0 values like `1046` means Total time

## Methodology

using `dig` command 1) we will fetch the NS of the domain using our default public resolver (i.e. 8.8.8.8) then 2) request the hostname directly to the NS server to check if the NS is working properly. finaly, using `curl` command, 3) we will request the URI. All as follows:

example URI: `https://cp.cloudflare.com/generate_204`

1.
```sh
$ dig +timeout=1 +retry=0 cloudflare.com @8.8.8.8 NS +short
ns3.cloudflare.com.
[SNIP]
```

2.
```sh
$ dig +timeout=1 +retry=0 cp.cloudflare.com @ns3.cloudflare.com.
[SNIP]
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 40853
[SNIP]
;; Query time: 308 msec
[SNIP]
```

3.
```sh
$ curl -o /dev/null -4 -m2 -sw "%{json}\n" https://cp.cloudflare.com/generate_204
{[SNIP],"http_code":204,[SNIP],"time_appconnect":0.560336,"time_connect":0.355649,"time_namelookup":0.163739,"time_pretransfer":0.560398,"time_redirect":0.000000,"time_starttransfer":0.966813,"time_total":0.966860,[SNIP]}
```
