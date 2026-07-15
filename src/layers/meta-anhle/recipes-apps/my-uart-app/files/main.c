#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>

int main() {
    // Mở cổng UART2 (ttyAMA1)
    int fd = open("/dev/ttyAMA1", O_RDWR | O_NOCTTY | O_NDELAY);
    if (fd == -1) {
        perror("Loi: Khong the mo /dev/ttyAMA1");
        return -1;
    }

    // Cấu hình thông số UART (Baudrate 115200)
    struct termios options;
    tcgetattr(fd, &options);
    cfsetispeed(&options, B115200);
    cfsetospeed(&options, B115200);
    options.c_cflag |= (CLOCAL | CREAD);
    options.c_cflag &= ~CSIZE;
    options.c_cflag |= CS8; // 8 data bits
    tcsetattr(fd, TCSANOW, &options);

    char tx_buffer[] = "UART Hello tu meta-anhle!\n";
    
    printf("Dang gui du lieu qua /dev/ttyAMA1...\n");
    while(1) {
        write(fd, tx_buffer, strlen(tx_buffer));
        sleep(2); // Gửi lại sau mỗi 2 giây
    }

    close(fd);
    return 0;
}