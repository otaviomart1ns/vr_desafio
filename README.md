# Projeto Flutter + Flask API

## Descrição

Este projeto consiste em uma aplicação web desenvolvida com Flutter para o frontend e Flask para o backend. O backend utiliza um banco de dados MySQL e ambos os serviços são orquestrados utilizando `docker-compose`. O projeto foi criado para Desafio VR Software.

### Tecnologias Utilizadas:

- **Frontend**: Flutter (Web)
- **Backend**: Flask
- **Banco de Dados**: MySQL
- **Containerização**: Docker, Docker Compose

---

## Requisitos

Certifique-se de ter os seguintes componentes instalados no ambiente onde o projeto será executado:

- **Docker**: [Instalar Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: [Instalar Docker Compose](https://docs.docker.com/compose/install/)

---

## Instruções para Execução

### 1. Clone o Repositório

Clone o repositório do projeto localmente:

```bash
git clone https://github.com/otaviomart1ns/vr_desafio.git
```

### 2. Navegue até o Diretório do Projeto

Acesse o diretório clonado:

```bash
cd vr_desafio
```

### 3. Configure o Arquivo `.env`

O arquivo `.env` deve estar configurado com as seguintes variáveis de ambiente para a API Flask e o banco de dados MySQL. Verifique se o arquivo está presente na raiz do projeto:

```bash
# Configurações do Flask
FLASK_ENV=prod                  # Modo de execução (dev, prod)
FLASK_APP=run.py                # Arquivo principal da API
API_PORT=5000                   # Porta onde a API será exposta
API_HOST=0.0.0.0                # Host para expor a API
SECRET_KEY=<insira_sua_secret_key_aqui> # Chave secreta para a API Flask

# Configurações do Banco de Dados
DB_NAME=<nome_do_banco>         # Nome do banco de dados MySQL
DB_PORT=3307                    # Porta do banco de dados
DB_USER=<usuario_do_banco>       # Usuário do banco de dados
DB_PASSWORD=<senha_do_banco>     # Senha do banco de dados
MYSQL_ROOT_PASSWORD=<senha_root> # Senha do usuário root do MySQL
DATABASE_URL=mysql+mysqlconnector://<usuario>:<senha>@localhost:<porta>/<nome_do_banco>
# Exemplo: mysql+mysqlconnector://appvr:INl1nzA4GinI@localhost:3307/vr

# Configurações do Flutter Web
WEB_PORT=8080                   # Porta onde o frontend Flutter será exposto
```

### 4. Executar o Projeto com Docker Compose

Com o `docker-compose`, os containers para a API Flask, o frontend Flutter e o banco de dados MySQL serão inicializados. Para executar o projeto, use o seguinte comando:

```bash
docker compose up --build
```

Este comando irá compilar as imagens e subir os seguintes serviços:

- **API Flask**: Disponível em `http://localhost:5000`.
- **Frontend Flutter**: Disponível em `http://localhost`.
- **Banco de Dados MySQL**: Funcionando internamente no container, acessível na porta `3307`.

### 5. Acessando a Aplicação

Após executar o comando acima, acesse os serviços:

- **Frontend Flutter**: Abra o navegador e vá para `http://localhost` para acessar a interface web.
- **Backend Flask API**: A API estará disponível em `http://localhost:5000`.

### 6. Parar os Containers

Para parar e remover os containers em execução, utilize o comando:

```bash
docker compose down
```

---

## Endpoints da API

Aqui estão os principais endpoints da API Flask para interagir com o backend:

### 1. **`GET /produtos`**

Retorna a lista de produtos cadastrados.

#### Exemplo de Requisição com `curl`:

```bash
curl -X GET http://localhost:5000/produtos
```

### 2. **`POST /produtos`**

Cria um novo produto.

#### Exemplo de Requisição com `curl`:

```bash
curl -X POST http://localhost:5000/produtos \
  -H "Content-Type: application/json" \
  -d '{
        "descricao": "Descrição do Produto A",
        "custo": 70.00,
        "imagem": "<imagem-base64>"
      }'
```

### 3. **`GET /produtos/<id>`**

Retorna informações sobre um produto específico com base no seu `id`.

#### Exemplo de Requisição com `curl`:

```bash
curl -X GET http://localhost:5000/produtos/1
```

### 4. **`PATCH /produtos/<id>`**

Atualiza um produto existente com base no `id`.

#### Exemplo de Requisição com `curl`:

```bash
curl -X PATCH http://localhost:5000/produtos/1 \
  -H "Content-Type: application/json" \
  -d '{
        "descricao": "Nova descrição do Produto A",
        "custo": 80.00,
        "imagem": "<nova-imagem-base64>"
      }'
```

### 5. **`DELETE /produtos/<id>`**

Exclui um produto existente com base no `id`.

#### Exemplo de Requisição com `curl`:

```bash
curl -X DELETE http://localhost:5000/produtos/1
```

---

## Endpoints para Preços de Produtos em Lojas

### 6. **`GET /produtos/<id>/lojas`**

Retorna a lista de preços de um produto específico em diferentes lojas.

#### Exemplo de Requisição com `curl`:

```bash
curl -X GET http://localhost:5000/produtos/1/lojas
```

### 7. **`POST /produtos/<id>/lojas`**

Associa um preço de venda a um produto em uma loja específica.

#### Exemplo de Requisição com `curl`:

```bash
curl -X POST http://localhost:5000/produtos/1/lojas \
  -H "Content-Type: application/json" \
  -d '{
        "loja_id": 2,
        "preco_venda": 105.00
      }'
```

### 8. **`PATCH /produtos/<id>/lojas/<id_preco>`**

Atualiza o preço de venda de um produto em uma loja específica.

#### Exemplo de Requisição com `curl`:

```bash
curl -X PATCH http://localhost:5000/produtos/1/lojas/1 \
  -H "Content-Type: application/json" \
  -d '{
        "preco_venda": 110.00
      }'
```

### 9. **`DELETE /produtos/<id>/lojas/<id_preco>`**

Remove a associação de preço de um produto em uma loja.

#### Exemplo de Requisição com `curl`:

```bash
curl -X DELETE http://localhost:5000/produtos/1/lojas/1
```

---

## Endpoints para Lojas

### 10. **`GET /lojas`**

Retorna a lista de lojas.

#### Exemplo de Requisição com `curl`:

```bash
curl -X GET http://localhost:5000/lojas
```

### 11. **`POST /lojas`**

Cria uma nova loja.

#### Exemplo de Requisição com `curl`:

```bash
curl -X POST http://localhost:5000/lojas \
  -H "Content-Type: application/json" \
  -d '{
        "descricao": "Loja B"
      }'
```

### 12. **`GET /lojas/<id>`**

Retorna informações sobre uma loja específica.

#### Exemplo de Requisição com `curl`:

```bash
curl -X GET http://localhost:5000/lojas/1
```

### 13. **`PATCH /lojas/<id>`**

Atualiza as informações de uma loja específica.

#### Exemplo de Requisição com `curl`:

```bash
curl -X PATCH http://localhost:5000/lojas/1 \
  -H "Content-Type: application/json" \
  -d '{
        "descricao": "Loja B Atualizada"
      }'
```

### 14. **`DELETE /lojas/<id>`**

Exclui uma loja específica.

#### Exemplo de Requisição com `curl`:

```bash
curl -X DELETE http://localhost:5000/lojas/1
```

---

## Problemas Comuns

### 1. **Portas em uso**

Se a porta 80 (para o frontend) ou 5000 (para a API) estiverem sendo usadas por outro processo, você pode:

- Alterar as portas no arquivo `docker-compose.yml`.
- Ou liberar as portas parando os processos que as estão usando.

### 2. **Conexão com o banco de dados**

Se ocorrerem erros de conexão com o banco de dados, verifique se as credenciais no arquivo `.env` estão corretas e se o container do MySQL foi inicializado corretamente.

---
