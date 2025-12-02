from flask import Blueprint, jsonify
from extensions import db
from models.users import users  # users modelin

vet_bp = Blueprint('vets', __name__)

# Tüm veterinerleri getir
@vet_bp.route('/vets', methods=['GET'])
def get_vets():
    vets = users.query.filter_by(role='vet').all()
    result = [
        {
            "id": v.id,
            "name": v.name,
            "email": v.email
        } for v in vets
    ]
    return jsonify({"success": True, "vets": result}), 200


# Belirli bir veteriner
@vet_bp.route('/vets/<int:vet_id>', methods=['GET'])
def get_vet(vet_id):
    vet = users.query.filter_by(id=vet_id, role='vet').first()
    if not vet:
        return jsonify({"success": False, "message": "Veteriner bulunamadı"}), 404

    return jsonify({
        "success": True,
        "vet": {
            "id": vet.id,
            "name": vet.name,
            "email": vet.email
        }
    }), 200
