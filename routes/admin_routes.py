from flask import Blueprint, jsonify
from models.pets import Pets
from models.users import users
from models.appointments import Appointments
from extensions import db
from sqlalchemy.orm import aliased

admin_bp = Blueprint('admin', __name__)

@admin_bp.route('/admin/stats', methods=['GET'])
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

@admin_bp.route('/admin/users', methods=['GET'])
def get_all_users():
    try:
        print("1. Admin: Kullanıcılar isteniyor...") # Debug
        
        # DÜZELTME 1: Çekilen veriyi 'all_users' değişkenine atıyoruz.
        # Böylece 'users' model ismiyle çakışmıyor.
        all_users = users.query.filter(users.role != 'admin').all()
        
        print(f"2. Bulunan kullanıcı sayısı: {len(all_users)}") # Debug
        
        users_list = []
        for user in all_users:
            # DÜZELTME 2: 'full_name' veritabanında var mı?
            # Yoksa hata verir. Eğer modelinde 'name' ise burayı değiştir.
            users_list.append({
                'id': user.id,
                'email': user.email,
                'name': getattr(user, 'name', 'Bilinmiyor'), # Hata vermesin diye koruma
                'role': user.role,
                'is_active': True 
            })
            
        return jsonify(users_list), 200

    except Exception as e:
        # Hata mesajını terminale kıpkırmızı basalım ki görelim
        print(f"!!! ADMIN USERS HATASI !!!: {e}") 
        return jsonify({'error': str(e)}), 500

@admin_bp.route('/admin/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    """
    Belirtilen ID'ye sahip kullanıcıyı siler.
    """
    try:
        user = users.query.get(user_id)
        if not user:
            return jsonify({'message': 'Kullanıcı bulunamadı'}), 404
            
        db.session.delete(user)
        db.session.commit()
        return jsonify({'message': 'Kullanıcı başarıyla silindi'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# 1. Bekleyen Veterinerleri Listele
@admin_bp.route('/approve/vets', methods=['GET'])
def get_pending_vets():
    try:
        # Sadece Veteriner OLAN ve Onay durumu FALSE (0) olanları çek
        pending_vets = users.query.filter_by(role='vet', is_approved=False).all()
        
        vets_list = []
        for vet in pending_vets:
            vets_list.append({
                'id': vet.id,
                'name': getattr(vet, 'name', 'İsimsiz'), # Modelindeki isme göre (name/full_name)
                'email': vet.email
            })
        return jsonify(vets_list), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# 2. Veterineri Onayla (Aktif Et)
@admin_bp.route('/approve/vets/<int:vet_id>', methods=['POST'])
def approve_vet(vet_id):
    try:
        vet = users.query.get(vet_id)
        if not vet:
            return jsonify({'message': 'Kullanıcı bulunamadı'}), 404
            
        vet.is_approved = True # ONAYLANDI!
        db.session.commit()
        
        return jsonify({'message': 'Veteriner hesabı onaylandı.'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
    
# --- YENİ: TÜM RANDEVULARI LİSTELE ---
@admin_bp.route('/admin/appointments', methods=['GET'])
def get_all_appointments_admin():
    try:
        # 1. 'users' tablosu için iki farklı takma ad (alias) oluşturuyoruz
        Vet = aliased(users, name="vet_user")
        Owner = aliased(users, name="owner_user")

        # 2. Sorguyu bu takma adlar üzerinden kuruyoruz
        results = db.session.query(
            Appointments, 
            Vet.name.label('vet_name'),
            Pets.name.label('pet_name'),
            Owner.name.label('owner_name')
        ).join(Vet, Appointments.vet_id == Vet.id) \
         .join(Pets, Appointments.pet_id == Pets.id) \
         .join(Owner, Pets.owner_id == Owner.id) \
         .order_by(Appointments.date.desc()) \
         .all()

        appointments_list = []
        for appo, vet_name, pet_name, owner_name in results:
            appointments_list.append({
                'id': appo.id,
                'date': appo.date.isoformat() if appo.date else None,
                'status': appo.status,
                'reason': appo.reason,
                'pet_name': pet_name,
                'vet_name': vet_name,
                'owner_name': owner_name
            })

        return jsonify(appointments_list), 200

    except Exception as e:
        print(f"!!! ADMIN APPOINTMENTS HATASI !!!: {e}")
        return jsonify({'error': str(e)}), 500

# --- YENİ: RANDEVU DURUMUNU GÜNCELLE ---
from flask import request # request import edilmemişse en üste ekle

@admin_bp.route('/admin/appointments/<int:appo_id>', methods=['PUT'])
def update_appointment_status_admin(appo_id):
    try:
        data = request.get_json()
        new_status = data.get('status') # 'approved', 'rejected' vb.

        appointment = Appointments.query.get(appo_id)
        if not appointment:
            return jsonify({'message': 'Randevu bulunamadı'}), 404

        appointment.status = new_status
        db.session.commit()

        return jsonify({'message': f'Randevu durumu {new_status} olarak güncellendi.'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
    
# --- YENİ: RANDEVUYU SİSTEMDEN TAMAMEN SİL ---
@admin_bp.route('/admin/appointments/<int:appo_id>', methods=['DELETE'])
def delete_appointment_admin(appo_id):
    """
    Admin yetkisiyle bir randevuyu veritabanından tamamen siler.
    """
    try:
        # 1. Silinecek randevuyu bul
        appointment = Appointments.query.get(appo_id)
        
        if not appointment:
            return jsonify({'message': 'Randevu bulunamadı'}), 404

        # 2. Silme işlemini gerçekleştir
        db.session.delete(appointment)
        db.session.commit()

        print(f"--- ADMIN: {appo_id} ID'li randevu silindi ---") # Debug log
        return jsonify({'success': True, 'message': 'Randevu başarıyla sistemden silindi'}), 200

    except Exception as e:
        # Bir hata olursa işlemi geri al
        db.session.rollback()
        print(f"!!! ADMIN APPOINTMENT DELETE HATASI !!!: {e}")
        return jsonify({'error': str(e)}), 500
    
