from flask import Flask
from flask_cors import CORS
from database import init_db
from extensions import db
from routes.auth_routes import auth_bp
from routes.pet_routes import pets_bp
from routes.vet_routes import vet_bp
from routes.appointment_routes import appointments_bp
from routes.clinic_routes import clinic_bp
from routes.user_routes import user_bp
from routes.visits_routes import visits_bp
from routes.vet_patients_routes import vet_patients_bp
import os

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

init_db(app)

app.register_blueprint(auth_bp)
app.register_blueprint(pets_bp)
app.register_blueprint(vet_bp)
app.register_blueprint(appointments_bp)
app.register_blueprint(clinic_bp)
app.register_blueprint(user_bp)
app.register_blueprint(visits_bp)
app.register_blueprint(vet_patients_bp)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
