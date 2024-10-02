// server.js
const express = require('express');
const { Client, GatewayIntentBits, EmbedBuilder } = require('discord.js');
const dotenv = require('dotenv');
const fs = require('fs');
const path = require('path');

// Load variables from the .env file
dotenv.config({ path: '../mineflared.env' });

// Discord bot configuration
const botToken = process.env['DISCORD-BOT-TOKTEN'];
const serverId = process.env['DISCORD-SERVER-ID'];
const chatId = process.env['DISCORD-CHAT-ID'];

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

// Endpoint to send the .md file content as an embed
app.post('/send', async (req, res) => {
  try {
    // Ensure the bot is connected
    if (!client.isReady()) {
      await client.login(botToken);
    }

    // Extract the .md file path from the request body
    const { filePath } = req.body;

    // Check if filePath is provided and valid
    if (!filePath || !fs.existsSync(filePath) || path.extname(filePath) !== '.md') {
      return res.status(400).json({ message: 'Invalid .md file path' });
    }

    // Read the file content
    const fileContent = fs.readFileSync(filePath, 'utf-8');

    // Create an embed message for Discord
    const embed = new EmbedBuilder()
      .setTitle('Markdown File Content')
      .setDescription('The content of the Markdown file is below:')
      .setColor(0x00ff00)
      .addFields({
        name: 'File Content',
        value: `\`\`\`md\n${fileContent}\n\`\`\``, // Enclose the markdown content in code block
      })
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
  console.log(`Server running at http://localhost:${port}`);
});
