from flask import Blueprint, request, jsonify
from extensions import db
from models.appointments import Appointments
from datetime import datetime
from models.pets import Pets

appointments_bp = Blueprint('appointments', __name__)

# -----------------------------
# 1) Yeni randevu oluştur
# -----------------------------
@appointments_bp.route('/appointments', methods=['POST'])
def create_appointment():
    data = request.get_json()
    pet_id = data.get('pet_id')
    owner_id = data.get('owner_id')
    vet_id = data.get('vet_id')
    date = data.get('date')  # örn: "2025-11-05T14:30:00"
    reason = data.get('reason', '')

    if not all([pet_id, owner_id, vet_id, date]):
        return jsonify({"success": False, "message": "Tüm alanlar gerekli!"}), 400

    try:
        dt = datetime.fromisoformat(date)
    except ValueError:
        return jsonify({"success": False, "message": "Geçersiz tarih formatı!"}), 400

    appointment = Appointments(
        pet_id=pet_id,
        owner_id=owner_id,
        vet_id=vet_id,
        date=dt,
        reason=reason,
        status="pending"  # varsayılan durum
    )
    db.session.add(appointment)
    db.session.commit()
    return jsonify({"success": True, "message": "Randevu oluşturuldu!"}), 201


# -----------------------------
# 2) Veterinerin randevularını listele
# -----------------------------
@appointments_bp.route('/appointments/vet/<int:vet_id>', methods=['GET'])
def get_vet_appointments(vet_id):
    appointments = Appointments.query.filter_by(vet_id=vet_id).all()
    result = [
        {
            "id": a.id,
            "pet_id": a.pet_id,
            "pet_name": a.pet.name if a.pet else "Bilinmiyor",
            "owner_id": a.owner_id,
            "vet_id": a.vet_id,
            "date": a.date.isoformat(),
            "reason": a.reason,
            "status": a.status
        } for a in appointments
    ]
    return jsonify({"success": True, "appointments": result}), 200


# -----------------------------
# 3) Sahip randevularını listele
# -----------------------------
@appointments_bp.route('/appointments/owner/<int:owner_id>', methods=['GET'])
def get_owner_appointments(owner_id):
    appointments = Appointments.query.filter_by(owner_id=owner_id).all()
    result = [
        {
            "id": a.id,
            "pet_id": a.pet_id,
            "pet_name": a.pet.name if a.pet else "Bilinmiyor",
            "owner_id": a.owner_id,
            "vet_id": a.vet_id,
            "date": a.date.isoformat(),
            "reason": a.reason,
            "status": a.status
        } for a in appointments
    ]
    return jsonify({"success": True, "appointments": result}), 200


# -----------------------------
# 4) Randevuyu güncelle (pet_id, vet_id, date, reason)
# -----------------------------
@appointments_bp.route('/appointments/<int:appointment_id>', methods=['PUT'])
def update_appointment(appointment_id):
    data = request.get_json()
    appointment = Appointments.query.get(appointment_id)

    if not appointment:
        return jsonify({"success": False, "message": "Randevu bulunamadı!"}), 404

    # Genel alanlar (UI'dan gelen güncellemeler)
    pet_id = data.get('pet_id')
    vet_id = data.get('vet_id')
    date = data.get('date')
    reason = data.get('reason')
    status = data.get('status')  # örneğin: approved, cancelled, done

    if pet_id:
        appointment.pet_id = pet_id
    if vet_id:
        appointment.vet_id = vet_id
    if reason is not None:
        appointment.reason = reason
    if date:
        try:
            appointment.date = datetime.fromisoformat(date)
        except ValueError:
            return jsonify({"success": False, "message": "Geçersiz tarih formatı!"}), 400
    if status:
        appointment.status = status

    db.session.commit()
    return jsonify({"success": True, "message": "Randevu güncellendi!"}), 200

# -----------------------------
# 5) Randevu durumunu güncelle 
# -----------------------------
@appointments_bp.route('/appointments/<int:appointment_id>/status', methods=['PATCH'])
def update_appointment_status(appointment_id):
    data = request.json
    new_status = data.get('status')  # "approved", "rejected", vb.

    appointment = Appointments.query.get(appointment_id)
    if not appointment:
        return jsonify({"success": False, "message": "Randevu bulunamadı"}), 404

    if new_status not in ['approved', 'rejected', 'pending',"completed"]:
        return jsonify({"success": False, "message": "Geçersiz durum"}), 400

    appointment.status = new_status
    db.session.commit()

    return jsonify({"success": True, "message": "Randevu durumu güncellendi"}), 200

# -----------------------------
# 6) Randevu sil (iptal)
# -----------------------------
@appointments_bp.route('/appointments/<int:appointment_id>', methods=['DELETE'])
def delete_appointment(appointment_id):
    appointment = Appointments.query.get(appointment_id)

    if not appointment:
        return jsonify({"success": False, "message": "Randevu bulunamadı!"}), 404

    db.session.delete(appointment)
    db.session.commit()
    return jsonify({"success": True, "message": "Randevu iptal edildi!"}), 200

# -----------------------------
# 7) Veteriner tarafından randevu/aşı oluştur (OTOMATİK ONAYLI)
# -----------------------------
@appointments_bp.route('/appointments/create-by-vet', methods=['POST'])
def create_appointment_by_vet():
    data = request.get_json()
    
    vet_id = data.get('vet_id')
    pet_id = data.get('pet_id')
    date = data.get('date')  # örn: "2025-11-05T14:30:00"
    reason = data.get('reason', '') # Örn: "Karma Aşı 1. Doz"

    if not all([vet_id, pet_id, date]):
        return jsonify({"success": False, "message": "Vet ID, Pet ID ve Tarih zorunludur!"}), 400

    try:
        dt = datetime.fromisoformat(date)
    except ValueError:
        return jsonify({"success": False, "message": "Geçersiz tarih formatı!"}), 400

    # 1. Adım: Pet üzerinden Owner'ı buluyoruz
    pet = Pets.query.get(pet_id)
    if not pet:
        return jsonify({"success": False, "message": "Seçilen hayvan bulunamadı!"}), 404
    
    owner_id = pet.owner_id  # Hayvanın sahibini otomatik alıyoruz

    # 2. Adım: Randevuyu 'confirmed' (onaylı) olarak oluşturuyoruz
    appointment = Appointments(
        pet_id=pet_id,
        owner_id=owner_id,
        vet_id=vet_id,
        date=dt,
        reason=reason,
        status="approved"  # <--- KRİTİK NOKTA: Veteriner oluşturduğu için direkt onaylı
    )
    
    db.session.add(appointment)
    db.session.commit()
    
    return jsonify({"success": True, "message": "Randevu/Aşı takvimi başarıyla oluşturuldu!"}), 201