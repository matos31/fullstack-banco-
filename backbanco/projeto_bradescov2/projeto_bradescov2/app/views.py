from django.shortcuts import render
import requests
import jwt
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Client
from .serializers import ClientSerializer
from django.contrib.auth.hashers import make_password, check_password
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.views import TokenObtainPairView
from .jwt_auth import CustomTokenObtainPairSerializer
from datetime import datetime, timedelta
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.tokens import AccessToken

# Endpoint de registro
class RegistroView(APIView):
    def post(self, request):
        print("DADOS RECEBIDOS:", request.data)

        data = request.data.copy()
        data['senha'] = make_password(data.get('senha'))  # Criptografa a senha

        serializer = ClientSerializer(data=data)

        if serializer.is_valid():
            client = serializer.save()
            print("✅ Registro realizado com sucesso.")

            # Envia automaticamente para a API externa
            try:
                external_payload = {
                    "nome": client.nome,
                    "cpf": client.cpf,
                    "dtaNascimento": str(client.nascimento)
                }
                external_response = requests.post(
                    "http://localhost:8090/valores-a-receber/proponente",
                    json=external_payload,
                    timeout=5
                )
                print("🌐 Registro na API externa:", external_response.status_code)
            except Exception as e:
                print("❌ Falha ao registrar na API externa:", e)

            return Response({'mensagem': 'Usuário registrado com sucesso!'}, status=status.HTTP_201_CREATED)
        else:
            print("❌ ERROS NO REGISTRO:", serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Endpoint de login
class LoginView(APIView):
    def post(self, request):
        cpf = request.data.get('cpf')
        senha = request.data.get('senha')

        try:
            client = Client.objects.get(cpf=cpf)
            dta_nasc = client.nascimento

            if check_password(senha, client.senha):
                refresh = RefreshToken.for_user(client)

                # Adiciona informações extras no token
                refresh['cpf'] = cpf
                refresh['nascimento'] = str(dta_nasc)
                refresh['user_id'] = client.id  # Adicionado para fallback no backend

                return Response({
                    'mensagem': 'Login realizado com sucesso!',
                    'access': str(refresh.access_token),
                    'refresh': str(refresh),
                    'nome': client.nome,
                    'cpf': client.cpf,
                    'email': client.email
                })

            return Response({'erro': 'Senha incorreta'}, status=status.HTTP_401_UNAUTHORIZED)

        except Client.DoesNotExist:
            return Response({'erro': 'CPF não encontrado'}, status=status.HTTP_404_NOT_FOUND)

# Endpoint que chama a API de valores do Alyson
class ValoresReceberView(APIView):
    def post(self, request):
        print("CHAMADA OK - HEADERS:", request.headers)

        auth_header = request.headers.get('Authorization')

        if not auth_header or not auth_header.startswith('Bearer '):
            return Response({'erro': 'Token ausente ou mal formatado'}, status=401)

        token = auth_header.replace('Bearer ', '')

        try:
            decoded = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])

            cpf = decoded.get('cpf')
            nascimento = decoded.get('nascimento')

            if not (cpf and nascimento):
                user_id = decoded.get('user_id')
                if not user_id:
                    return Response({'erro': 'Token inválido. Sem user_id.'}, status=401)

                try:
                    client = Client.objects.get(id=user_id)
                    cpf = client.cpf
                    nascimento = str(client.nascimento)
                except Client.DoesNotExist:
                    return Response({'erro': 'Usuário não encontrado.'}, status=404)

            params = {
                "cpf": cpf,
                "dta_nasc": nascimento
            }

            resposta = requests.get(
               "http://localhost:8090/valores-a-receber/valores",
                params=params,
                timeout=5
            )

            print("✅ RESPOSTA DA API EXTERNA:", resposta.text)

            if resposta.status_code == 200:
                return Response(resposta.json(), status=200)
            else:
                return Response({
                    'erro': 'Erro ao chamar a API externa',
                    'detalhes': resposta.text
                }, status=502)

        except jwt.ExpiredSignatureError:
            return Response({'erro': 'Token expirado'}, status=401)
        except jwt.InvalidTokenError:
            return Response({'erro': 'Token inválido'}, status=401)
        except Exception as e:
            import traceback
            print("❌ ERRO INTERNO AO CHAMAR A API DE VALORES:")
            print(str(e))
            traceback.print_exc()
            return Response({'erro': f'Erro inesperado: {str(e)}'}, status=500)

# (opcional: não precisa mais se estiver usando LoginView acima)
class CustomLoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer
