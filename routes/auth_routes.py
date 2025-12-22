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
    role = data.get('role', 'owner')

    if role == 'vet':
        approval_status = False  # Veterinerse onay bekle
    else:
        approval_status = True   # Değilse direkt gir

    if not all([name, email, password, role]):
        return jsonify({"success": False, "message": "Tüm alanları doldurun!"}), 400

    if users.query.filter_by(email=email).first():
        return jsonify({"success": False, "message": "Email zaten kayıtlı!"}), 400

    hashed_password = generate_password_hash(password)
    new_user = users(name=name, email=email, password_hash=hashed_password, role=role, is_approved=approval_status)
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
    
    # YENİ KONTROL: Eğer veterinerse ve onayı yoksa içeri alma!
    if user.role == 'vet' and user.is_approved == False:
        return jsonify({
            "error": "Hesabınız henüz onaylanmadı. Yönetici onayı bekleniyor."
        }), 403


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

@auth_bp.route('/change-password', methods=['POST'])
def change_password():
    """
    Kullanıcının mevcut şifresini doğrulayarak yeni şifre atamasını sağlar.
    Güvenlik Protokolü: Mevcut şifre kontrolü zorunludur.
    """
    data = request.get_json()
    
    # Gerekli alanların varlığının kontrol edilmesi
    user_id = data.get('user_id')
    old_password = data.get('old_password')
    new_password = data.get('new_password')

    # 1. Veri Eksikliği Kontrolü (Validation)
    if not all([user_id, old_password, new_password]):
        return jsonify({
            "success": False, 
            "message": "Eksik bilgi: user_id, old_password ve new_password alanları zorunludur."
        }), 400

    # 2. Kullanıcının Veritabanında Sorgulanması
    user = users.query.get(user_id)
    if not user:
        return jsonify({
            "success": False, 
            "message": "Sistemde belirtilen ID ile eşleşen kullanıcı bulunamadı."
        }), 404

    # 3. Mevcut Şifrenin Doğrulanması (Security Verification)
    # Werkzeug check_password_hash kullanarak güvenli karşılaştırma yapılır.
    if not check_password_hash(user.password_hash, old_password):
        return jsonify({
            "success": False, 
            "message": "Mevcut şifreniz hatalı. Lütfen kontrol ediniz."
        }), 401

    # 4. Yeni Şifrenin Güvenli Hashlenmesi ve Güncellenmesi
    # Güvenlik Notu: Asla düz metin (plain-text) şifre saklanmaz.
    try:
        user.password_hash = generate_password_hash(new_password)
        db.session.commit()
        
        return jsonify({
            "success": True, 
            "message": "Şifreniz başarıyla güncellendi."
        }), 200
        
    except Exception as e:
        # Veritabanı hatalarında rollback yapılması best-practice'dir.
        db.session.rollback()
        return jsonify({
            "success": False, 
            "message": "İşlem sırasında teknik bir hata oluştu.",
            "error": str(e)
        }), 500
