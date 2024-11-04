import base64
from flask import Blueprint, jsonify, request
from sqlalchemy.exc import IntegrityError
from . import Config, db
from .models import Produto, ProdutoLoja, Loja

api = Blueprint('api', __name__)

# GET / - Index
@api.route('/')
def index():
    return jsonify({"message": "API está funcionando!"})

# GET /produtos - Listagem de produtos com filtros
@api.route('/produtos', methods=['GET'])
def get_produtos():
    try:
        id = request.args.get('id')
        descricao = request.args.get('descricao')
        custo = request.args.get('custo')
        preco_venda = request.args.get('preco_venda')

        query = Produto.query

        if id:
            query = query.filter(Produto.id == id)
        if descricao:
            query = query.filter(Produto.descricao.ilike(f"%{descricao}%"))
        if custo:
            query = query.filter(Produto.custo == custo)
        if preco_venda:
            query = query.join(ProdutoLoja).filter(ProdutoLoja.preco_venda == preco_venda)

        produtos = query.all()
        response = []
        for p in produtos:
            produto_data = {
                "id": p.id,
                "descricao": p.descricao,
                "custo": float(p.custo) if p.custo else None,
                "precos_venda": [float(preco.preco_venda) for preco in ProdutoLoja.query.filter_by(id_produto=p.id).all()]
            }

            response.append(produto_data)

        return jsonify(response), 200

    except Exception as e:
        return jsonify({"message": "Erro ao listar produtos.", "error": str(e)}), 500

# GET /produtos/<int:id> - Listagem de um produto
@api.route('/produtos/<int:id>', methods=['GET'])
def get_produto(id):
    produto = Produto.query.get(id)
    if not produto:
        return jsonify({"message": "Produto não encontrado."}), 404

    imagem_base64 = None
    if produto.imagem:
        imagem_base64 = base64.b64encode(produto.imagem).decode('utf-8') 
        
    return jsonify({
        "id": produto.id,
        "descricao": produto.descricao,
        "custo": float(produto.custo),
        "imagem": imagem_base64
    }), 200

# POST /produtos - Criar um produto
@api.route('/produtos', methods=['POST'])
def create_produto():
    data = request.json
    
    descricao = data.get('descricao')
    custo = data.get('custo')
    imagem = data.get('imagem')

    if not descricao or len(descricao) > 60:
        return jsonify({"message": "Campo 'descricao' é obrigatório e deve ter no máximo 60 caracteres."}), 400

    try:
        produto = Produto(descricao=descricao, custo=custo)
        
        if imagem:
            try:
                produto.imagem = base64.b64decode(imagem)
            except Exception as e:
                return jsonify({"message": "Erro ao decodificar a imagem."}), 400

        db.session.add(produto)
        db.session.commit()
        return jsonify({"message": "Produto criado com sucesso!", "id": produto.id}), 201
    except IntegrityError:
        db.session.rollback()
        return jsonify({"message": "Erro de integridade ao criar produto."}), 400
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Erro ao criar produto.", "error": str(e)}), 500

