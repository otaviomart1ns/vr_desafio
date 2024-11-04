from . import db

class Produto(db.Model):
    __tablename__ = "produto"
        
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    descricao = db.Column(db.String(60), nullable=False)
    custo = db.Column(db.Numeric(13,3), nullable=True)
    imagem = db.Column(db.LargeBinary(length=(2**24)-1), nullable=True)

    precos_lojas = db.relationship("ProdutoLoja", back_populates="produto", cascade="all, delete-orphan")
    
    def to_dict(self):
        return {
            "id": self.id,
            "descricao": self.descricao,
            "custo": str(self.custo),
            "imagem": self.imagem,
            "precos_lojas": [preco.to_dict() for preco in self.precos_lojas]
        }

class Loja(db.Model):
    __tablename__ = "loja"
        
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    descricao = db.Column(db.String(60), nullable=False)

    precos_produtos = db.relationship("ProdutoLoja", back_populates="loja", cascade="all, delete-orphan")

    
    def to_dict(self):
        return {
            "id": self.id,
            "descricao": self.descricao,
            "precos_produtos": [preco.to_dict() for preco in self.precos_produtos]
        }

class ProdutoLoja(db.Model):
    __tablename__ = "produto_loja"
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    preco_venda = db.Column(db.Numeric(13,3), nullable=False)
    
    id_produto = db.Column(db.Integer, db.ForeignKey("produto.id"), nullable=False)
    id_loja = db.Column(db.Integer, db.ForeignKey("loja.id"), nullable=False)
    
    produto = db.relationship("Produto", back_populates="precos_lojas")
    loja = db.relationship("Loja", back_populates="precos_produtos")
    
    __table_args__ = (
        db.UniqueConstraint("id_produto", "id_loja", name="unique_produto_loja"),
    )
    
    def to_dict(self):
        return {
            "id": self.id,
            "id_produto": self.id_produto,
            "id_loja": self.id_loja,
            "descricao_loja": self.loja.descricao,
            "preco_venda": str(self.preco_venda),
        }