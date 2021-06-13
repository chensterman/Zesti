# Required imports
import os
from flask import Flask, request, jsonify
from firebase_admin import credentials, firestore, initialize_app

# Initialize Flask app
app = Flask(__name__)

# Initialize Firestore DB
cred = credentials.Certificate('zesti-4b3e6-firebase-adminsdk-2sac9-edc52eac83.json')
default_app = initialize_app(cred)
db = firestore.client()
users_coll = db.collection('users')

@app.route('/list', methods=['GET'])
def read(): 
    """
        read() : Fetches documents from Firestore collection as JSON.
        todo : Return document that matches query ID.
        all_todos : Return all documents.
    """
    try:
        # Check if ID was passed to URL query
        print('run')
        user = users_coll.document('ikWfhZK3heO4vM6OGkdRzcoaqWA2').get()
        print(user.to_dict())
        return jsonify(user.to_dict()), 200
    except Exception as e:
        return f"An Error Occured: {e}"

port = int(os.environ.get('PORT', 8080))
if __name__ == '__main__':
    app.run(debug=True, threaded=True, host='0.0.0.0', port=port)