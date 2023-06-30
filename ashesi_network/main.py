import json
import os
import uuid
from flask_cors import CORS
from flask import Flask, request, jsonify
from datetime import datetime, timedelta
import firebase_admin
import functions_framework
from firebase_admin import credentials, firestore, storage
from flask_mail import Mail, Message
import re

# Loading the authentication credentials for the Firebase Admin SDK from the 'social-network-key.json' file
cred = credentials.Certificate("social-network-key.json")
# Initializing the Firebase Admin SDK using the credentials stored in the 'cred' variable
firebase_admin.initialize_app(cred, {
    'storageBucket': 'social-network-fef8c.appspot.com'
})


# Creating an instance of the storage bucket
bucket = storage.bucket()

# Creating a db object to interact with the Firebase database
db = firestore.client()

# Initialize Flask app
social_network = Flask(__name__)
CORS(social_network)

@functions_framework.http
def server(request):
    if request.method == 'GET' and request.path == '/user_profiles':
        return view_profile()
    elif request.method == 'POST' and request.path == '/create_profile':
        return create_profile()
    elif request.method == 'PATCH' and request.path == '/user_profiles/edit':
        return edit_profile()
    elif request.method == 'POST' and request.path == '/login':
        return login()
    elif request.method == 'POST' and request.path == '/post':
        return create_post()
    elif request.method == 'GET' and request.path == '/feed':
        return view_feed()
    else:
        return jsonify('Invalid request')



######################## Creating a user profile page ########################

def create_profile():
    required_fields = ['StudentID', 'name', 'email', 'dob', 'major', 'residence', 'best_food', 'best_movie']
    record = json.loads(request.data)
    
    for field in required_fields:
        if field not in record:
            return jsonify({'error': f'Missing required parameter {field}'}), 400 # Bad Request
        # Validate major and name
        if not isinstance(record[field], str):
            return jsonify({'error': f'The value of {field} must be a string'}), 400 # Bad Request
        
    # Check if Year group is present, else create it
    if 'year_group' in record:
            year_group = record['year_group']
    else:
        # Getting the last 4 digits of the student ID as the year group
        year_group = record['StudentID'][-4:] 


    # Validate student ID by ensuring that the total length of the studentID is 8 digits long
    if not re.match(r'^\d{8}$', record['StudentID']):
        return jsonify({'error': 'Invalid student ID format. Please use 8 digits.'}), 400
    elif int(record['StudentID'][-4:]) < 2002:
        return jsonify({'error': 'Invalid year in student ID. Please use a year from 2002 going.'}), 400

    # Validate email
    if not (record['email'].endswith('@ashesi.edu.gh') or record['email'].endswith('@gmail.com')):
        return jsonify({'error': 'Invalid ashesi email or gmail address'}), 400

    # Validate residence
    if record['residence'] not in ['On-Campus', 'Off-Campus']:
        return jsonify({'error': 'Invalid residence format. Please state either on-campus or off-campus.'}), 400

    # Validate date of birth
    try:
        dob = datetime.strptime(record['dob'], '%Y-%m-%d').date()
        if dob >= datetime.now().date():
            return jsonify({'error': 'Date of birth cannot be today or in the future!'}), 400
    except ValueError:
        return jsonify({'error': 'Invalid date of birth format. Please use YYYY-MM-DD.'}), 400
    
    # Check if profile already exists in database
    query = db.collection('user_profiles').where('StudentID', '==', record['StudentID'])
    existing_records = query.stream()

    # Check if a record with the same StudentID already exists in the database
    if len(list(existing_records)) > 0:
        return jsonify({'error': 'Profile already exists.'}), 400

    # Add Year group to the record
    record['year_group'] = year_group

    # Save the record to the database
    db.collection('user_profiles').add(record)

    return jsonify({'success': 'Profile created successfully.'}, record), 201



