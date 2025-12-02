from flask import Blueprint, request, jsonify
from extensions import db
from models.users import users  # users modelin
from models.clinics import Clinic

clinic_bp = Blueprint('clinics', __name__)

# Tüm klinikleri listele
@clinic_bp.route('/clinics', methods=['GET'])
def get_clinics():
    clinics = Clinic.query.all()
    result = [c.to_dict() for c in clinics]
    return jsonify({"success": True, "clinics": result}), 200


# Belirli bir klinik
@clinic_bp.route('/clinics/<int:clinic_id>', methods=['GET'])
def get_clinic(clinic_id):
    clinic = Clinic.query.get(clinic_id)
    if not clinic:
        return jsonify({"success": False, "message": "Klinik bulunamadı"}), 404
    return jsonify({"success": True, "clinic": clinic.to_dict()}), 200


# Veterinerin kliniklerini listele
@clinic_bp.route('/vets/<int:vet_id>/clinics', methods=['GET'])
def get_vet_clinics(vet_id):
    vet = users.query.filter_by(id=vet_id, role='vet').first()
    if not vet:
        return jsonify({"success": False, "message": "Veteriner bulunamadı"}), 404

    clinics = Clinic.query.filter_by(vet_id=vet.id).all()
    result = [c.to_dict() for c in clinics]
    return jsonify({"success": True, "clinics": result}), 200


# Yeni klinik ekle
@clinic_bp.route('/clinics', methods=['POST'])
def create_clinic():
    data = request.get_json()
    name = data.get('name')
    address = data.get('address')
    phone = data.get('phone')
    working_hours = data.get('working_hours')
    vet_id = data.get('vet_id')

    if not all([name, vet_id]):
        return jsonify({"success": False, "message": "Klinik adı ve veteriner gerekli"}), 400

    clinic = Clinic(
        name=name,
        address=address,
        phone=phone,
        working_hours=working_hours,
        vet_id=vet_id
    )
    db.session.add(clinic)
    db.session.commit()

    return jsonify({"success": True, "clinic": clinic.to_dict()}), 201


# Klinik güncelle
@clinic_bp.route('/clinics/<int:clinic_id>', methods=['PUT'])
def update_clinic(clinic_id):
    clinic = Clinic.query.get(clinic_id)
    if not clinic:
        return jsonify({"success": False, "message": "Klinik bulunamadı"}), 404

    data = request.get_json()
    clinic.name = data.get('name', clinic.name)
    clinic.address = data.get('address', clinic.address)
    clinic.phone = data.get('phone', clinic.phone)
    clinic.working_hours = data.get('working_hours', clinic.working_hours)
    db.session.commit()

    return jsonify({"success": True, "clinic": clinic.to_dict()}), 200


# Klinik sil
@clinic_bp.route('/clinics/<int:clinic_id>', methods=['DELETE'])
def delete_clinic(clinic_id):
    clinic = Clinic.query.get(clinic_id)
    if not clinic:
        return jsonify({"success": False, "message": "Klinik bulunamadı"}), 404

    db.session.delete(clinic)
    db.session.commit()
    return jsonify({"success": True, "message": "Klinik silindi"}), 200
