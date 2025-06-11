from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin


class ClientManager(BaseUserManager):
    def create_user(self, cpf, senha=None, **extra_fields):
        if not cpf:
            raise ValueError("O CPF e obrigatorio.")
        user = self.model(cpf=cpf, **extra_fields)
        user.set_password(senha)
        user.save(using=self._db)
        return user

    def create_superuser(self, cpf, senha, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(cpf, senha, **extra_fields)


class Client(AbstractBaseUser, PermissionsMixin):
    nome = models.CharField(max_length=100)
    cpf = models.CharField(max_length=11, unique=True)
    email = models.EmailField(unique=True)
    nascimento = models.DateField()

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = ClientManager()

    USERNAME_FIELD = 'cpf'
    REQUIRED_FIELDS = ['nome', 'email', 'nascimento']

    def __str__(self):
        return self.nome


class ValorReceber(models.Model):
    cpf = models.CharField(max_length=14, unique=True)
    valor = models.DecimalField(max_digits=10, decimal_places=2)
    data_disponivel = models.DateField()

    # Novos campos
    instituicao = models.CharField(
        max_length=100,
        default="Banco XYZ S.A."
    )
    tipo_valor = models.CharField(
        max_length=200,
        default="Conta corrente encerrada com saldo disponivel"
    )
    instrucoes = models.TextField(
        default="Pix automatico para a chave cadastrada ou contato direto com a instituicao."
    )
    prazo = models.CharField(
        max_length=100,
        default="2 dias uteis"
    )

    def __str__(self):
        return f'{self.cpf} - R$ {self.valor} em {self.data_disponivel}'