######################## LOGIN ########################
def login():
    request_body = json.loads(request.data)
    required_fields = ['StudentID', 'email']
    for field in request_body:
        if field not in required_fields:
            return jsonify({'error':'Only studentID and email are needed to login'}), 400
    
    # Check if a user with the provided StudentID exists in the database
    user_query = db.collection('user_profiles').where('StudentID', '==', request_body['StudentID'])
    user_docs = user_query.stream()
    if not user_docs:
        return jsonify({'error':'Account with such details not found'}), 404
    
    # Check if the email associated with the provided StudentID matches the provided email
    for doc in user_docs:
        if doc.to_dict()['email'] == request_body['email']:
            return jsonify({'success':'You have been logged in successfully'}), 200
    
    return jsonify({'error':'Account with such details not found'}), 404


######################## EDIT PROFILE ########################
def edit_profile():
    student_id = request.args.get("StudentID")
    print(student_id)
    profile_ref = db.collection('user_profiles')
    query = profile_ref.where('StudentID', '==', str(student_id)).get()
    if not query:
        return jsonify({'error': 'Student Id Not Found'}), 404 # Not Found
    else:
        for doc in query:
            existing_record = doc.to_dict()
            
            # Update text fields
            for key, value in request.form.items():
                if key in ['name', 'StudentID', 'email']:
                    return jsonify({'error': f'Sorry, not allowed to update your {key}!'}),400
                existing_record[key] = value
                
            # Update profile image
            if 'profile_image' in request.files:
                file = request.files['profile_image']
                filename = str(student_id)
                blob = bucket.blob(f'profile_images/{filename}')
                blob.upload_from_string(file.read(), content_type=file.content_type)
                existing_record['profile_image'] = blob.public_url
            doc.reference.set(existing_record)
            
        return jsonify({'message': 'Profile edited successfully', 'updated_profile': existing_record}), 200




######################## VIEWING PROFILE ########################
def view_profile():
    student_id = request.args.get('StudentID')
    email = request.args.get('email')
    if not student_id and not email:
        return jsonify({'error': 'Please provide either a student ID or an email address'}), 400
    profile_ref = db.collection('user_profiles')
    if student_id:
        query = profile_ref.where('StudentID', '==', str(student_id)).get()
    else:
        query = profile_ref.where('email', '==', str(email)).get()
    if not query:
        return jsonify({'error': 'Profile does not exist'}), 404
    else:
        return jsonify(query[0].to_dict())



######################## CREATE POST ########################

