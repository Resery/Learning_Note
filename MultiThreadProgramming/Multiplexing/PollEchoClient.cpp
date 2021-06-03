#include <iostream>
#include <set>
#include <netdb.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <poll.h>
#include <sys/epoll.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>

#define MAXLINE 128

int Fd[MAXLINE];

unsigned int maxSocketId(int ClientFd, std::set<int>& ConnFd) {
    return ConnFd.empty() ? ClientFd : std::max(ClientFd, *ConnFd.rbegin());
}

static inline int set_nonblock(int fd) {
    int flags;
#if defined(O_NONBLOCK)
    if (-1 == (flags = fcntl(fd, F_GETFL, 0))) {
        flags = 0;
    }
    return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
#else
    flags = 1;
    return ioctl(fd, FIONBIO, &flags);
#endif
}

int main(int argc, char **argv) {
    int ListenFd = 0;
    int connfd = 0;
    socklen_t clilen;
    char RecvMsg[MAXLINE] = {0};

    struct sockaddr_in cliaddr, servaddr;
    char ip[MAXLINE] = {0};

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <port>", argv[0]);
        exit(-1);
    }

    // Init Server Info Struct
    bzero(&servaddr, sizeof(servaddr));
    // Set Server Procotol
    servaddr.sin_family = AF_INET;
    // Set Server Ip Address
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    // Set Server Port
    servaddr.sin_port = htons(atoi(argv[1]));

    //
    if ((ListenFd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        perror("Create Socket Failed");
        exit(-1);
    }

    if (bind(ListenFd, (const struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) {
        perror("Bind Socket Failed");
        exit(-1);
    }

    std::cout << "Start Server at ";
    std::cout << inet_ntop(AF_INET, &servaddr.sin_addr, ip, MAXLINE) << " : ";
    std::cout << ntohs(servaddr.sin_port) << std::endl;
    listen(ListenFd, 4);

    pollfd Fds[4096];
    int FdsSize = 1;
    int TimeOut = 0;

    Fds[0].fd = ListenFd;
    Fds[0].events = POLLRDNORM;
    Fds[0].revents = 0;

    while (true) {
        int Ready = poll(Fds, FdsSize, TimeOut);

        if (Fds[0].revents & POLLRDNORM) {
            int ConnFd = 0;
            if ((ConnFd = accept(ListenFd, (struct sockaddr *)&cliaddr, &clilen)) < 0) {
                perror("Accept Socket Failed");
                exit(EXIT_FAILURE);
            }
            std::cout << "Connect From ";
            std::cout << inet_ntop(AF_INET, &cliaddr.sin_addr, ip, MAXLINE) << " : ";
            std::cout << ntohs(cliaddr.sin_port) << "\n" << std::endl;
            Fds[FdsSize].fd = ConnFd;
            Fds[FdsSize].events = POLLRDNORM;
            Fds[FdsSize].revents = 0;
            FdsSize++;
        }

        for (int i = 1; i < FdsSize; i++) {
            if (Fds[i].revents & POLLRDNORM) {
                char RecvMsg[MAXLINE];
                int Len = recv(Fds[i].fd, RecvMsg, MAXLINE, MSG_NOSIGNAL);
                if (Len <= 0) {
                    std::clog << "The Client ";
                    std::cout << inet_ntop(AF_INET, &cliaddr.sin_addr, ip, MAXLINE) << " : ";
                    std::cout << ntohs(cliaddr.sin_port) << " Is Disconnect" << std::endl;
                    shutdown(Fds[i].fd, SHUT_RDWR);
                    close(Fds[i].fd);
                    if (i == FdsSize - 1) {
                        FdsSize--;
                    }
                    Fds[i].fd = -1;
                } else {
                    std::clog << "Recv Msg : " << RecvMsg << std::endl;
                    send(Fds[i].fd, RecvMsg, MAXLINE, MSG_NOSIGNAL);
                }
            }
        }
    }
}