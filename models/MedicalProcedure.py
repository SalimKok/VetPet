from extensions import db
from sqlalchemy import JSON

class MedicalProcedure(db.Model):
    __tablename__ = "medical_procedures"

    id = db.Column(db.Integer, primary_key=True, index=True)
    visit_id = db.Column(db.Integer, db.ForeignKey("medical_visits.id"), nullable=False)
    
    category = db.Column(db.String, nullable=False)  # VACCINE, IMAGING vs.
    title = db.Column(db.String, nullable=False)
    details = db.Column(JSON, nullable=False)        # JSONB yerine JSON

    visit = db.relationship("MedicalVisit", back_populates="procedures")
