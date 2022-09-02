import ipaddress_v4

echo "# IPaddressV4 Nim module"
echo ""

echo "## Testing invalid IP Address"
echo ""

try:
    echo "try: IPAddressV4().init(\"192.168.666.12\")"
    var myIP = IPAddressV4().init("192.168.666.12")

    # Avoid compiler complains about unused variables...
    myIP = myIP + 1
except ValueError as e:
    echo "except ValueError as e (echo e.msg): " & e.msg

echo ""

echo "## IP utility functions"
echo ""

echo "int64ToIP(3232235841): ", int64ToIP(3232235841)

echo "fromReversePTR(\"65.1.168.192.in-addr.arpa\"): ", fromReversePTR("65.1.168.192.in-addr.arpa")

echo ""
echo "## Test invalid in-addr.arpa"
echo ""

echo "fromReversePTR(\"1.1.1.in-addr.arpa\")"

try:
    echo fromReversePTR("1.1.1.in-addr.arpa")
except ValueError as e:
    echo "Exception of ValueError: " & e.msg

echo ""

let IP: string = "192.168.0.12"
let CIDR: int = 24 
var myIP = IPAddressV4()

try:
    echo "# In try/except, IPAddressV4 usage"
    echo ""

    echo "IPAddressV4().init(" & IP & ")"
    echo ""
    myIP = IPAddressV4().init(IP)

    var myNetwork = IPNetworkV4(ip: myIP, cidr: CIDR)

    echo "## IPAddressV4 methods"
    echo ""

    echo ".reversePTR() : ", myIP.reversePTR()
    echo ".toDec()      : ", myIP.toDec()
    echo ".isPrivate()  : ", myIP.isPrivate()
    echo ".isReserved() : ", myIP.isReserved()
    echo ".isLinkLocal(): ", myIP.isLinkLocal()
    echo ".isLoopback() : ", myIP.isLoopback()

    echo ""
    echo "## IPAddressV4 overloaded operators"
    echo ""

    echo "$(IPAddressV4().init(\"" & IP & "\")): ", myIP

    myIP = myIP + 10
    echo "IPAddressV4.init(\"" & IP & "\") + 10: ", myIP

    myIP = myIP - 10
    echo "IPAddressV4.init(\"192.168.1.22\") - 10: ", myIP

    let myIP2 = IPAddressV4().init("192.168.0.22")
    echo "IPAddressV4.init(\"" & IP & "\") == IPAddressV4.init(\"192.168.0.22\"): ", myIP == myIP2
    echo "IPAddressV4.init(\"" & IP & "\") == IPAddressV4.init(\"192.168.0.12\"): ", myIP == myIP

    echo "IPAddressV4.init(\"" & IP & "\") > IPAddressV4.init(\"192.168.0.22\") : ", myIP > myIP2
    echo "IPAddressV4.init(\"" & IP & "\") < IPAddressV4.init(\"192.168.0.22\") : ", myIP < myIP2


    echo "IPAddressV4.init(\"" & IP & "\") in IPNetwork(ip: \"",
                myNetwork.networkAddress, "\"), cidr: ", CIDR, " : ",
                myIP in myNetwork

    let CIDR2 = 32 
    var myNetwork2 = IPNetworkV4(ip: IPAddressV4().init("192.168.0.22"), cidr: CIDR2)

    echo "IPAddressV4.init(\"" & IP & "\") in IPNetwork(ip: \"",
                myNetwork2.networkAddress, "\"), cidr: ", CIDR2, " : ",
                myIP in myNetwork2


    echo ""

    echo "# In try/except IPNetworkV4 usage"

    echo "Network for ", myIP, "/", myNetwork.cidr
    echo ""

    echo "## IPNetworkV4 methods"
    echo ""
    echo ".mask()             : ", myNetwork.mask()
    echo ".totalHosts()       : ", myNetwork.totalHosts()
    echo ".usableHosts()      : ", myNetwork.usableHosts()
    echo ".networkAddress()   : ", myNetwork.networkAddress()
    echo ".broadcastAddress() : ", myNetwork.broadcastAddress()
    echo ".hosts() (here only first 10)"

    var counter = 0

    for host in myNetwork.hosts():
        echo $host

        if counter >= 10:
            break

        inc(counter)

    echo "..."

except ValueError as e:
    echo e.msg
