from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
from .config import Config

db = SQLAlchemy()
migrate = Migrate()

def create_app():
    app = Flask(__name__)
    CORS(app) 
    app.config.from_object(Config)

    db.init_app(app)
    migrate.init_app(app, db)

    from .routes import api as api_blueprint
    app.register_blueprint(api_blueprint)

    return app
