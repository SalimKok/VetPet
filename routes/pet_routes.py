from flask import Blueprint, request, jsonify, send_from_directory, current_app
from werkzeug.utils import secure_filename
from extensions import db
from models.pets import Pets
import os
from datetime import datetime

pets_bp = Blueprint('pets', __name__)

# Fotoğraf servisi
@pets_bp.route('/uploads/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(current_app.config['UPLOAD_FOLDER'], filename)


@pets_bp.route('/pets/<int:owner_id>', methods=['GET'])
def get_pets(owner_id):
    pets_list = Pets.query.filter_by(owner_id=owner_id).all()
    result = [
        {
            "id": pet.id,
            "name": pet.name,
            "species": pet.species,
            "breed": pet.breed,
            "birth_date": pet.birth_date.isoformat() if pet.birth_date else None,
            "photo_url": pet.photo_url,
            "notes": pet.notes
        } for pet in pets_list
    ]
    return jsonify({"success": True, "pets": result}), 200


@pets_bp.route('/pets', methods=['POST'])
def add_pet():
    name = request.form.get('name')
    owner_id = request.form.get('owner_id')
    species = request.form.get('species')
    breed = request.form.get('breed')
    notes = request.form.get('notes')
    birth_date = request.form.get('birth_date')
    photo = request.files.get('photo')

    photo_url = None
    if photo:
        filename = secure_filename(photo.filename)
        photo.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
        photo_url = f"http://10.0.2.2:5000/uploads/{filename}"

    birth_dt = datetime.fromisoformat(birth_date) if birth_date else None

    pet = Pets(
        owner_id=int(owner_id),
        name=name,
        species=species,
        breed=breed,
        birth_date=birth_dt,
        photo_url=photo_url,
        notes=notes
    )
    db.session.add(pet)
    db.session.commit()
    return jsonify({"success": True, "message": "Pet eklendi", "pet_id": pet.id}), 201


@pets_bp.route('/pets/<int:pet_id>', methods=['PUT'])
def update_pet(pet_id):
    pet = Pets.query.get_or_404(pet_id)

    name = request.form.get('name', pet.name)
    species = request.form.get('species', pet.species)
    breed = request.form.get('breed', pet.breed)
    notes = request.form.get('notes', pet.notes)
    birth_date = request.form.get('birth_date')
    photo = request.files.get('photo')

    if birth_date:
        pet.birth_date = datetime.fromisoformat(birth_date)
    if photo:
        filename = secure_filename(photo.filename)
        photo.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
        pet.photo_url = f"http://10.0.2.2:5000/uploads/{filename}"

    pet.name = name
    pet.species = species
    pet.breed = breed
    pet.notes = notes

    db.session.commit()
    return jsonify({"success": True, "message": "Pet güncellendi"}), 200


@pets_bp.route('/pets/<int:pet_id>', methods=['DELETE'])
def delete_pet(pet_id):
    pet = Pets.query.get_or_404(pet_id)
    db.session.delete(pet)
    db.session.commit()
    return jsonify({"success": True, "message": "Pet silindi"}), 200


