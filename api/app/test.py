import pytest
import json
from app import create_app, db
from app.models import Produto, Loja, ProdutoLoja

@pytest.fixture
def client():
    app = create_app(config_name='test')

    with app.app_context():
        db.create_all()

    with app.test_client() as client:
        yield client

    with app.app_context():
        db.drop_all()
        
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
    with client.application.app_context():
        produto = Produto(descricao="Leite Condensado", custo=10.5)
        db.session.add(produto)
        db.session.commit()
        produto_id = produto.id

    response = client.get(f'/produtos/{produto_id}')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["descricao"] == "Leite Condensado"
    assert data["custo"] == 10.5

def test_update_produto(client):
    # Testa a atualização de um produto existente
    with client.application.app_context():
        produto = Produto(descricao="Leite Condensado", custo=10.5)
        db.session.add(produto)
        db.session.commit()
        produto_id = produto.id

    updated_data = {
        "descricao": "Leite Desnatado",
        "custo": 12.0
    }
    response = client.patch(f'/produtos/{produto_id}', json=updated_data)
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["message"] == "Produto atualizado com sucesso!"

def test_delete_produto(client):
    # Testa a exclusão de um produto existente
    with client.application.app_context():
        produto = Produto(descricao="Iogurte", custo=6.0)
        db.session.add(produto)
        db.session.commit()
        produto_id = produto.id

    response = client.delete(f'/produtos/{produto_id}')
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
    with client.application.app_context():
        loja1 = Loja(descricao="Loja 01")
        loja2 = Loja(descricao="Loja 02")
        db.session.add(loja1)
        db.session.add(loja2)
        db.session.commit()

    response = client.get('/lojas')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert len(data) == 2

def test_get_loja(client):
    # Testa a obtenção de uma loja específica
    with client.application.app_context():
        loja = Loja(descricao="Loja 01")
        db.session.add(loja)
        db.session.commit()
        loja_id = loja.id

    response = client.get(f'/lojas/{loja_id}')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["descricao"] == "Loja 01"

def test_create_preco_produto(client):
    # Testa a criação de um preço para um produto em uma loja
    with client.application.app_context():
        produto = Produto(descricao="Leite Condensado", custo=10.5)
        loja = Loja(descricao="Loja 01")
        db.session.add(produto)
        db.session.add(loja)
        db.session.commit()
        produto_id = produto.id
        loja_id = loja.id

    preco_data = {
        "id_loja": loja_id,
        "preco_venda": 12.5
    }
    response = client.post(f'/produtos/{produto_id}/precos', json=preco_data)
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data["message"] == "Preço de venda adicionado com sucesso!"

def test_get_precos_produto(client):
    # Testa a obtenção dos preços de venda de um produto
    with client.application.app_context():
        produto = Produto(descricao="Leite Condensado", custo=10.5)
        loja = Loja(descricao="Loja 01")
        db.session.add(produto)
        db.session.add(loja)
        db.session.commit()

        preco = ProdutoLoja(id_produto=produto.id, id_loja=loja.id, preco_venda=12.5)
        db.session.add(preco)
        db.session.commit()
        produto_id = produto.id

    response = client.get(f'/produtos/{produto_id}/precos')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert len(data) == 1
    assert data[0]["preco_venda"] == 12.5

def test_update_preco_produto(client):
    # Testa a atualização de um preço de venda de um produto em uma loja
    with client.application.app_context():
        produto = Produto(descricao="Leite Condensado", custo=10.5)
        loja = Loja(descricao="Loja 01")
        db.session.add(produto)
        db.session.add(loja)
        db.session.commit()

        preco = ProdutoLoja(id_produto=produto.id, id_loja=loja.id, preco_venda=12.5)
        db.session.add(preco)
        db.session.commit()
        produto_id = produto.id
        preco_id = preco.id

    updated_data = {
        "preco_venda": 15.0
    }
    response = client.patch(f'/produtos/{produto_id}/precos/{preco_id}', json=updated_data)
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["message"] == "Preço de venda atualizado com sucesso!"

def test_delete_preco_produto(client):
    # Testa a exclusão de um preço de venda de um produto em uma loja
    with client.application.app_context():
        produto = Produto(descricao="Leite Condensado", custo=10.5)
        loja = Loja(descricao="Loja 01")
        db.session.add(produto)
        db.session.add(loja)
        db.session.commit()

        preco = ProdutoLoja(id_produto=produto.id, id_loja=loja.id, preco_venda=12.5)
        db.session.add(preco)
        db.session.commit()
        produto_id = produto.id
        preco_id = preco.id

    response = client.delete(f'/produtos/{produto_id}/precos/{preco_id}')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["message"] == "Preço de venda excluído com sucesso!"
