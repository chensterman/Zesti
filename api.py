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

@app.route('/swipe-list', methods=['GET'])
def swipe_list(): 
    """
        read() : Fetches documents from Firestore collection as JSON.
        todo : Return document that matches query ID.
        all_todos : Return all documents.
    """
    uid = request.args['uid']
    print('uid: ' + uid)

    try:
        user_data = users_coll.document(uid).get()
        user_data = user_data.to_dict()
        '''
        op = interest = None
        if user_data['dating-interest'] == 'everyone':
            op = 'in'
            interest = ['woman', 'man']
        else:
            op = '=='
            interest = user_data['dating-interest']
        likers = db.collection_group('matched') \
            .where('uid', '!=', uid) \
            .where('identity', op, interest) \
            .where('interest', '==', user_data['dating-identity']).get()
        print(likers)
        '''
        return jsonify(user_data), 200
    except Exception as e:
        return f"An Error Occured: {e}"

@app.route('/match-check', methods=['GET'])
def match_check(): 
    """
        read() : Fetches documents from Firestore collection as JSON.
        todo : Return document that matches query ID.
        all_todos : Return all documents.
    """
    meid = request.args['meid']
    youid = request.args['youid']

    print('meid: ' + meid)
    print('youid: ' + youid)

    try:
        me = users_coll.document(youid).collection('liked').where('user', '==', meid).get()
        if len(me) == 0:
            return jsonify({'match' : False})
        else:
            return jsonify({'match' : True})
    except Exception as e:
        return f"An Error Occured: {e}"

@app.route('/user-info', methods=['GET'])
def user_info(): 
    """
        read() : Fetches documents from Firestore collection as JSON.
        todo : Return document that matches query ID.
        all_todos : Return all documents.
    """
    uid = request.args['uid']
    print('uid: ' + uid)

    try:
        user_data = users_coll.document(uid).get()
        return jsonify(user_data.to_dict())
    except Exception as e:
        return f"An Error Occured: {e}"

@app.route('/matches', methods=['GET'])
def matches(): 
    """
        read() : Fetches documents from Firestore collection as JSON.
        todo : Return document that matches query ID.
        all_todos : Return all documents.
    """
    uid = request.args['uid']
    print('uid: ' + uid)

    try:
        matches = users_coll.document(uid).collection('matched').order_by('timestamp').get()
        print(matches)
        return jsonify({'matches' : matches})
    except Exception as e:
        return f"An Error Occured: {e}"

port = int(os.environ.get('PORT', 8080))
if __name__ == '__main__':
    app.run(debug=True, threaded=True, host='0.0.0.0', port=port)