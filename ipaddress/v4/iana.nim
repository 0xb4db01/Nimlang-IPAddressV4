##
# IANA definitions for Nim IP Address V4 module, don't import this, import
# import ipaddress_v4 module in the previous directory instead
#
# Author: 0xb4db01
#

import ipaddress

##
# IANA definitions
##

let privateNetworks = [
            newIPNetworkV4(newIPAddressV4("10.0.0.0"), 8),
            newIPNetworkV4(newIPAddressV4("172.16.0.0"), 12),
            newIPNetworkV4(newIPAddressV4("192.168.0.0"), 16)
        ]
let reservedNetwork = newIPNetworkV4(newIPAddressV4("240.0.0.0"), 4)
let linkLocal = newIPNetworkV4(newIPAddressV4("169.254.0.0"), 16)
let loopback = newIPNetworkV4(newIPAddressV4("127.0.0.0"), 8)

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
