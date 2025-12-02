from extensions import db
from datetime import datetime

class Appointments(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    pet_id = db.Column(db.Integer, db.ForeignKey('pets.id'), nullable=False)
    owner_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    vet_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    date = db.Column(db.DateTime, nullable=False)
    reason = db.Column(db.String(255))
    status = db.Column(db.String(50), default='pending')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    pet = db.relationship('Pets', backref='appointments', lazy=True)
    owner = db.relationship('users', foreign_keys=[owner_id], backref='owner_appointments', lazy=True)
    vet = db.relationship('users', foreign_keys=[vet_id], backref='vet_appointments', lazy=True)
