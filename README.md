# Guia de Turismo

App em Flutter da disciplina de Desenvolvimento Mobile.

## Funcionalidades
- Login com e-mail/senha e com conta Google (Firebase), sessão salva e logout
- Lista de lugares
- Cadastro de lugar com foto (câmera ou galeria)
- Tema claro e escuro
- Mapa com os lugares cadastrados (pin com foto) e a localização do usuário (GPS)
- Distância até cada lugar, favoritos, filtro por categoria e botão "Como chegar"
- Busca de endereço ou CEP no mapa para pegar a latitude e longitude no cadastro

## APIs
- https://guia.liliaborges.com.br/api-docs/
- Nominatim (OpenStreetMap) para a busca de endereço

## Como rodar
```
flutter pub get
flutter run -d chrome
```
