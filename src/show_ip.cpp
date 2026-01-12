#include <cstdio>
#include <cstring>
#include <iostream>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>
#include <arpa/inet.h>


int main(int argc, char *argv[])
{

    if (argc != 2)
    {
        std::cout << "usage: showip your_hostname_here" << std::endl;
        return 1;
    }

    int status;
    addrinfo hints;
    addrinfo* results = nullptr;

    memset(&hints, 0, sizeof(hints));

    hints.ai_family = AF_UNSPEC; // ipv4 or 6
    hints.ai_socktype = SOCK_STREAM; // tcp socket

    if ((status = getaddrinfo(argv[1], NULL, &hints, &results)))
    {
        std::cout << "gai error: " << gai_strerror(status) << std::endl;
        return 2;
    }

    std::cout << "IP addresses for " << argv[1] << std::endl;

    addrinfo* tempResults = results;

    while (tempResults)
    {
        void* addr;
        std::string ipver;
        sockaddr_in* ipv4;
        sockaddr_in6* ipv6;

        if (tempResults->ai_family == AF_INET)
        {
            ipv4 = (sockaddr_in*)tempResults->ai_addr;
            addr = &(ipv4->sin_addr);
            ipver = "IPv4";
        }
        else
        {
            ipv6 = (sockaddr_in6*)tempResults->ai_addr;
            addr = &(ipv6->sin6_addr);
            ipver = "IPv6";
        }
        char ip_string[INET6_ADDRSTRLEN];

        inet_ntop(tempResults->ai_family, addr, ip_string, sizeof(ip_string));

        std::cout << ipver << ": " << ip_string << std::endl;

        tempResults = tempResults->ai_next;
    }

    freeaddrinfo(results);

    return 0;
}

/*
int main(int argc, char *argv[])
{
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

    return 0;
}
*/
