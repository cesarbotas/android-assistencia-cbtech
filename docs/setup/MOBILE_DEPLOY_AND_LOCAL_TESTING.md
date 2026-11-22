# CBTech — Guia de Instalação do APK & Testes em Aparelho Físico

Este documento orienta sobre como gerar o APK do aplicativo **CBTech**, instalá-lo em um smartphone Android físico e conectá-lo ao backend rodando localmente na sua máquina (`localhost:5176`).

---

## 1. Habilitando a Depuração USB no Celular
1. No seu celular Android, vá em **Configurações** > **Sobre o telefone**.
2. Toque 7 vezes em **Número da versão** até habilitar o modo de desenvolvedor.
3. Volte e acesse **Opções do desenvolvedor**.
4. Ative a opção **Depuração USB**.
5. Conecte o celular ao computador via cabo USB e confirme a permissão na tela do aparelho.

---

## 2. Gerando e Instalando o APK

### Forma A: Instalação Direta via Cabo (Desenvolvimento)
Com o celular conectado, verifique o ID do dispositivo:
```bash
flutter devices
```
Para compilar e instalar diretamente no celular:
```bash
flutter run -d <ID_DO_SEU_CELULAR>
```

### Forma B: Gerando o Arquivo `.apk` para Envio Manual
Para gerar o arquivo executável instalável (.apk):
```bash
flutter build apk --debug
```
O arquivo será gerado em:
`build/app/outputs/flutter-apk/app-debug.apk`

Envie este arquivo para o seu celular (via WhatsApp Web, Google Drive ou e-mail) e toque nele para instalar.

---

## 3. Conectando o App ao Backend Local (`localhost:5176`)

Como o backend está rodando no seu computador, o celular físico precisa de uma rota de rede para acessá-lo. Escolha uma das 3 opções abaixo:

### Opção 1: Usando `adb reverse` (Recomendado via USB)
Se o celular estiver conectado via cabo USB, execute no terminal do computador:
```bash
adb reverse tcp:5176 tcp:5176
```
Isso redireciona o tráfego da porta `5176` do celular diretamente para o seu PC. No app, basta selecionar o ambiente **Local** (`http://localhost:5176/api/v1`).

### Opção 2: Usando o IP da Rede Wi-Fi
Se o celular e o computador estiverem na mesma rede Wi-Fi:
1. Descubra o IP local do seu computador (ex: `192.168.1.15`).
2. No app (na tela de login, clicando no seletor de ambiente), configure a URL base apontando para o IP:
   `http://192.168.1.15:5176/api/v1`

### Opção 3: Usando o Ngrok (Para testes remotos / 4G)
Se precisar testar via rede móvel:
1. Execute o ngrok apontando para a porta do backend:
   ```bash
   ngrok http 5176
   ```
2. Copie a URL HTTPS gerada (ex: `https://xxxx-xx.ngrok-free.app`).
3. Cole a URL no seletor de ambiente do app seguida de `/api/v1`.
