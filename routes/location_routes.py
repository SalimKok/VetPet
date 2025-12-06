from flask import Blueprint, jsonify
from models.locations import City, District

location_bp = Blueprint('location', __name__)

# Tüm Şehirleri Getir
@location_bp.route('/cities', methods=['GET'])
def get_cities():
    try:
        # DÜZELTME: plate_number yerine id'ye göre sıralıyoruz
        cities_list = City.query.order_by(City.id).all()
        
        result = []
        for city in cities_list:
            result.append(city.to_dict())
        
        return jsonify({"success": True, "cities": result}), 200
    except Exception as e:
        return jsonify({"success": False, "message": f"Şehirler çekilemedi: {str(e)}"}), 500

# Seçilen Şehrin İlçelerini Getir
@location_bp.route('/districts/<int:city_id>', methods=['GET'])
def get_districts(city_id):
    try:
        # İsme göre sırala
        districts_list = District.query.filter_by(city_id=city_id).order_by(District.name).all()
        
        result = []
        for dist in districts_list:
            result.append(dist.to_dict())
        
        return jsonify({"success": True, "districts": result}), 200
    except Exception as e:
        return jsonify({"success": False, "message": f"İlçeler çekilemedi: {str(e)}"}), 500