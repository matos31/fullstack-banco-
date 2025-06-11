🏦 Projeto Banco Fictício
Este projeto simula um banco com funcionalidades de login, valores a receber, Pix, boletos e empréstimos. É dividido em duas partes:

📱 Frontend (Flutter) – Interface do usuário

🖥️ Backend (Django + REST Framework) – API e banco de dados

🚀 Como rodar o projeto
1. 📦 Faça o download do ZIP
Clique em Code > Download ZIP ou clique aqui se já estiver hospedado.

Extraia o conteúdo para um local fácil de acessar.

Você verá duas pastas principais:

bash
Copiar
Editar
📁 banco_app         # Projeto Flutter (Frontend)
📁 projeto_bradescov2 # Projeto Django (Backend)
💻 Backend (Django)
✔️ Requisitos:
Python 3.10+

Virtualenv (opcional, mas recomendado)

VS Code ou PyCharm

▶️ Como rodar:
Abra a pasta projeto_bradescov2 no VS Code ou PyCharm.

Crie e ative um ambiente virtual (opcional, mas recomendado):

bash
Copiar
Editar
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac
Instale as dependências:

bash
Copiar
Editar
pip install -r requirements.txt
Rode as migrações:

bash
Copiar
Editar
python manage.py migrate
Inicie o servidor:

bash
Copiar
Editar
python manage.py runserver
O backend estará disponível em:

arduino
Copiar
Editar
http://localhost:8000
📱 Frontend (Flutter)
✔️ Requisitos:
Flutter SDK instalado

Android Studio ou VS Code

▶️ Como rodar:
Abra a pasta banco_app no Android Studio ou VS Code.

Execute o comando para atualizar pacotes:

bash
Copiar
Editar
flutter pub get
Conecte um emulador ou dispositivo físico.

Rode o projeto:

bash
Copiar
Editar
flutter run
Certifique-se de que o backend (Django) esteja rodando em http://localhost:8000.
Se estiver em outro IP (ex: rede local), atualize os endpoints em auth_provider.dart.

✅ Funcionalidades implementadas
Login e registro com autenticação JWT 🔐

Tela de valores a receber com estilo moderno 💰

Cartão virtual e controle de fatura 💳

Pix, Boletos e Empréstimos com navegação 💸

🛠️ API
POST /api/registro/ → Criar novo usuário

POST /api/login/ → Autenticar e receber token

POST /cadastrar-valor/ → Cadastrar valor para um CPF

POST /valores-a-receber/ → Retorna os valores associados ao CPF do usuário autenticado
