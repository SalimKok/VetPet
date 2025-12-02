from extensions import db
from models.users import users 

class Clinic(db.Model):
    __tablename__ = 'clinic'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    address = db.Column(db.String(500))
    phone = db.Column(db.String(50))
    working_hours = db.Column(db.String(255))
    vet_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE', onupdate='CASCADE'), nullable=False)

    # Relationship: Veterinerin klinikleri
    vet = db.relationship('users', backref=db.backref('clinics', lazy=True))

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "address": self.address,
            "phone": self.phone,
            "working_hours": self.working_hours,
            "vet_id": self.vet_id,
            "vet_name": self.vet.name if self.vet else None
        }
