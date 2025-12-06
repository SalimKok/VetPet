from extensions import db

# Tablo adı: cities (Çoğul)
class City(db.Model):
    __tablename__ = 'cities'  # <-- Veritabanındaki tablo adı

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
        }

# Tablo adı: district (Tekil)
class District(db.Model):
    __tablename__ = 'district' # <-- Veritabanındaki tablo adı

    id = db.Column(db.Integer, primary_key=True)

    city_id = db.Column(db.Integer, db.ForeignKey('cities.id'), nullable=False) 
    
    name = db.Column(db.String(255), nullable=False)

    # İlişki
    city = db.relationship('City', backref=db.backref('districts', lazy=True))

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "city_id": self.city_id
        }