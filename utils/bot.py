import discord
from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import asyncio

# Define intents
intents = discord.Intents.default() 
intents.messages = True  # Enable message-related events
intents.guilds = True    # Enable guild-related events

# Create the Discord bot with intents
bot = discord.Client(intents=intents)

# Ensure to define your chat_id and bot_token
chat_id = int(os.getenv('DISCORD_CHAT_ID'))  # Ensure this is set correctly
bot_token = os.getenv('DISCORD_BOT_TOKEN')  # Ensure this is set correctly

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

        # Use asyncio to run the discord message sending
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

        # Run the send_discord_message function
        asyncio.run(send_discord_message())

        return jsonify({'message': 'Message sent successfully!'}), 200

    except Exception as error:
        print(f"Error sending message: {error}")
        return jsonify({'message': 'Internal error while sending message'}), 500

# Start the Flask server on port 8080
if __name__ == '__main__':
    # Start the Discord bot in a separate thread
    loop = asyncio.get_event_loop()
    loop.create_task(bot.start(bot_token))
    
    # Run the Flask app
    app.run(port=8080)
