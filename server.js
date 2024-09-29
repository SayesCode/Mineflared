// server.js
const express = require('express');
const { Client } = require('minecraft-server-util');

const app = express();
const PORT = 3000;

app.get('/server-banner', async (req, res) => {
    const serverAddress = 'localhost';
    const port = 25565; // Port

    try {
        const response = await Client.status(serverAddress, port);
        res.json({ banner: response.favicon });
    } catch (error) {
        console.error('Erro ao conectar ao servidor:', error);
        res.status(500).json({ error: 'Não foi possível obter o banner' });
    }
});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
