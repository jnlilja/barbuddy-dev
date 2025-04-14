from dotenv import load_dotenv

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