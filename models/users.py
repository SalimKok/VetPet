from extensions import db
from datetime import datetime

vet_patients = db.Table('vet_patients',
    db.Column('user_id', db.Integer, db.ForeignKey('users.id'), primary_key=True),
    db.Column('pet_id', db.Integer, db.ForeignKey('pets.id'), primary_key=True)
)

class users(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    role = db.Column(db.String(50), nullable=False) 
    photo_url = db.Column(db.String(255), nullable=True)  
    phone = db.Column(db.String(20), nullable=True) 
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    my_patients = db.relationship(
        'Pets', 
        secondary=vet_patients, 
        backref=db.backref('vets', lazy='dynamic'),
        lazy='dynamic'
    )
    
    def __init__(self, name, email, password_hash, role, photo_url=None, phone=None):
        self.name = name
        self.email = email
        self.password_hash = password_hash
        self.role = role
        self.photo_url = photo_url
        self.phone = phone
