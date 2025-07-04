# Project Documentation




## Overview

Our project currently runs using a local database setup. This means that to run the entire project, you'll need to:

- Set up a local PostgreSQL server for the front end.
- Configure the necessary settings in the backend folder.

*Note: We should plan to implement Docker soon to streamline our setup and integrate the various components more efficiently.*

## Temporary Documentation

For the time being, this documentation is temporary:

- I will host the full documentation on GitHub Pages when possible.
  
### Viewing API Documentation

To view the API documentation:

1. Open [Swagger Editor](https://editor-next.swagger.io/).
2. Copy and paste the contents of the [April24.txt](https://github.com/user-attachments/files/19898403/April24.txt) file into the editor.

### April 16
I added a `sexual_preference` field to the user model. Options are:

`SEXUAL_PREFERENCE_CHOICES = [     ('straight', 'Straight'),     ('gay', 'Gay'),     ('bisexual', 'Bisexual'),     ('asexual', 'Asexual'),     ('pansexual', 'Pansexual'),     ('other', 'Other'), ]`

- There’s now an endpoint to **get and update** the user’s location.
- Since we're using **Firebase for auth**, the frontend needs to include the Firebase `idToken` in the `Authorization` header for all API calls:

`Authorization: Bearer <idToken>`

In Swift, you can grab the token with:

`Auth.auth().currentUser?.getIDToken { idToken, error in     // attach "Bearer \(idToken)" to your API request headers }`


### Events filtering based on day: 

GET /api/events/?today=true
Authorization: Bearer <token>

## Pusher API Overview
The BarBuddy application uses Pusher for real-time messaging functionality. Pusher is integrated to handle both direct messages between users and group chat messages.

### Configuration
Backend Setup:
1. Install the Pusher Python SDK:
2. Configure Pusher credentials in your .env file:

### Pusher API Endpoints
1. Send Message  
Endpoint: /api/trigger/  
Method: POST  
Description: Sends a message through Pusher  
3. Get Direct Message Channel Name  
Endpoint: /api/messages/get_channel_name/  
Method: GET  
Query Parameters:  
user_id: ID of the other user in the conversation  
4. Get Group Chat Channel Name  
Endpoint: /api/group-chats/{group_id}/get_channel_name/  
Method: GET  

## API endpoints: 
#### API DOCS: 
https://barbuddy-backend-148659891217.us-central1.run.app/swagger/
#### Base URL: 
https://barbuddy-backend-148659891217.us-central1.run.app






