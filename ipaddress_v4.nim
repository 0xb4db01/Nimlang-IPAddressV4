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
proc init*(self: IPAddressV4, ip: string): IPAddressV4 =
    self.ip = ip

    if self.isValid():
        return self
    else:
        raise newException(ValueError, "Invalid IP address")

type
    IPNetworkV4* = object
        ip*: IPAddressV4
        cidr*: int

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

    return IPAddressV4().init(strip(retval, chars = {'.'}))

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

    return IPAddressV4().init(join(tmp, "."))

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
# IPNetworkV4 public methods
##

##
# Calculates netmask from w.x.y.z/cidr
#
proc mask*(self: IPNetworkV4): string =
    var x = self.cidr
    var retval = [0, 0, 0, 0]

    for i in 0..3:
        # The concept here is that we want to shift right a certain amount of
        # 1's for each octet, but only if they are less than 8 because in
        # that case the octet will be 255 (1111111).
        # To do so, we assing a temporary variable x = CIDR and decrement it
        # by CIDR - ((position + 1) * 8) for each octet we visit.
        # So, for example, if CIDR is 27, things will be like
        # 11111111.11111111.11111111.11100000
        # So we'll assign 255 to the first octet, then it will decrement to 19
        # so again we assign 255 to the second octet, then it will decrement
        # to 11 so, again, you know the drill and finally it will decrement to
        # 3, which will be calculated as 11100000 (224) in the next for loop
        # at the else block
        #
        if x >= 8:
            retval[i] = 255
        else:
            var octet = 0

            # Here we are calculating the value of the octet because
            # decremented CIDR is < 8. The countdown stops at
            # (7 - (CIDR - (i * 8))) + 1
            # If we consider the example above, we are at position 3 where 
            # decremented CIDR (x) < 8, so our for loop will countdown 
            # from 7 up and stop at 5 because (7 - (27 - (3 * 8)) + 1) = 5
            #
            for j in countdown(7, (7 - (self.cidr - (i * 8))) + 1):
                octet += (1 shl j)

            retval[i] = octet

        x = self.cidr - ((i + 1) * 8)

    return join(retval, ".")

##
# Total hosts for a given IP network (with network and broadcast)
#
proc totalHosts*(self: IPNetworkV4): int64 =
    return int(pow(2.0, float(32 - self.cidr)))

##
# Total assignable IP v4 addresses for a given IP network
#
proc usableHosts*(self: IPNetworkV4): int64 =
    let tmp = self.totalHosts() - 2

    return if tmp >= 2: tmp else: 0

##
# Get network address
#
proc networkAddress*(self: IPNetworkV4): IPAddressV4 =
    let ipdec = self.ip.toDec()
    let tmp = IPAddressV4(ip: self.mask())
    let subnetdec: int64 = tmp.toDec()

    return int64ToIP(ipdec and subnetdec)

##
# Get broadcast address
#
proc broadcastAddress*(self: IPNetworkV4): IPAddressV4 =
    return int64ToIP(self.networkAddress().toDec() + self.usableHosts())

##
# Starts from network address and adds 1 till reaches last IP before the
# broadcast address.
# One must consider that for small CIDRs (such as /8) this will last ages...
#
iterator hosts*(self: IPNetworkV4): IPAddressV4 =
    var currentIP = self.networkAddress().toDec()

    for i in 0..self.usableHosts():
        if currentIP < self.broadcastAddress.toDec():
            inc(currentIP)

            yield int64ToIP(currentIP)
        else:
            break

##
# IPAddressV4 overloaded operators
##

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
# Is IP in network
#
proc `in`*(self: IPAddressV4, network: IPNetworkV4): bool =
    let netdec = IPAddressV4(ip: network.networkAddress().ip).toDec()
    let broadcastdec = IPAddressV4(ip: network.broadcastAddress().ip).toDec()
    let ipdec = self.toDec()

    if netdec < ipdec and ipdec < broadcastdec:
        return true

    return false

##
# Is equal to other IPAddressV4 object
#
proc `==`*(self: IPAddressV4, ipobj: IPAddressV4): bool =
    return if self.ip == ipobj.ip: true else: false

##
# IANA definitions
##

let privateNetworks = [
            IPNetworkV4(ip: IPAddressV4(ip: "10.0.0.0"), cidr: 8),
            IPNetworkV4(ip: IPAddressV4(ip: "172.16.0.0"), cidr: 12),
            IPNetworkV4(ip: IPAddressV4(ip: "192.168.0.0"), cidr: 16),
        ]
let reservedNetwork = IPNetworkV4(ip: IPAddressV4(ip: "240.0.0.0"), cidr: 4)
let linkLocal = IPNetworkV4(ip: IPAddressV4(ip: "169.254.0.0"), cidr: 16)
let loopback = IPNetworkV4(ip: IPAddressV4(ip: "127.0.0.0"), cidr: 8)

##
# IPAddressV4 methods that need overloaded operators
#
proc isPrivate*(self: IPAddressV4): bool =
    for i in privateNetworks:
        if self in i:
            return true

    return false

proc isReserved*(self: IPAddressV4): bool =
    return if self in reservedNetwork: true else: false

proc isLinkLocal*(self: IPAddressV4): bool =
    return if self in linkLocal: true else: false

proc isLoopback*(self: IPAddressV4): bool =
    return if self in loopback: true else: false
