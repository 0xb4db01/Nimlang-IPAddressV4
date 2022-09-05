# IPAddress V4 Nim module

Author: 0xb4db01
Date  : 02/09/2022

Simple IPv4 address module for calculating subnets, masks, network addresses, broadcast addresses, ...

Inspired somehow by Python's IPAddress module, I did what I could, it's my first code in Nim.

Obviously some IP related stuff is missing, like some IANA things, let alone go IPv6 support, but mainly this is what I needed at the moment. Maybe one day I'll add more stuff and possibly code it better ;)

## Usage

Import ipaddress/ipaddress_v4 in your Nim code, that alone will give you access to all objects, methods and utility functions. Do not import directly what's in the v4 directory.

A "test.nim" file should come with this module, with most of its usage.

I did some tests and checks with other calculators, hopefully all output is correct.

AFAIK at the moment overloading assignment is not supported, to create IPAddressV4 and IPNetworkV4 instances do

```
var myIP = newIPAddressV4()("127.0.0.1")

var myNet = newIPNetworkV4(myIP, 24)
```

Both will validate input: IP address in IPAddressV4 and CIDR in IPNetworkV4. Use try/except and catch ValueError.

For all featured methods and utilities run test, read the output and also check test.nim source code.

Compile test.nim with the command: nim c test.nim
