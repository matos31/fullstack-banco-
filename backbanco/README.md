# Projeto Bradesco

## Descrição do Projeto

O objetivo do projeto é consultar de maneira segura se o cliente tem Valores a Receber em seu CPF pelo aplicativo do banco, contornando assim golpes onde terceiros contatem o cliente, pedindo quantidades em dinheiro para tal consulta.

## Modo de Uso

Este projeto é uma aplicação web desenvolvida com Django e Django REST Framework. Para rodar o projeto localmente, siga os passos abaixo:

## **PROJETO DEVE RODAR NA MAQUINA LOCAL. **

### Pré-requisitos

*   Python 3.9
*   pip (gerenciador de pacotes do Python)
*   IDE VS Code
*	IDE IntelliJ Community
*	Postman (Para utilização das APIs)
*   Extensao Markdown Preview Mermaid Support

### Instalação

1.  Baixe os repositórios necessários:

*	APIBC para consulta das APIs: https://github.com/alysonGuimaraes/Atividade-A3_VersaoAPIBC *atenção: rodar no IntelliJ*

2.  Crie e ative um ambiente virtual (recomendado):

    
*    python -m venv venv
    
*    Ative a venv:

*    venv\Scripts\activate\
    


3.  Rodar o APIBC:

*	Rode o APIBC na IDE IntelliJ, executando o arquivo ValoresareceberApplication.
*	Caminho src/main/java/com/bca3/valoresareceber/ .
 
4.  Instale as dependências:

*	As dependências do BackEnd estao no requirements.txt:  pip install -r requirements.txt
* 	As dependências da APIBC sao instaladas automaticamente pelo IntelliJ ao abrir a aplicacao, devido ao pom.xml

5.  Inicie o servidor de desenvolvimento:


*	python manage.py runserver


*	O projeto estará acessível em http://127.0.0.1:8000/ .

	Caso necessario, python .\manage.py migrate .

6. Utilizacao do Postman

*	Utilize o Postman para testar as APIs




## Exemplos de exitos e erros com as APIs





* API POST http://127.0.0.1:8000/api/registro/

* Resposta esperada para registro com sucesso:

{
    "mensagem": "Usuário registrado com sucesso!"
}


* Resposta de erro devido a falta de cpf no campo:

{
    "cpf": [
        "This field may not be blank."
    ]
}

##


* API POST http://127.0.0.1:8000/api/login/

* Resposta esperada para login com sucesso:

{
    "mensagem": "Login realizado com sucesso!",
    "access": "token de acesso...",
    "refresh": "token de refresh..."
}


* Resposta de erro devido a senha incorreta no login:

{
    "erro": "Senha incorreta"
}

##

* API  POST http://127.0.0.1:8000/api/valores-a-receber/

* Exemplo de resposta devido a erro de token invalido no authorization: 

{
    "erro": "Token inválido"
}


* Exemplo da resposta esperada com um token valido:

{
    "CPF proponente": "29891443078",
    "valores_a_receber": [
        {
            "nomeInstituicao": "Banco XYZ",
            "cnpj": "71710084000103",
            "valor": 1500.75,
            "tipoValor": "Antecipação",
            "observacao": "Recebido parcialmente",
            "dtaReferencia": "2024-01-01"
        }
    ],
    "Nome proponente": "João Silva",
    "Possui_valores_receber": true
}

##

## Tecnologias e Ferramentas Utilizadas

*   **Linguagem:** Python
*   **Framework Web:** Django
*   **API Framework:** Django REST Framework
*   **Banco de Dados:** SQLite (padrão do Django)
*   **IDE:** VS Code e IntelliJ Community
*   **Plataforma para tesde das APIs:** Postman
## Autores

*   Alyson Guimarães da Silva
*   Edicarlos Jorge Marques Filho
*   Eduardo Matos Santana
*   Gabriel Cavali da Silva
*   José Luiz Oliveira Valenza


