from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
from .config import Config

db = SQLAlchemy()
migrate = Migrate()

def create_app(config_name='default'):
    app = Flask(__name__)
    CORS(app)
    
    if config_name == 'test':
        app.config.from_mapping({
            'TESTING': True,
            'SQLALCHEMY_DATABASE_URI': 'sqlite:///:memory:',
            'SQLALCHEMY_TRACK_MODIFICATIONS': False
        })
    else:
        app.config.from_object(Config)

    db.init_app(app)
    migrate.init_app(app, db)

    from .routes import api as api_blueprint
    app.register_blueprint(api_blueprint)

    return app
