/*
Project: The Echo Multi-Tool

The server should sit on a specific port and wait
for a connection. When it receives a message,
it prints it to the screen and sends the same message
back to the client.
*/

#include <cstring>
#include <iostream>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>
#include <arpa/inet.h>


int main()
{

    int status_code;
    addrinfo hints;
    addrinfo* results = nullptr;

    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_PASSIVE;

    status_code = getaddrinfo("127.0.0.1", "3490", &hints, &results);

    if (status_code != 0)
    {
        std::cout << "gai error: " << gai_strerror(status_code) << std::endl;
        return 2;
    }

    int sockfd = socket(results->ai_family, results->ai_socktype, results->ai_protocol);

    status_code = bind(sockfd, results->ai_addr, results->ai_addrlen);

    if (status_code != 0)
    {
        std::cout << "gai error: " << gai_strerror(status_code) << std::endl;
        return 2;
    }

    listen(sockfd, 10);

    sockaddr_storage user_addr;
    socklen_t user_addr_size = sizeof(user_addr);

    int newfd = accept(sockfd, (sockaddr*)&user_addr, &user_addr_size);

    const int buffer_size = 256;
    char buff[buffer_size];

    recv(newfd, buff, buffer_size, 0); //THIS FUNCTION IS BLOCKING 

    std::cout << buff << std::endl;

    return 0;
}
