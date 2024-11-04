import pytest
import json
from app import create_app, db
from app.models import Produto, Loja

@pytest.fixture
def client():
    # Configuração da aplicação para testes
    app = create_app(config_overrides={
        'TESTING': True,
        'SQLALCHEMY_DATABASE_URI': 'sqlite:///:memory:'
    })

    with app.app_context():
        db.create_all()
    
    with app.test_client() as client:
        yield client

def test_index(client):
    # Testa a rota index para verificar se a API está funcionando
    response = client.get('/')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["message"] == "API está funcionando!"

def test_create_produto(client):
    # Testa a criação de um novo produto
    produto_data = {
        "descricao": "Energetico",
        "custo": 5.15
    }
    response = client.post('/produtos', json=produto_data)
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data["message"] == "Produto criado com sucesso!"
    assert "id" in data

def test_get_produto(client):
    # Testa a obtenção de um produto existente
    produto = Produto(descricao="Leite Condensado", custo=10.5)
    db.session.add(produto)
    db.session.commit()

    response = client.get(f'/produtos/{produto.id}')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["descricao"] == "Leite Condensado"
    assert data["custo"] == 10.5

def test_update_produto(client):
    # Testa a atualização de um produto existente
    produto = Produto(descricao="Leite Condensado", custo=10.5)
    db.session.add(produto)
    db.session.commit()

    updated_data = {
        "descricao": "Leite Desnatado",
        "custo": 12.0
    }
    response = client.patch(f'/produtos/{produto.id}', json=updated_data)
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["message"] == "Produto atualizado com sucesso!"

def test_delete_produto(client):
    # Testa a exclusão de um produto existente
    produto = Produto(descricao="Iogurte", custo=6.0)
    db.session.add(produto)
    db.session.commit()

    response = client.delete(f'/produtos/{produto.id}')
    assert response.status_code == 204

def test_create_loja(client):
    # Testa a criação de uma nova loja
    loja_data = {
        "descricao": "Loja 01"
    }
    response = client.post('/lojas', json=loja_data)
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data["message"] == "Loja criada com sucesso!"
    assert "id" in data

def test_get_lojas(client):
    # Testa a listagem de lojas
    loja1 = Loja(descricao="Loja 01")
    loja2 = Loja(descricao="Loja 02")
    db.session.add(loja1)
    db.session.add(loja2)
    db.session.commit()

    response = client.get('/lojas')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert len(data) == 2

if __name__ == "__main__":
    pytest.main()
