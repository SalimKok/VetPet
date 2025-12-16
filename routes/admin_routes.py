from flask import Blueprint, jsonify
from models.users import users
from models.appointments import Appointments

admin_bp = Blueprint('admin', __name__)

@admin_bp.route('/stats', methods=['GET'])
def get_stats():
    # 1. Veritabanından sayıları çekiyoruz
    total_users = users.query.count()
    total_vets = users.query.filter_by(role='vet').count()
    total_owners = users.query.filter_by(role='owner').count()
    total_appointments = Appointments.query.count()

    return jsonify({
        "success": True,
        "total_users": total_users,
        "total_vets": total_vets,
        "total_owners": total_owners,
        "total_appointments": total_appointments
    }), 200