# PATCH /produtos/<int:id> - Atualizar um produto
@api.route('/produtos/<int:id>', methods=['PATCH'])
def update_produto(id):
    produto = Produto.query.get(id)
    if not produto:
        return jsonify({"message": "Produto não encontrado."}), 404

    data = request.json
    produto.descricao = data.get('descricao', produto.descricao)
    produto.custo = data.get('custo', produto.custo)
    imagem = data.get('imagem')
    if imagem:
        try:
            produto.imagem = base64.b64decode(imagem)
        except Exception as e:
            return jsonify({"message": "Erro ao decodificar a nova imagem."}), 400
    
    try:
        db.session.commit()
        return jsonify({"message": "Produto atualizado com sucesso!"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Erro ao atualizar produto.", "error": str(e)}), 500

# DELETE /produtos/<int:id> - Excluir um produto
@api.route('/produtos/<int:id>', methods=['DELETE'])
def delete_produto(id):
    produto = Produto.query.get(id)
    if not produto:
        return jsonify({"message": "Produto não encontrado."}), 404

    try:
        db.session.delete(produto)
        db.session.commit()
        return jsonify({"message": "Produto excluído com sucesso"}), 204
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Erro ao excluir produto.", "error": str(e)}), 500

# GET /lojas - Listagem de lojas
@api.route('/lojas', methods=['GET'])
def get_lojas():
    try:
        lojas = Loja.query.all()
        return jsonify([{
            "id": loja.id,
            "descricao": loja.descricao
        } for loja in lojas]), 200
    except Exception as e:
        return jsonify({"message": "Erro ao listar lojas.", "error": str(e)}), 500
    
# GET /lojas/<id> - Busca de uma loja específica pelo ID
@api.route('/lojas/<int:id>', methods=['GET'])
def get_loja(id):
    try:
        loja = Loja.query.get(id)
        if loja is None:
            return jsonify({"message": "Loja não encontrada."}), 404
        return jsonify({
            "id": loja.id,
            "descricao": loja.descricao
        }), 200
    except Exception as e:
        return jsonify({"message": "Erro ao buscar loja.", "error": str(e)}), 500

# POST /lojas - Criar uma loja
@api.route('/lojas', methods=['POST'])
def create_loja():
    data = request.json
    descricao = data.get('descricao')

    if not descricao or len(descricao) > 60:
        return jsonify({"message": "Campo 'descricao' é obrigatório e deve ter no máximo 60 caracteres."}), 400

    try:
        loja = Loja(descricao=descricao)
        db.session.add(loja)
        db.session.commit()
        return jsonify({"message": "Loja criada com sucesso!", "id": loja.id}), 201
    except IntegrityError:
        db.session.rollback()
        return jsonify({"message": "Erro de integridade ao criar loja."}), 400
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Erro ao criar loja.", "error": str(e)}), 500
    
# PATCH /lojas/<int:id> - Atualizar a descrição de uma loja
@api.route('/lojas/<int:id>', methods=['PATCH'])
def update_loja(id):
    loja = Loja.query.get(id)
    if not loja:
        return jsonify({"message": "Loja não encontrada."}), 404

    data = request.json
    descricao = data.get('descricao')

    if descricao and len(descricao) > 60:
        return jsonify({"message": "Campo 'descricao' deve ter no máximo 60 caracteres."}), 400

    try:
        if descricao:
            loja.descricao = descricao
        
        db.session.commit()
        return jsonify({"message": "Descrição da loja atualizada com sucesso!"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Erro ao atualizar descrição da loja.", "error": str(e)}), 500
    
# DELETE /lojas/<int:id> - Excluir uma loja
@api.route('/lojas/<int:id>', methods=['DELETE'])
def delete_loja(id):
    loja = Loja.query.get(id)
    if not loja:
        return jsonify({"message": "Loja não encontrada."}), 404

    try:
        db.session.delete(loja)
        db.session.commit()
        return jsonify({"message": "Loja excluída com sucesso!"}), 204
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Erro ao excluir loja.", "error": str(e)}), 500
    
# GET /produtos/<int:id>/precos - Listar preços de venda de um produto em lojas
@api.route('/produtos/<int:id>/precos', methods=['GET'])
def get_precos_produto(id):
    produto = Produto.query.get(id)
    if not produto:
        return jsonify({"message": "Produto não encontrado."}), 404
    try:
        precos = ProdutoLoja.query.filter_by(id_produto=id).all()
        return jsonify([{
            "id": preco.id,
            "id_produto": preco.produto.id,
            "descricao_produto": preco.produto.descricao,
            "id_loja": preco.id_loja,
            "descricao_loja": preco.loja.descricao,
            "preco_venda": float(preco.preco_venda)
        } for preco in precos]), 200
    except Exception as e:
        return jsonify({"message": "Erro ao listar preços.", "error": str(e)}), 500

# POST /produtos/<id>/precos - Adicionar preço de venda para um produto em uma loja
@api.route('/produtos/<int:id>/precos', methods=['POST'])
def create_preco_produto(id):
    produto = Produto.query.get(id)
    if not produto:
        return jsonify({"message": "Produto não encontrado."}), 404
    
    data = request.json
    id_loja = data.get('id_loja')
    preco_venda = data.get('preco_venda')

    if not id_loja or not preco_venda:
        return jsonify({"message": "'id_loja' e 'preco_venda' são obrigatórios."}), 400

    existing_preco = ProdutoLoja.query.filter_by(id_produto=id, id_loja=id_loja).first()
    if existing_preco:
        return jsonify({"message": "Não é permitido mais que um preço de venda para a mesma loja."}), 400

    try:
        preco = ProdutoLoja(id_produto=id, id_loja=id_loja, preco_venda=preco_venda)
        db.session.add(preco)
        db.session.commit()
        return jsonify({"message": "Preço de venda adicionado com sucesso!"}), 201
    except IntegrityError:
        db.session.rollback()
        return jsonify({"message": "Erro de integridade ao adicionar preço."}), 400
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Erro ao adicionar preço.", "error": str(e)}), 500

# PATCH /produtos/<id>/precos/<id_preco> - Atualizar preço de venda de um produto em uma loja
@api.route('/produtos/<int:id>/precos/<int:id_preco>', methods=['PATCH'])
def update_preco_produto(id, id_preco):
    preco = ProdutoLoja.query.get(id_preco)
    if not preco:
        return jsonify({"message": "Preço não encontrado."}), 404
    
    data = request.json
    preco_venda = data.get('preco_venda')
    
    if preco_venda is not None:
        if not isinstance(preco_venda, (int, float)):
            return jsonify({"message": "Preço de venda deve ser um número."}), 400
    
        preco.preco_venda = preco_venda
        
    try:
        db.session.commit()
        return jsonify({"message": "Preço de venda atualizado com sucesso!"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Erro ao atualizar preço.", "error": str(e)}), 500

# DELETE /produtos/<id>/precos/<id_preco> - Remover preço de venda de um produto em uma loja
@api.route('/produtos/<int:id>/precos/<int:id_preco>', methods=['DELETE'])
def delete_preco_produto(id, id_preco):
    preco = ProdutoLoja.query.get(id_preco)
    if not preco:
        return jsonify({"message": "Preço não encontrado."}), 404
    
    try:
        db.session.delete(preco)
        db.session.commit()
        return jsonify({"message": "Preço de venda excluído com sucesso!"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Erro ao excluir preço.", "error": str(e)}), 500
