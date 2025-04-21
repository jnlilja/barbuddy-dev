from dotenv import load_dotenv
from datetime import datetime

# Load environment variables from .env file
load_dotenv()

import pusher
import os


#going to use .env file to store the pusher credentials
pusher_client = pusher.Pusher(


  app_id=os.getenv('PUSHER_APP_ID'),
  key=os.getenv('PUSHER_KEY'),
  secret=os.getenv('PUSHER_SECRET'),
  cluster=os.getenv('PUSHER_CLUSTER'),
  ssl=True

)

def send_message(channel, event, data):
  pusher_client.trigger(channel, event, data)

def unsubscribe_channel(channel_name):
    """
    Unsubscribe all users from a channel.
    This effectively 'deletes' the channel by removing all subscribers.
    """
    try:
        # Get channel info
        channel_info = pusher_client.channel_info(channel_name)
        
        # If channel exists and has subscribers
        if channel_info and channel_info.get('occupied'):
            # Trigger a 'channel-deleted' event to notify subscribers
            pusher_client.trigger(channel_name, 'channel-deleted', {
                'message': 'This chat has been deleted',
                'timestamp': datetime.now().isoformat()
            })
            
            # Note: Pusher doesn't actually have a delete method
            # The channel will automatically be removed when all subscribers leave
    except Exception as e:
        print(f"Error unsubscribing from channel {channel_name}: {str(e)}")

if __name__ == "__main__":
    # Test sending a message
    test_channel = "test-channel"
    test_event = "test-event"
    test_data = {"message": "Hello, Pusher!"}

    try:
        send_message(test_channel, test_event, test_data)
        print("Message sent successfully!")
    except Exception as e:
        print("Error sending message:", e)