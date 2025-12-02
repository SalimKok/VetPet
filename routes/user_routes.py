from flask import Blueprint, jsonify, request
from extensions import db
from models.users import users
import os
from werkzeug.utils import secure_filename

user_bp = Blueprint('users', __name__)

UPLOAD_FOLDER = 'uploads/profile_photos'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@user_bp.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    user = users.query.get(user_id)
    if not user:
        return jsonify({"success": False, "message": "Kullanıcı bulunamadı"}), 404

    user_data = {
        "id": user.id,
        "name": user.name,
        "email": user.email,
        "phone": getattr(user, 'phone', ''),
        "role": user.role,
        "photo_url": user.photo_url,
        "joined": user.created_at.strftime("%Y-%m-%d")
    }

    return jsonify({"success": True, "user": user_data}), 200


@user_bp.route('/users/<int:user_id>', methods=['POST'])
def update_user(user_id):
    user = users.query.get(user_id)
    if not user:
        return jsonify({"success": False, "message": "Kullanıcı bulunamadı"}), 404

    # Text alanlarını al
    name = request.form.get('name')
    email = request.form.get('email')
    phone = request.form.get('phone')

    if name:
        user.name = name
    if email:
        user.email = email
    if phone:
        user.phone = phone

    # Fotoğraf yüklemesi
    if 'photo' in request.files:
        file = request.files['photo']
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            filepath = os.path.join(UPLOAD_FOLDER, filename)
            file.save(filepath)
            user.photo_url = f"/{UPLOAD_FOLDER}/{filename}"

    db.session.commit()

    return jsonify({
        "success": True,
        "user": {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "phone": getattr(user, 'phone', ''),
            "photo_url": user.photo_url,
            "joined": user.created_at.strftime("%Y-%m-%d")
        }
    }), 200
