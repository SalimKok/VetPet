from flask import Blueprint, request, jsonify
from extensions import db
from models.clinics import Clinic
from models.users import users # Veteriner kontrolü için gerekli

clinic_bp = Blueprint('clinics', __name__)

# ---------------------------------------------------------
# 1. TÜM KLİNİKLERİ GETİR
# ---------------------------------------------------------
@clinic_bp.route('/clinics', methods=['GET'])
def get_clinics():
    try:
        clinics = Clinic.query.all()
        # Modeldeki to_dict() metodu il/ilçe isimlerini otomatik doldurur
        result = [c.to_dict() for c in clinics]
        return jsonify({"success": True, "clinics": result}), 200
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

# ---------------------------------------------------------
# 2. TEK BİR KLİNİĞİ GETİR (ID'ye göre)
# ---------------------------------------------------------
@clinic_bp.route('/clinics/<int:clinic_id>', methods=['GET'])
def get_clinic(clinic_id):
    try:
        clinic = Clinic.query.get(clinic_id)
        if not clinic:
            return jsonify({"success": False, "message": "Klinik bulunamadı"}), 404
        
        return jsonify({"success": True, "clinic": clinic.to_dict()}), 200
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

# ---------------------------------------------------------
# 3. BİR VETERİNERE AİT KLİNİKLERİ GETİR
# ---------------------------------------------------------
@clinic_bp.route('/vets/<int:vet_id>/clinics', methods=['GET'])
def get_vet_clinics(vet_id):
    try:
        # Önce veteriner var mı kontrol et
        vet = users.query.filter_by(id=vet_id).first() # role='vet' kontrolü de eklenebilir
        if not vet:
            return jsonify({"success": False, "message": "Veteriner bulunamadı"}), 404

        # O veterinere ait klinikleri bul
        clinics = Clinic.query.filter_by(vet_id=vet_id).all()
        result = [c.to_dict() for c in clinics]
        
        return jsonify({"success": True, "clinics": result}), 200
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

# ---------------------------------------------------------
# 4. YENİ KLİNİK EKLE (POST)
# ---------------------------------------------------------
@clinic_bp.route('/clinics', methods=['POST'])
def create_clinic():
    data = request.get_json()
    name = data.get('name')
    vet_id = data.get('vet_id')
    
    if not all([name, vet_id]):
        return jsonify({"success": False, "message": "Klinik adı ve veteriner ID gerekli"}), 400

    clinic = Clinic(
        name=name,
        vet_id=vet_id,
        phone=data.get('phone'),
        working_hours=data.get('working_hours'),
        
        # Sadece İl ve İlçe
        city_id=data.get('city_id'),
        district_id=data.get('district_id'),
        
        # Adres detayı
        address_details=data.get('address_details') or data.get('address')
    )
    
    try:
        db.session.add(clinic)
        db.session.commit()
        return jsonify({"success": True, "clinic": clinic.to_dict()}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500

# ---------------------------------------------------------
# 5. KLİNİK GÜNCELLE (PUT)
# ---------------------------------------------------------
@clinic_bp.route('/clinics/<int:clinic_id>', methods=['PUT'])
def update_clinic(clinic_id):
    clinic = Clinic.query.get(clinic_id)
    if not clinic:
        return jsonify({"success": False, "message": "Klinik bulunamadı"}), 404

    data = request.get_json()

    clinic.name = data.get('name', clinic.name)
    clinic.phone = data.get('phone', clinic.phone)
    clinic.working_hours = data.get('working_hours', clinic.working_hours)
    
    # Konum güncelleme
    clinic.city_id = data.get('city_id', clinic.city_id)
    clinic.district_id = data.get('district_id', clinic.district_id)
    
    new_address = data.get('address_details') or data.get('address')
    if new_address is not None:
        clinic.address_details = new_address

    try:
        db.session.commit()
        return jsonify({"success": True, "clinic": clinic.to_dict()}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500

# ---------------------------------------------------------
# 6. KLİNİK SİL (DELETE)
# ---------------------------------------------------------
@clinic_bp.route('/clinics/<int:clinic_id>', methods=['DELETE'])
def delete_clinic(clinic_id):
    clinic = Clinic.query.get(clinic_id)
    if not clinic:
        return jsonify({"success": False, "message": "Klinik bulunamadı"}), 404

    try:
        db.session.delete(clinic)
        db.session.commit()
        return jsonify({"success": True, "message": "Klinik silindi"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "message": str(e)}), 500