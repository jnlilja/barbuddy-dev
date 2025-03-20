import firebase_admin
from firebase_admin import credentials

cred = credentials.Certificate("backend/firebase_admin_credentials.json")
firebase_app = firebase_admin.initialize_app(cred)
