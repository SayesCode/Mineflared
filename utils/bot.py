import os
import discord
from discord.ext import commands
from flask import Flask, request, jsonify
from dotenv import load_dotenv
from flask_cors import CORS

# Load variables from the .env file
load_dotenv(dotenv_path='../mineflared.env')

# Discord bot configuration
bot_token = os.getenv('DISCORD_BOT_TOKEN')
chat_id = int(os.getenv('DISCORD_CHAT_ID'))

# Initialize the Discord client
intents = discord.Intents.default()
intents.guilds = True
intents.guild_messages = True
intents.message_content = True

bot = commands.Bot(command_prefix='!', intents=intents)

@bot.event
async def on_ready():
    print('Bot connected to Discord!')

# Create the Flask server
app = Flask(__name__)
CORS(app, resources={r"/send": {"origins": "http://127.0.0.1"}})

# Endpoint to send a message
@app.route('/send', methods=['POST'])
def send_message():
    try:
        # Check if a message was provided in the request body
        data = request.get_json()
        message = data.get('message', '')

        if not message:
            return jsonify({'message': 'No message provided'}), 400

        # Asynchronous function to send the message to the Discord channel
        async def send_discord_message():
            channel = bot.get_channel(chat_id)
            if channel is not None:
                embed = discord.Embed(
                    title="Minecraft Server Link",
                    description=f"Server info:\n\n{message}",
                    color=discord.Color.green()
                )
                embed.timestamp = discord.utils.utcnow()

                await channel.send(embed=embed)
            else:
                return jsonify({'message': 'Channel not found!'}), 404

        # Execute the message sending using asyncio
        bot.loop.create_task(send_discord_message())
        return jsonify({'message': 'Message sent successfully!'}), 200

    except Exception as error:
        print(f"Error sending message: {error}")
        return jsonify({'message': 'Internal error while sending message'}), 500

# Start the Flask server on port 8080
if __name__ == '__main__':
    bot.loop.create_task(bot.start(bot_token))  # Start the Discord bot
    app.run(port=8080)
