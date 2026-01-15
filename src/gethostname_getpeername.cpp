#include <netinet/in.h>
#include <unistd.h>
#include <iostream>

int main()
{
    char buff[INET6_ADDRSTRLEN];
    int badResponse = gethostname(buff, sizeof(buff));

    if (badResponse)
    {
        std::cout << "could not get hostname" << std::endl;
    }

    std::cout << buff << std::endl;


    return 0;

}
