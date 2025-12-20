from extensions import db
from flask import Flask

def init_db(app: Flask):
    app.config['SQLALCHEMY_DATABASE_URI'] = '************************'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    db.init_app(app)
    with app.app_context():
        db.create_all()

