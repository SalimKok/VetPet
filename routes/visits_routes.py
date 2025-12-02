from flask import Blueprint, request, jsonify
from extensions import db
from datetime import datetime
from models.MedicalVisit import MedicalVisit
from models.MedicalProcedure import MedicalProcedure
from models.pets import Pets  
from models.users import users

# Blueprint oluşturuyoruz (URL ön eki: /api/visits)
visits_bp = Blueprint('visits', __name__, url_prefix='/api/visits')

# --- 1. YENİ MUAYENE VE İŞLEM EKLEME (TRANSACTION) ---
@visits_bp.route('/', methods=['POST'])
def create_visit():
    data = request.get_json()

    try:
        # 1. Gelen verileri al
        pet_id = data.get('pet_id')
        vet_id = data.get('vet_id') # Bu ID'nin User tablosunda VETERİNER olup olmadığını kontrol edebilirsin
        diagnosis = data.get('diagnosis')
        notes = data.get('notes')
        procedures_data = data.get('procedures', []) # Liste olarak gelecek

        if not all([pet_id, vet_id, diagnosis]):
            return jsonify({'error': 'Eksik bilgi: pet_id, vet_id ve diagnosis zorunludur.'}), 400

        # 2. Ana Ziyaret (Visit) Nesnesini Oluştur
        new_visit = MedicalVisit(
            pet_id=pet_id,
            vet_id=vet_id,
            diagnosis=diagnosis,
            notes=notes,
            visit_date=datetime.utcnow()
        )

        db.session.add(new_visit)
        
        # KRİTİK NOKTA: flush()
        # commit yapmadan önce flush diyerek veritabanında bu objeye bir ID atanmasını sağlıyoruz.
        # Böylece aşağıdaki prosedürlere visit_id verebileceğiz.
        db.session.flush() 

        # 3. İşlemleri (Procedures) Döngü ile Ekle
        for proc in procedures_data:
            new_procedure = MedicalProcedure(
                visit_id=new_visit.id, # Yeni oluşan ID'yi buraya bağlıyoruz
                category=proc.get('category'),
                title=proc.get('title'),
                details=proc.get('details') # JSONB verisi (Dict) olarak gelir
            )
            db.session.add(new_procedure)

        # 4. Her şey hatasızsa veritabanına işle
        db.session.commit()

        return jsonify({
            'message': 'Muayene kaydı başarıyla oluşturuldu.',
            'visit_id': new_visit.id
        }), 201

    except Exception as e:
        db.session.rollback() # Hata olursa yapılan tüm işlemleri geri al
        return jsonify({'error': str(e)}), 500


# --- 2. BİR HAYVANIN GEÇMİŞİNİ GETİRME ---
@visits_bp.route('/pet/<int:pet_id>', methods=['GET'])
def get_pet_history(pet_id):
    # O hayvana ait ziyaretleri, tarihe göre yeniden eskiye sıralayarak çek
    visits = MedicalVisit.query.filter_by(pet_id=pet_id)\
        .order_by(MedicalVisit.visit_date.desc())\
        .all()

    results = []
    for visit in visits:
        # Her ziyaretin içindeki prosedürleri de listeye ekliyoruz
        vet_name_str = visit.vet.name if visit.vet else "Bilinmiyor"
        procedures_list = []
        for proc in visit.procedures:
            procedures_list.append({
                'id': proc.id,
                'category': proc.category,
                'title': proc.title,
                'details': proc.details # JSON olarak döner
            })

        results.append({
            'id': visit.id,
            'vet_id': visit.vet_id,
            'vet_name': vet_name_str,
            'diagnosis': visit.diagnosis,
            'date': visit.visit_date.isoformat(),
            'notes': visit.notes,
            'procedures': procedures_list # İç içe yapı
        })

    return jsonify(results), 200


# --- 3. TEK BİR MUAYENE DETAYI ---
@visits_bp.route('/<int:visit_id>', methods=['GET'])
def get_visit_detail(visit_id):
    visit = MedicalVisit.query.get_or_404(visit_id)

    procedures_list = [{
        'id': p.id,
        'category': p.category,
        'title': p.title,
        'details': p.details
    } for p in visit.procedures]

    return jsonify({
        'id': visit.id,
        'pet_id': visit.pet_id,
        'vet_id': visit.vet_id,
        'diagnosis': visit.diagnosis,
        'date': visit.visit_date.isoformat(),
        'notes': visit.notes,
        'procedures': procedures_list
    }), 200