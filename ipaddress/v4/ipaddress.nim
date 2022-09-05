##
# IPNetwork definitions for Nim IP Address V4 module, don't import this, 
# import ipaddress_v4 module in the previous directory instead
#
# Author: 0xb4dbo1
#

import strutils
import math

##
# Author: 0xb4db01
# Date  : 02/09/2022
#
# Description:
#
# Simple IPv4 address module for calculating subnets, masks, network addresses,
# broadcast addresses, ...
#
# Inspired somehow by Python's IPAddress module, I did what I could, it's my
# first code in Nim.
# Obviously some IP related stuff is missing, like some IANA things, let alone 
# go IPv6 support, but mainly this is what I needed at the moment. Maybe one 
# day I'll add more stuff and possibly code it better ;)
# 
# A "test.nim" file should come with this code, with most of this module's
# usage. I did some tests and checks with other calculators, hopefully all
# output is correct.
#
# Usage:
#
# AFAIK at the moment overloading assignment is not supported, so to create 
# IPAddressV4 and IPNetworkV4 instances do:
#
# var myIP = IPAddress().init("127.0.0.1")
# var myNet = IPNetworkV4(ip: myIP, cidr: 24)
#
# Use try/except and catch ValueError.
#
# For all featured methods and utilities run test, read the output and also 
# check test.nim source code.
#
# Compile test.nim with the command: nim c test.nim
#

type 
    IPAddressV4* = ref object
        ip: string

##
# Validate IP address
#
proc isValid*(self: IPAddressV4): bool =
    let octets = split(self.ip, ".")

    if len(octets) < 3:
        return false

    for i in octets:
        if parseInt(i) > 255:
            return false

        if parseInt(i) < 0:
            return false

    return true

##
# IPAddressV4 object initialization.
# Validates the IP address and raises ValueError if IP is not valid.
#
proc newIPAddressV4*(ip: string): IPAddressV4 =
    var newObj: IPAddressV4 = IPAddressV4(ip: ip)

    if newObj.isValid():
        return newObj
    else:
        raise newException(ValueError, "Invalid IP address")

##
# IP generic utility functions...
##

##
# Converts a 64bit integer to IP v4 address
#
proc int64ToIP*(ipdec: int64): IPAddressV4 =
    var tmpIPDec = ipdec
    var retval = ""

    for i in 0..3:
        var x = ""

        for j in 0..7:
            x = $(tmpIPDec mod 2) & x
            tmpIPDec = tmpIPDec shr 1

        retval = $(frombin[int](x)) & "." & retval

    return newIPAddressV4(strip(retval, chars = {'.'}))

##
# Converts from .in-addr.arpa address to IP v4 address
#
proc fromReversePTR*(inAddrArpa: string): IPAddressV4 =
    if inAddrArpa.find(".in-addr.arpa") < 7:
        raise newException(ValueError, "Invalid in-addr.arpa")

    var revIP = split(inAddrArpa, ".")[0..3]
    var tmp: seq[string] = @[]

    for i in countdown(revIP.high, 0):
        tmp.add(revIP[i])

    return newIPAddressV4(join(tmp, "."))

##
# IPAddressV4 public methods
##

##
# IP v4 address to .in-addr.arpa
#
proc reversePTR*(self: IPAddressV4): string =
    var tmp: seq[string] = @[]
    var s = split(self.ip, '.')

    for i in countdown(s.high, 0):
        tmp.add(s[i])

    return join(tmp, ".") & ".in-addr.arpa"

##
# IP v4 address to 64bit integer
#
proc toDec*(self: IPAddressV4): int64 =
    var octets = split(self.ip, ".")
    var retVal: int64

    var exponent = 3

    for i in 0..3:
        retval += parseInt(octets[i]) * int64(pow(256.0, float(exponent)))

        exponent -= 1

    return retval


##
# IPAddressV4 overloaded operators
##

{.experimental: "callOperator".}
proc `()`*(ip: string): IPAddressV4 =
    return newIPAddressV4(ip)

##
# IPv4 object to string
#
proc `$`*(self: IPAddressV4): string =
    return self.ip

## 
# Add integer to IPAddressV4
#
proc `+`*(self: IPAddressV4, x: int): IPAddressV4 =
    self.ip = int64ToIP(self.toDec() + x).ip

    return self

##
# Substract integer to IPAddressV4
#
proc `-`*(self: IPAddressV4, x: int): IPAddressV4 =
    self.ip = int64ToIP(self.toDec() - x).ip

    return self

##
# Is greater than other IPAddressV4 object
#
proc `>`*(self: IPAddressV4, ipobj: IPAddressV4): bool =
    return if self.toDec() > ipobj.toDec(): true else: false

##
# Is smaller than other IPAddressV4 object
#
proc `<`*(self: IPAddressV4, ipobj: IPAddressV4): bool =
    return if self.toDec() < ipobj.toDec(): true else: false

##
# Is equal to other IPAddressV4 object
#
proc `==`*(self: IPAddressV4, ipobj: IPAddressV4): bool =
    return if self.ip == ipobj.ip: true else: false

##
# From here on, we need IPNetworkV4...
# We also export all IPNetworkV4 methods so one can use them by
# just importing this module...
#

import ipnetwork
export IPNetworkV4

export newIPNetworkV4
export getCidr
export networkAddress
export mask
export totalHosts
export usableHosts
export broadcastAddress
export hosts

##
# Is IP in network
#
proc `in`*(self: IPAddressV4, network: IPNetworkV4): bool =
    let netdec = IPAddressV4(ip: network.networkAddress().ip).toDec()
    let broadcastdec = IPAddressV4(ip: network.broadcastAddress().ip).toDec()
    let ipdec = self.toDec()

    if netdec < ipdec and ipdec < broadcastdec:
        return true

    return false

import iana
export isPrivate
export isReserved
export isLinkLocal
export isLoopback
