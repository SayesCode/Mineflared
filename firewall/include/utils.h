#ifndef UTILS_H
#define UTILS_H

// Function to monitor traffic on port 7844
void monitor_traffic();

// Parses received and sent packets
void parse_packet(const unsigned char *packet, size_t length);

#endif
