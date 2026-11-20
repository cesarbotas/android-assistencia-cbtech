# CBTech — Guia de Inicialização do Ambiente

## 1. Pré-requisitos
- **.NET 10 SDK** instalado (`dotnet --version`)
- **Flutter SDK** instalado (`flutter --version`)
- **Docker** e **Docker Compose** instalados (`docker compose version`)

---

## 2. Inicializando os Serviços de Infraestrutura (PostgreSQL & MinIO)
Na raiz do projeto:
```bash
docker compose -f infrastructure/docker/docker-compose.yml up -d
```

Serviços disponibilizados:
- **PostgreSQL 16**: Porta `5432` (Usuário: `cbtech_user`, Senha: `cbtech_password`, DB: `cbtech_db`)
- **MinIO (S3 API)**: Porta `9000` (Console web na porta `9001`)

---

## 3. Executando o Backend (.NET 10)
```bash
cd backend/src/CBTech.Api
dotnet run
```
A API iniciará por padrão em `http://localhost:5176` ou `https://localhost:5001`.
Acesse a documentação Swagger em: `http://localhost:5176/swagger`.

---

## 4. Executando os Testes
```bash
cd backend
dotnet test
```

---

## 5. Executando o Aplicativo Mobile (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```
