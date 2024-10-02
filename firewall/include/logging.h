#ifndef LOGGING_H
#define LOGGING_H

#include <stddef.h> // For the size_t type

// Function to log packet information
void log_packet_info(int src_port, int dest_port, size_t bytes);

#endif
