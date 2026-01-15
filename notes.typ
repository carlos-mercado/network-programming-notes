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

#pagebreak()
= 5 System Calls or Bust

=== \ _5.1 `getaddrinfo()` - Prepare to Launch!_  \

This function will be used to set up a lot of `structs` that will be used later.

This function has three parameters, and will give you a pointer to a linked list, `res`, of results.

1. The `node` parameter.

This is the host name to connect to, or an IP address. 

`www.example.com or 192.45.23.12`

2. The `service` parameter.

This can be a port number `:80` or the name of a particular service like `http, ftp, telnet, smtp` etc.

3. The `hints` parameter.

This is a reference to a `struct addrinfo` that has already been filled out with the relevant information.

`
// using getaddrinfo()

    int status;
    addrinfo hints;
    addrinfo* results = nullptr;

    memset(&hints, 0, sizeof(hints));

    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_PASSIVE;


    if ((status = getaddrinfo("127.0.0.1", "3490", &hints, &results)))
    {
        std::cout << "gai error: " << gai_strerror(status) << std::endl;
        exit(1);
    }


    freeaddrinfo(results);

`
=== \ _5.2 `socket()` - Get the File Descriptor_  \

The socket system call:

#align(center, block[
`int socket(int domain, int type, int protocol);`
])

The arguments allow you to say what kind of socket you want. (IPv4 or IPv6, stream or datagram, TCP or UDP).
- `domain`: `PF_INET` or `PF_INET6`
- `type`: `SOCK_STREAM` or `SOCK_DGRAM`
- `protocol`: Setting this to `0` will choose the proper protocol for a given type.

We can use the function to return a socket descriptor like so:

`
  int s;
  struct addrinfo hints, *res;

  // assume we alreawdy filled out the hints struct
  getaddrinfo("www.example.com", "http", &hints, &res)

  //...
  // error checking
  // walking throught hte linked list
  // etc
  //...


  s = socket(res->ai_family, res->ai_socktype, res->ai_protocol);

`
With the _socket descriptor_ that `socket()` returns, we can use it in later system calls. The call will return -1 on error.


=== \ _5.4 `bind()` - What port am I on?_  \

This function is useful when you want to associate a socket with a port on you local machine.

The `bind()` system call:

#align(center, block[`int bind(int sockfd, struct sockaddr *my_addr, int addrlen);`])

Parameters
- `sockfd` is the file descriptor returned by `socket()`
- `my_addr` is a pointer to a `struct sockaddr` that contains information about your address, namely, port and IP address.
- `addrlen` is the length (in bytes) of that address.


=== \ _5.5 `connect()` - Hey, you!_  \

Want to connect to a remote host? You're gonna want to use the `connect()` call.


#align(center, block[`int connect(int sockfd, struck sockaddr *serv_addr, int addrlen);`])

Parameters
- `sockfd` is the file descriptor returned by `socket()`
- `struck sockaddr` is a pointer to a `struct sockaddr` that contains information about the server / destination, namely, port and IP address.
- `addrlen` is the length (in bytes) of that address.

=== \ _5.6 `listen()` - Will somebody please call me?_  \

Instead of connecting to another machine, want to wait for incoming connections to your machine instead? Easy. Two steps.
- `listen()`
- `accept()`

#align(center, block[`int listen(int sockfd, int backlog);`])

Parameters
- `sockfd` is the file descriptor returned by `socket()`.
- `backlog` is the number of connections allowed in the incoming queue. Connections will pile up in the queue until they are `accept()`'d. So the number is the amount that can pile up. Most systems use 20.


=== \ _5.7 `accept()` - "Thank you for calling port 3490"_  \

The larger process happening:
- Someone will try to `connect()` to your machine on a port that you are `listen()`ing on.
- The connection will wait in a queue waiting to be `accept()`'d.
- You call `accept()`, telling it to get the pending connection.
- It'll return a _new_ socket file descriptor that you can `send()` and `recv()` on.

