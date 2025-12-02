from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from extensions import db
from models.users import users

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    role = data.get('role')

    if not all([name, email, password, role]):
        return jsonify({"success": False, "message": "Tüm alanları doldurun!"}), 400

    if users.query.filter_by(email=email).first():
        return jsonify({"success": False, "message": "Email zaten kayıtlı!"}), 400

    hashed_password = generate_password_hash(password)
    new_user = users(name=name, email=email, password_hash=hashed_password, role=role)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"success": True, "message": f"{role} başarıyla kayıt oldu!"})


@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not all([email, password]):
        return jsonify({"success": False, "message": "Email ve şifre gerekli!"}), 400

    user = users.query.filter_by(email=email).first()
    if not user:
        return jsonify({"success": False, "message": "Kullanıcı bulunamadı!"}), 404

    if not check_password_hash(user.password_hash, password):
        return jsonify({"success": False, "message": "Şifre hatalı!"}), 401

    return jsonify({
        "success": True,
        "message": f"{user.role} olarak giriş başarılı!",
        "role": user.role,
        "user": {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "role": user.role
        }
    }), 200
