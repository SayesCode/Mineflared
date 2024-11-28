import discord
from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import asyncio
import json
import threading

# Load environment variables from env.json file
def load_env_from_json(filepath):
    with open(filepath, 'r') as f:
        return json.load(f)

env_vars = load_env_from_json('../env.json')

# Define intents
intents = discord.Intents.default()
intents.messages = True
intents.guilds = True

# Create the Discord bot with intents
bot = discord.Client(intents=intents)

# Get environment variables
server_id = env_vars.get('DISCORD_SERVER_ID')
chat_id = env_vars.get('DISCORD_CHAT_ID')
bot_token = env_vars.get('DISCORD_BOT_TOKEN')

if server_id is None:
    raise ValueError("Key 'DISCORD_SERVER_ID' not found in env.json.")
if chat_id is None:
    raise ValueError("Key 'DISCORD_CHAT_ID' not found in env.json.")
if bot_token is None:
    raise ValueError("Key 'DISCORD_BOT_TOKEN' not found in env.json.")

# Ensure IDs are integers
server_id = int(server_id)
chat_id = int(chat_id)

@bot.event
async def on_ready():
    print(f'Bot connected to Discord server with ID {server_id}.')

# Create the Flask server
app = Flask(__name__)
CORS(app, resources={r"/send": {"origins": "http://127.0.0.1"}})

# Endpoint to send a message
@app.route('/send', methods=['POST'])
def send_message():
    try:
        data = request.get_json()
        message = data.get('message', '')

        if not message:
            return jsonify({'message': 'No message provided'}), 400

        async def send_discord_message():
            channel = bot.get_channel(chat_id)
            if channel is None:
                return jsonify({'message': 'Channel not found!'}), 404

            embed = discord.Embed(
                title="Minecraft Server Link",
                description=f"Server info:\n\n{message}",
                color=discord.Color.green()
            )
            embed.timestamp = discord.utils.utcnow()
            await channel.send(embed=embed)

        # Schedule the message to be sent asynchronously
        asyncio.run_coroutine_threadsafe(send_discord_message(), asyncio.get_event_loop())

        return jsonify({'message': 'Message sent successfully!'}), 200

    except Exception as error:
        print(f"Error sending message: {error}")
        return jsonify({'message': 'Internal error while sending message'}), 500

# Function to run Flask in a separate thread
def run_flask():
    app.run(port=8080)

# Start both the bot and the Flask server
if __name__ == '__main__':
    # Run Flask in a separate thread
    flask_thread = threading.Thread(target=run_flask)
    flask_thread.start()

    # Run the bot on the main thread
    loop = asyncio.get_event_loop()
    loop.run_until_complete(bot.start(bot_token))
