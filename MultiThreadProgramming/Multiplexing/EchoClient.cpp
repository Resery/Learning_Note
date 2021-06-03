#include <iostream>
#include <netdb.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <strings.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>

#define MAXLINE 128

/**
 * 套接字建立连接过程
 * 
 * 1. 首先使用 socket 函数创建一个套接字文件，该函数返回一个文件描述符
 * 2. 然后使用输入的 hostname 获取主机信息
 * 3. 创建一个存储服务器信息的结构体并进行初始化
 * 4. 使用 connect 函数连接目标服务器
 */

int main(int argc, char **argv) {
    int sockfd;
    struct sockaddr_in servaddr;
    char SendMsg[MAXLINE] = {0};
    char RecvMsg[MAXLINE] = {0};

    if (argc != 3) {
        fprintf(stderr, "Usage: %s <hostname> <port>\n", argv[0]);
        exit(0);
    }
    
    bzero(&servaddr, sizeof(servaddr));
    
    servaddr.sin_family = AF_INET;
    inet_pton(AF_INET, argv[1], &servaddr.sin_addr);
    servaddr.sin_port = htons(atoi(argv[2]));

    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        perror("Create Socket Failed");
        exit(-1);
    }

    if(connect(sockfd, (const struct sockaddr *)&servaddr, sizeof(servaddr)) != 0)
    {
        perror("connect failed");
        exit(-1);
    }

    std::cout << "Enter Msg: ";
    while (fgets(SendMsg, MAXLINE, stdin)) {
        int ret = 0;
        if ((ret = strncmp(SendMsg, "exit", 4)) == 0) exit(0);
        write(sockfd, SendMsg, sizeof(SendMsg));
        read(sockfd, RecvMsg, MAXLINE);
        std::cout << "Recv Msg: " << RecvMsg << std::endl;
        std::cout << "Enter Msg: ";
    }

    close(sockfd);
    exit(0);
}