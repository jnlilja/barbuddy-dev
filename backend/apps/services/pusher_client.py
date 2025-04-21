from datetime import datetime
from django.conf import settings

def send_message(channel, event, data):
    """
    Send a message through Pusher.
    
    Args:
        channel (str): The channel to send the message to
        event (str): The event name
        data (dict): The data to send
    """
    settings.PUSHER_CLIENT.trigger(channel, event, data)

def unsubscribe_channel(channel_name):
    """
    Unsubscribe all users from a channel.
    This effectively 'deletes' the channel by removing all subscribers.
    
    Args:
        channel_name (str): The name of the channel to unsubscribe from
    """
    try:
        # Get channel info
        channel_info = settings.PUSHER_CLIENT.channel_info(channel_name)
        
        # If channel exists and has subscribers
        if channel_info and channel_info.get('occupied'):
            # Trigger a 'channel-deleted' event to notify subscribers
            settings.PUSHER_CLIENT.trigger(channel_name, 'channel-deleted', {
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