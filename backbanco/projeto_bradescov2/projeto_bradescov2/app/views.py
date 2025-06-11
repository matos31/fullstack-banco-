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

        if 'senha' in data:
            data['password'] = make_password(data.pop('senha'))  # Corrige e criptografa

        serializer = ClientSerializer(data=data)

        if serializer.is_valid():
            client = serializer.save()
            print("✅ Registro realizado com sucesso.")

            # Chamada opcional para API externa
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

            # ✅ Usa o método correto herdado de AbstractBaseUser
            if client.check_password(senha):
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
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user

        try:
            client = Client.objects.get(id=user.id)
        except Client.DoesNotExist:
            return Response({'erro': 'Cliente não encontrado'}, status=404)

        cpf = client.cpf  # pegamos só o CPF

        try:
            params = {"cpf": cpf}

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

        except requests.exceptions.RequestException as e:
            return Response({'erro': f'Erro na conexão com a API externa: {str(e)}'}, status=503)
        except Exception as e:
            import traceback
            traceback.print_exc()
            return Response({'erro': f'Erro inesperado: {str(e)}'}, status=500)


# (opcional: não precisa mais se estiver usando LoginView acima)
class CustomLoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer


from .models import ValorReceber
from .serializers import ValorReceberSerializer

class ValoresReceberView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        cpf = request.user.cpf
        try:
            valor = ValorReceber.objects.get(cpf=cpf)
            client = Client.objects.get(cpf=cpf)

            return Response({
                "titular": client.nome,
                "instituicao": valor.instituicao,
                "tipo_valor": valor.tipo_valor,
                "valor": float(valor.valor),
                "instrucoes": valor.instrucoes,
                "prazo": valor.prazo
            }, status=200)

        except ValorReceber.DoesNotExist:
            return Response({'mensagem': 'Nenhum valor a receber cadastrado.'}, status=204)


class AdicionarValorView(APIView):
    def post(self, request):
        required_fields = ['cpf', 'valor', 'data_disponivel', 'instituicao', 'tipo_valor', 'instrucoes', 'prazo']
        missing = [field for field in required_fields if field not in request.data]

        if missing:
            return Response({'erro': f'Campos obrigatórios ausentes: {", ".join(missing)}'}, status=400)

        obj, criado = ValorReceber.objects.update_or_create(
            cpf=request.data['cpf'],
            defaults={
                'valor': request.data['valor'],
                'data_disponivel': request.data['data_disponivel'],
                'instituicao': request.data['instituicao'],
                'tipo_valor': request.data['tipo_valor'],
                'instrucoes': request.data['instrucoes'],
                'prazo': request.data['prazo']
            }
        )

        return Response({'mensagem': 'Valor salvo com sucesso'}, status=200)

