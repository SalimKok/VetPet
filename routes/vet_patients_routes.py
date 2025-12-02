from flask import Blueprint, request, jsonify
from extensions import db
from models.users import users, vet_patients  # User modelini çağırıyoruz
from models.pets import Pets   # Pets modelini çağırıyoruz

# Blueprint tanımı
vet_patients_bp = Blueprint('vet', __name__, url_prefix='/api/vet')

# ---------------------------------------------------
# 1. SİSTEMDEKİ TÜM HAYVANLARI GETİR (KEŞFET EKRANI İÇİN)
# ---------------------------------------------------
@vet_patients_bp.route('/all-pets', methods=['GET'])
def get_all_pets():
    try:
        # Sadece pets tablosunu çekiyoruz, ilişkilere (owner) hiç dokunmuyoruz.
        all_pets = Pets.query.all()
        
        results = []
        for p in all_pets: # veya 'in my_list'
            
            # Sahibinin ismini güvenli şekilde alalım
            owner_display = "Bilinmiyor"
            if p.owner: # Modeldeki ilişki sayesinde burası çalışır
                owner_display = p.owner.name

            results.append({
                'id': p.id,
                'name': p.name,
                'species': p.species,
                'breed': p.breed,
                
                # ARTIK BURAYA GERÇEK İSMİ YAZABİLİRİZ:
                'owner_name': owner_display, 
                
                'photo_url': p.photo_url
            })

        return jsonify(results), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ---------------------------------------------------
# 2. SEÇİLEN HAYVANI VETERİNERİN LİSTESİNE EKLE
# ---------------------------------------------------
@vet_patients_bp.route('/add-patient', methods=['POST'])
def add_patient_to_vet():
    data = request.get_json()
    
    vet_id = data.get('vet_id')  # Şu anki Veterinerin ID'si
    pet_id = data.get('pet_id')  # Eklemek istediği Hayvanın ID'si

    if not vet_id or not pet_id:
        return jsonify({'error': 'vet_id ve pet_id zorunludur.'}), 400

    try:
        # Veterineri ve Hayvanı bul
        vet = users.query.get(vet_id)
        pet = Pets.query.get(pet_id)

        if not vet:
            return jsonify({'error': 'Veteriner bulunamadı.'}), 404
        if not pet:
            return jsonify({'error': 'Hayvan bulunamadı.'}), 404

        # Zaten ekli mi kontrol et?
        # lazy='dynamic' kullandığımız için .all() dememiz gerekebilir veya sorgu atabiliriz
        # Basit kontrol:
        existing_check = db.session.query(vet_patients).filter_by(user_id=vet_id, pet_id=pet_id).first()
        
        if existing_check:
             return jsonify({'message': 'Bu hayvan zaten listenizde ekli.'}), 200

        # Ekleme işlemi (SQLAlchemy listeye append yapınca ara tabloyu doldurur)
        vet.my_patients.append(pet)
        db.session.commit()

        return jsonify({'message': f'{pet.name} başarıyla listenize eklendi.'}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


# ---------------------------------------------------
# 3. VETERİNERİN KENDİ HASTA LİSTESİNİ GETİR
# ---------------------------------------------------
@vet_patients_bp.route('/my-patients/<int:vet_id>', methods=['GET'])
def get_my_patients(vet_id):
    try:
        vet = users.query.get_or_404(vet_id)
        
        # İlişki üzerinden hastaları çekiyoruz
        # lazy='dynamic' olduğu için .all() kullanıyoruz
        my_list = vet.my_patients.all() 

        results = []
        for p in my_list: # veya 'in my_list'
            
            # Sahibinin ismini güvenli şekilde alalım
            owner_display = "Bilinmiyor"
            if p.owner: # Modeldeki ilişki sayesinde burası çalışır
                owner_display = p.owner.name

            results.append({
                'id': p.id,
                'name': p.name,
                'species': p.species,
                'breed': p.breed,
                
                # ARTIK BURAYA GERÇEK İSMİ YAZABİLİRİZ:
                'owner_name': owner_display, 
                
                'photo_url': p.photo_url
            })

        return jsonify(results), 200

    except Exception as e:
        print(f"HATA OLUŞTU: {e}") # Konsola hatayı basar
        return jsonify({'error': str(e)}), 500