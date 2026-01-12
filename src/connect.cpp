#include <cstdio>
#include <cstring>
#include <iostream>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>

int main()
{
    addrinfo server_hints;
    addrinfo* response;
    memset(&server_hints, 0, sizeof(server_hints));
    server_hints.ai_family = AF_UNSPEC;
    server_hints.ai_socktype = SOCK_STREAM;

    int code = getaddrinfo("www.example.com", "443", &server_hints, &response);


    int sockfd = socket(response->ai_family, response->ai_socktype, response->ai_protocol);

    code = connect(sockfd, response->ai_addr, response->ai_addrlen);

    if (code == -1)
    {
        std::cout << "Could not connect: " << strerror(errno);
    }

    close(sockfd);
    freeaddrinfo(response);
    return 0;
}
