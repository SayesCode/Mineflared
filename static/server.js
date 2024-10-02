const express = require('express');
const util = require('minecraft-server-util');
const cors = require('cors');  // Importing CORS

const app = express();
const port = 3000; // Port for the Express server

// Minecraft server IP and port
const mcServerIP = '127.0.0.1';
const mcServerPort = 25565;

// CORS Configuration (allows requests from localhost)
const corsOptions = {
    origin: '127.0.0.1',
    methods: 'GET,POST',
    allowedHeaders: 'Content-Type',
};

app.use(cors(corsOptions)); // Applying CORS middleware

// Endpoint to fetch Minecraft server status
app.get('/mc-status', async (req, res) => {
    try {
        // Fetch the Minecraft server status
        const response = await util.status(mcServerIP, { port: mcServerPort });
        
        // Send the server information as a JSON response
        res.json({
            motd: response.motd.clean,
            version: response.version.name,
            playersOnline: response.players.online,
            maxPlayers: response.players.max,
            latency: response.roundTripLatency
        });
    } catch (error) {
        // Handle errors and send an error message
        res.status(500).json({ error: 'Failed to fetch server status', details: error.message });
    }
});

// Start the Express server
app.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}`);
});
