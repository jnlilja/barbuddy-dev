from firebase_admin import auth as firebase_auth
from django.http import JsonResponse
import json

def verify_firebase_token(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        token = data.get('idToken')
        if not token:
            return JsonResponse({"error": "No token provided."}, status=400)

        try:
            decoded = firebase_auth.verify_id_token(token)
            uid = decoded['uid']
            # lookup/create user in your DB, etc.
            return JsonResponse({"status": "success", "uid": uid})
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=401)
    return JsonResponse({"error": "Invalid request."}, status=400)