def create_post():
    # initialise Flask-Mail
    social_network.config['MAIL_SERVER'] = 'smtp.gmail.com'
    social_network.config['MAIL_PORT'] = 465
    social_network.config['MAIL_USERNAME'] = 'thomasquarshie36@gmail.com'
    social_network.config['MAIL_PASSWORD'] = 'adzsoccsswzhhdyp' # oyxgopdpdzuuzojh
    social_network.config['MAIL_USE_SSL'] = True
    mail = Mail(social_network)
    required_fields = ['email', 'message']
    
    request_body = json.loads(request.data)
    email = request_body.get("email")
    for field in required_fields:
        if field not in request_body:
            return jsonify({'error':f'Missing required field {field}'}), 400 # Bad Request
        
    if not (email.endswith('@ashesi.edu.gh') or email.endswith('@gmail.com')):
        return jsonify({'error': 'Invalid ashesi email or gmail'}), 400
    
    # Check if the email exists in the user_profiles collection
    user_profile = db.collection('user_profiles').where('email', '==', email).get()
    if not user_profile:
        return jsonify({'error': 'Email does not exist in the user_profiles collection.'}), 404
    
    # Retrieve the user who made the post
    for doc in user_profile:
        user_data = doc.to_dict()
        user_name = user_data.get('name')
        break

    request_body['username'] = user_name
    request_body['Date_posted'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # Retrieve all user emails
    user_profiles_ref = db.collection('user_profiles')
    recipients = []
    for doc in user_profiles_ref.stream():
        data = doc.to_dict()
        if 'email' in data:
            email = data['email']
            recipients.append(email)

    # Save the post to the database
    db.collection('posts').add(request_body)

    # Send email to all users
    message = Message(
        "New post from " + user_name, 
        sender="p.o.s.t.it438@gmail.com",
        recipients=recipients
    )
    message.body = user_name + " has made a new post on POST IT!\n"
    message.body += "Post content: " + request_body["message"] + "\n"
    message.body += "Date created: " + request_body["Date_posted"] + "\n\n"
    message.body += "Regards, \n Ashesi Social Team."
    return jsonify({'message':"Post and email sent successfully"}), 201



######################## FEED ########################
def view_feed():
    # Creating a reference to the posts collection
    post_ref = db.collection('posts')
    # Obtaining the argument passed for the email parameter
    email_args = request.args.get("email")
    # Obtaining the argument passed for the message parameter
    message_args = request.args.get('message')
    email_filter = []
    # If an email is provided but doesn't follow the Ashesi or Gmail format, return an error
    if email_args:
        if not((email_args.endswith('@ashesi.edu.gh') or email_args.endswith('@gmail.com'))):
            return jsonify({'error': 'Invalid Ashesi or Gmail address'}), 400
    # If an email argument is provided, filter the posts linked to that email
    if email_args:
        email_query = post_ref.where('email', '==', email_args).get()
        if not email_query:
            return jsonify({'error': f'The email address {email_args} does not exist'}), 404
        # If a message argument is also provided, filter the posts containing that message
        if message_args:
            for doc in email_query:
                if message_args in doc.to_dict().get('message'):
                    email_filter.append(doc.to_dict())
            if not email_filter:
                return jsonify({'message': f"No posts found for {email_args} containing '{message_args}'"}), 404
            # Sort the results using the timestamp in descending order of time
            result = sorted(email_filter, key=lambda x: x["Date_posted"], reverse=True)
            return jsonify(result)
        else:
            for doc in email_query:
                email_filter.append(doc.to_dict())
            result = sorted(email_filter, key=lambda x: x["Date_posted"], reverse=True)
            return jsonify(result)
    # If only the message argument is provided, filter the posts containing that message
    elif message_args:
        for doc in post_ref.stream():
            if message_args in doc.to_dict().get('message'):
                email_filter.append(doc.to_dict())
        if not email_filter:
            return jsonify({'message': f"No posts found containing '{message_args}'"}), 404
        # Sort the results using the timestamp in descending order of time
        result = sorted(email_filter, key=lambda x: x["Date_posted"], reverse=True)
        return jsonify(result)
    # If neither of the email or message arguments are provided, then display all posts in the database
    else:
        query = post_ref.stream()
        posts = []
        for doc in query:
            posts.append(doc.to_dict())
        result = sorted(posts, key=lambda x: x["Date_posted"], reverse=True)
        return jsonify(result)


###################### EDIT POST ###############################
@social_network.route('/post/edit_post', methods=['PATCH'])
def edit_post():
    email_arg = request.args.get('email')
    date_arg = request.args.get('date')
    profile_ref = db.collection('posts')
    if not email_arg or not date_arg:
        return jsonify({'error': 'Both email and date arguments need to be provided as query strings'}), 400
    # Validate the date provided as argument
    try:
        date_obj = datetime.strptime(date_arg, '%Y-%m-%d')
    except ValueError:
        return jsonify({'error': 'The date must be in the format yyyy-mm-dd'}), 400
    
    # Modify the date string to match the format in the database
    date_str = str(date_obj.strftime('%Y-%m-%d %H:%M:%S'))
    
    # Perform the query
    query = profile_ref.where('email', '==', str(email_arg)).where('Date_posted', '>=', date_str[:10]).where('Date_posted', '<', str(date_obj.date() + timedelta(days=1)))

    if not query:
        return jsonify({'error': f'No post found with the email address {email_arg} and date posted {date_arg}'}), 404 # Not Found
    else:
        for doc in query.get():
            existing_record = doc.to_dict()
            for key, value in request.json.items():
                # Disallow updating of email and date posted
                if key == 'email' or key == 'Date_posted':
                    return({'error': 'Sorry, not allowed to update the email address or date posted!'}),400
                else:
                    existing_record[key] = value
            doc.reference.set(existing_record)
            existing_record['last_update'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            return jsonify({'message': 'Post edited successfully'}, existing_record), 200 # Status code for update


    
if __name__ == '__main__':
    social_network.run()