#align(center, block[`int accept(int sockfd, struck sockaddr *addr, int addrlen);`])

Parameters
- `sockfd` is the listening file descriptor returned by `socket()`.
- `addr` is usually going to be a pointer to a local `struct sockaddr_storage`. This is where the information about the incoming connection ill go.

=== \ _5.8 `send() and recv()` - "Talk to me, baby!"_  \

These are two functions that we're gonna use to talk over stream sockets.

Quick Aside: These functions are *_blocking_*. This means that the program will not continue until there is some data to receive. 

#align(center, block[`int send(int sockfd, const void *msg, int len, int flags);`])

Parameters
- `sockfd` is the socket descriptor you want to send data to (The one that is returned by `socket` or the one that you got with `accept`).
- `msg` is a pointer to the data that you want to send
- `len` is the length of that data in bytes.
- `flags` usually just 0. Look up man pages for more info.


#align(center, block[`int recv(int sockfd, void *buff, int len, int flags);`])

Parameters
- `sockfd` is the socket descriptor you want to read data from.
- `buff` is a buffer to read the data into.
- `len` is the maximum length of the buffer.
- `flags` usually just 0. Look up man pages for more info.

`recv()` will return the number of bytes that were actually written onto the buffer, or -1 on error.

If you get returned `0` on return, that means that the remote side has closed the connection on you.


=== \ _5.9 `sendto() and recvfrom()` - "Talk to me, DGRAM-style!"_  \

Hold on, `recv()` and `send()` are specific to `SOCK_STREAM` sockets. How is data moved for unconnected datagram sockets?

#align(center, block[`int sendto(int sockfd, const void *msg, int len, unsigned int flags, const struct sockaddr* to, socklen_t tolen);`])

The call is basically the same as the call to `send()` with two other pieces of information.

- `to` is a pointer to `struct sockaddr` which contains the destination IP address and port.
- `tolen` is and int, which can be set to `sizeof(*to)`.


#align(center, block[`int recvfrom(int sockfd, void *buf, int len, unsigned int flags, const struct sockaddr* from, int *fromlen);`])

This call is basically the same as the call `recv()` with the addition of two other fields

- `from` is a pointer to `struct sockaddr` which contains the IP address and port of the originating machine.
- `fromlen` is a pointer to a local int that should be initialized to `sizeof` from or `sizeof(struct sockaddr_storage)`.


=== \ _5.10 `close() and shutdown()` - "Get outta my face!"_  \

Ready to close the connection on your socket descriptor? Just uise the regular file descriptor `close()`.

`close(sockfd)`;

If want to close off communication from just one end of a socket, or just close off both ends (just like `close()`) you can use the `shutdown()` function.

`int shutdown(int sockfd, int how);`

Parameters
- `sockfd` is the socket descriptor you want to shut down.
- How could be 
- - 0 : Further receives are disallowed
- - 1 : Further sends are disallowed
- - 2 : Further sends and receives are disallowed (like `close()`);

=== \ _5.11 `getpeername()` - "Who are you"_  \

Want to know who is at the other end of a connected stream socket?

Use `getpeername()`.

`int getpeername(int sockfd, struct sockaddr* addr, int* addrlen);`

Parameters
- `sockfd` is the socket descriptor of the connected stream socket.
- `addr` is a pointer to a `struct` sockaddr that will hold the information about the other side of the connection.
- `addrlen` is a pointer to an `int` that, should be initialized to `sizeof(*addr)` or `sizeof(struct sockaddr)`.

=== \ _5.10 `gethostname()` - "Who am I"_  \

Want to know the name of the computer that your program is running on?

Use `gethostname()`.

`int gethostname(char* hostname, size_t size);`

Parameters
- `hostname` is a pointer to an array of chars that will contain the hostname upon the functions return
- `size` is the length, in bytes, of the `hostname` array.
