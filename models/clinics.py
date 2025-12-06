from extensions import db
from models.users import users
from models.locations import City, District # Locations'ı import etmeyi unutmayın

class Clinic(db.Model):
    __tablename__ = 'clinic'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    
    # --- KONUM BİLGİLERİ ---
    city_id = db.Column(db.Integer, db.ForeignKey('cities.id'), nullable=True)
    district_id = db.Column(db.Integer, db.ForeignKey('district.id'), nullable=True)
    
    # Mahalle yok, direkt açık adres detayı var
    address_details = db.Column(db.String(500)) 

    phone = db.Column(db.String(50))
    working_hours = db.Column(db.String(255))
    
    vet_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE', onupdate='CASCADE'), nullable=False)
    vet = db.relationship('users', backref=db.backref('clinics', lazy=True))

    # İsimlere erişmek için ilişkiler
    city = db.relationship('City', backref='clinics')
    district = db.relationship('District', backref='clinics')

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            
            "city_id": self.city_id,
            "city_name": self.city.name if self.city else None,
            
            "district_id": self.district_id,
            "district_name": self.district.name if self.district else None,
            
            "address_details": self.address_details,
            
            # Tam adres stringi (Mahalle olmadan)
            "full_address_string": f"{self.city.name if self.city else ''} / {self.district.name if self.district else ''} - {self.address_details}",
            
            "phone": self.phone,
            "working_hours": self.working_hours,
            "vet_id": self.vet_id
        }