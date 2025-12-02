from datetime import datetime
from extensions import db

class MedicalVisit(db.Model):
    __tablename__ = "medical_visits"

    id = db.Column(db.Integer, primary_key=True, index=True)
    pet_id = db.Column(db.Integer, db.ForeignKey("pets.id"), nullable=False)
    vet_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    
    diagnosis = db.Column(db.String, nullable=False)
    visit_date = db.Column(db.DateTime, default=datetime.utcnow)
    notes = db.Column(db.Text, nullable=True)

    vet = db.relationship('users', backref='performed_visits')

    procedures = db.relationship(
        "MedicalProcedure",
        back_populates="visit",
        cascade="all, delete-orphan"
    )
