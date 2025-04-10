import pusher
import os 


#going to use .env file to store the pusher credentials
pusher_client = pusher.Pusher(
  app_id=u'APP_ID',
  key=u'APP_KEY',
  secret=u'APP_SECRET',
  cluster=u'APP_CLUSTER',
  ssl=True
)



def send_message(channel, event, data):
  pusher_client.trigger(channel, event, data)
