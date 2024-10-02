const express = require('express');
const { Client, GatewayIntentBits, EmbedBuilder } = require('discord.js');
const dotenv = require('dotenv');
const cors = require('cors');  // Importing CORS

// Load variables from the .env file
dotenv.config({ path: '../mineflared.env' });

// Discord bot configuration
const botToken = process.env['DISCORD_BOT_TOKTEN'];
const chatId = process.env['DISCORD_CHAT_ID'];

// Initialize Discord client
const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent],
});

client.once('ready', () => {
  console.log('Bot connected to Discord!');
});

// Create an Express server
const app = express();
app.use(express.json());

// CORS Configuration (allows requests from localhost)
const corsOptions = {
    origin: '127.0.0.1',
    methods: 'GET,POST',
    allowedHeaders: 'Content-Type',
};
app.use(cors(corsOptions)); // Applying CORS middleware

// Endpoint to send a message
app.post('/send', async (req, res) => {
  try {
    // Ensure the bot is connected
    if (!client.isReady()) {
      await client.login(botToken);
    }

    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ message: 'No message provided' });
    }

    // Create an embed message for Discord
    const embed = new EmbedBuilder()
      .setTitle('Minecraft Server Link')
      .setDescription('Server info:\n\n' + message)
      .setColor(0x00ff00)
      .setTimestamp();

    // Send the embed to the Discord channel
    const channel = await client.channels.fetch(chatId);
    if (channel) {
      await channel.send({ embeds: [embed] });
      res.status(200).json({ message: 'Message sent successfully!' });
    } else {
      res.status(404).json({ message: 'Channel not found!' });
    }
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ message: 'Internal error while sending message' });
  }
});

// Start the server on port 8080
const port = 8080;
app.listen(port, () => {
  console.log(`Bot running at http://localhost:${port}`);
});
