# BoilingNet
check disconnections and interrupts using `cURL` (>= 7.70.0) and `dig`

## Usage:
`bash [bash file name]-u [URL for TCP+TLS+etc check] [optional -a at the end for any cURL arguments]`
```sh
bash netector.bash -u https://www.gmail.com/generate_204
```
```sh
bash netector.bash -u https://self-signed.example.com/robots.txt -a -k
```

## Requirements

Debian-based distributions:
```sh
sudo apt install dnsutils curl jq -y
```

Red-Hat-based distributions:
```sh
sudo dnf install dnsutils curl jq -y
```


#### NOTE: all arguments after `-a` will be considered for `curl` command. therefore you **MUST** use it at the _end_

![boiling net demo](https://raw.githubusercontent.com/boilingoden/boilingnet/main/demo.png)

#### charts bars: Total time* , DNS query time , TCP Handshake time , TLS handshake time
[*] Total time = (`curl`'s `time_total` - `curl`'s `time_namelookup`) + `dig`'s `Query time` to domain's NS server

#### in the chart above:
- first bar = `-1` :  DNS is working - TCP handshake is working very fast (because we have TLS handshake) - TLS handshake is working - but after that, there is timeout
- second bar = `-2` : DNS is not working - TCP handshake is working very late - TLS handshake is working very late - there is timeout after that. (HTTP exchange)
- third bar = `-1` : We now have the Total time's bar - DNS is not working - TCP handshake is working - TLS handshake is working - there is no timeout after that, because we have the Total time's bar
- forth bar = `1046` : which means we had successful connection in both `dig` and `curl`. the +0 values like `1046` means Total time
