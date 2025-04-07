import pusher

pusher_client = pusher.Pusher(
  app_id='1963649',
  key='9f2ddf2b1d39e4a29fff',
  secret='5f14e48dc97cbb1284f1',
  cluster='us3',
  ssl=True
)

def send_message(channel, event, data):
  pusher_client.trigger(channel, event, data)
