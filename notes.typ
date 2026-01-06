= 2 What is a socket?

Sockets are a way to talk to other programs by using standard Unix *file descriptors*.

OK, but what is a file descriptor?

A file descriptor is simply an integer associated with some open file. BUT, that file can be a network connection, a pipe, a terminal, a real on-the-disk file, or basically anything else.

How do you acquire one of these file descriptors for your network communication needs?

You make a call to the `socket()` system routine. This will return a socket descriptor, and you can communicate through it with specialized `send()` and `recv()` socket calls.

\ _2.1 Two Types of Internet Sockets_  \

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
