#include <cstdio>
#include <cstring>
#include <iostream>
#include <netinet/in.h>
#include <sched.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>

int main()
{
    addrinfo hints;
    addrinfo* response_list;

    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_PASSIVE;

    int ret = getaddrinfo(NULL, "3490", &hints, &response_list);

    if(ret != 0)
    {
        std::cout << "gai error: " << gai_strerror(ret) << std::endl;
        return 2;
    }

    //make a socket

    int sockfd = socket(response_list->ai_family, response_list->ai_socktype, response_list->ai_protocol);

    ret = bind(sockfd, response_list->ai_addr, response_list->ai_addrlen);

    const char* msg = "what is going on?";

    int bytes_sent = send(sockfd, msg, strlen(msg), 0);

    if (bytes_sent < strlen(msg))
    {
        std::cout << "Not all bytes sent out!" << std::endl;
    }

    freeaddrinfo(response_list);

}
