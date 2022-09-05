##
# Main Nim module for IP Address V4.
#
# Description:
# This is the only module that should be imported in your code. It will provide
# the following objects, with all their methods:
#   - IPAddressV4
#   - IPNetworkV4
#
# This module will also provide IANA utility functions
#
# Author: 0xb4db01
#

import v4/ipaddress

##
# IPAddressV4 object
#
export IPAddressV4

##
# IPAddressV4 methods
#
export newIPAddressV4
export isValid
export int64ToIP
export fromReversePTR
export reversePTR
export toDec

##
# IPAddressV4 overloaded operators
# 
export `$`
export `+`
export `-`
export `>`
export `<`

import v4/ipnetwork

##
# IPNetworkV4 object
#
export IPNetworkV4

export newIPNetworkV4
##
# IPNetworkV4 methods
#
export getCidr
export networkAddress
export mask
export totalHosts
export usableHosts
export broadcastAddress
export hosts

##
# IPNetworkV4 overloaded operators
#
export `in`
export `==`

##
# IANA utility functions
# 
import v4/iana
export isPrivate
export isReserved
export isLinkLocal
export isLoopback
