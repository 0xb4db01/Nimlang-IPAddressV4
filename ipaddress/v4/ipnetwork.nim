##
# IPNetwork definitions for Nim IP Address V4 module, don't import this, 
# import ipaddress_v4 module in the previous directory instead
#
# Author: 0xb4dbo1
#

import ipaddress
import std/strutils
import math

type
    IPNetworkV4* = object
        ip: IPAddressV4
        cidr: int

proc newIPNetworkV4*(ip: IPAddressV4, cidr: int): IPNetworkV4 =
    if cidr > 32 or cidr < 0:
        raise newException(ValueError, "Invalid CIDR")

    var newObj: IPNetworkV4 = IPNetworkV4(ip: ip, cidr: cidr)

    return newObj

##
# IPNetworkV4 public methods
##

proc getCidr*(self: IPNetworkV4): int =
    return self.cidr

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
    let tmp = newIPAddressV4(self.mask())
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

