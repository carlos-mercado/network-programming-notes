= 2 What is a socket?

Sockets are a way to talk to other programs by using standard Unix *file descriptors*.

OK, but what is a file descriptor?

A file descriptor is simply an integer associated with some open file. BUT, that file can be a network connection, a pipe, a terminal, a real on-the-disk file, or basically anything else.

How do you acquire one of these file descriptors for your network communication needs?

You make a call to the `socket()` system routine. This will return a socket descriptor, and you can communicate through it with specialized `send()` and `recv()` socket calls.

=== \ _2.1 Two Types of Internet Sockets_  \
- Stream Sockets (`SOCK_STREAM`)
- Datagram Sockets (`SOCK_DGRAM`)

*Datagram Sockets*:
- Sometimes called "connectionless" sockets
- Less Reliable

*Stream Sockets*:
- Reliable
- Two-Way Connected
- Items arrive in-order the same way that they are sent
- Error free

`How are stream sockets so reliable?`

Stream sockets use a protocol called TCP. TCPs job is to make sure that your data arrives sequentially and error free.

`Why are datagram sockets called "connectionless"? why are they not as reliable?`

Datagram sockets don't use TCP, they use UDP. UDP does not place as much emphesis on reliability as TCP. Data may arrive it might not. Data might arrive in-order it might not. That is a fact for UDP. Datagram sockets are connectionless because you don't have to have maintain an open connection with another computer. You just build your packet, slap your IP header on it with destination info, and send it out. No connection needed.

`Why use Stream Sockets / UDP?`

*SPEED.*


= 3 IP Addresses, struct S, and Data Munging

=== \ _3.1.1 Subnets_  \

`192.0.2.12/24`

The number 24 to the right of the IPv4 address here is the number of network bits (starting from the left). 24 network bits would leave the remaining bits (8) as the host bits.

To get the network number: Use the netmask and BITWISE AND it with the IP address.

The netmask will look something like this:

`255.255.255.0`

=== \ _3.2 Byte Order_  \

Network Byte Order = Big Endian

Your Computer stores numbers in Host Byte Order.

When building packets or filling out data structures you'll need to make sure your two and four-byte numbers are in the Network Byte Order. But, how is that done if you don't know the native Host Byte Order?

Answer: Just assume the Host Byte Order is wrong and run the value through a function to set it to network byte order.

The functions we'll use:

#table(
  columns: (auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Function*], [*Description*],
  ),
  [htons()], [host to network short], 
  [htonl()], [host to network long],
  [ntohs()], [network to host short],
  [ntohl()], [network to host long]
)

We are going to want to convert the numbers to Network Byte Order before they go out on the wire, and convert them to Host Byte Order as they come in off the wire.

=== \ _3.4 IP Addresses, Part Deux_  \


Converting IP address from dots and numbers notation to *`struct in_addr`* or *`struct in_addr`*, is simple just use *`inet_pton()`*.
`
struct sockaddr_in sa; //IPv4
struct sockaddr_i //IPv6

inet_pton(AF_INET, "10.12.110.57", &(sa.sin_addr));
inet_pton(AF_INET6, "2001:db8:63b3:1::3490", &(sa6.sin6_addr));
`

That function, `inet_pton()`, actually returns a values, -1 if there is an error, or 0 if the address is messed up. Make sure the return value > 1 before using it.

What if we want to do the opposite operation?

Just use *`inet_ntop()`*

`
// IPv4:

char ip4[INET_ADDRSTRLEN];  // space to hold the IPv4 string
struct sockaddr_in sa;      // pretend this is loaded with something

inet_ntop(AF_INET, &(sa.sin_addr), ip4, INET_ADDRSTRLEN);

printf("The IPv4 address is: %s\n", ip4);


// IPv6:

char ip6[INET6_ADDRSTRLEN]; // space to hold the IPv6 string
struct sockaddr_in6 sa6;    // pretend this is loaded with something

inet_ntop(AF_INET6, &(sa6.sin6_addr), ip6, INET6_ADDRSTRLEN);

printf("The address is: %s\n", ip6);

`
