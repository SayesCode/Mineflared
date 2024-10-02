#include "logging.h"
#include <stdio.h>

void log_packet_info(int src_port, int dest_port, size_t bytes) {
    printf("Packet sent from %d to %d, size: %zu bytes\n", src_port, dest_port, bytes);
}
