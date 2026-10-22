# Guia de Turismo

App mobile feito em Flutter na disciplina de Desenvolvimento Mobile (Entrega 1).

## O que o app faz
- Login com e-mail e senha (token JWT)
- Lista os lugares cadastrados
- Cadastra novos lugares (nome, descrição, latitude, longitude e categoria)
- Escolhe uma foto pela câmera ou galeria (só a prévia, ainda não é enviada)
- Alterna entre tema claro e escuro

## API
https://guia.liliaborges.com.br/api-docs/

## Estrutura
- `models`: classes que representam os dados (lugar, categoria)
- `services`: conversam com a API e com o armazenamento do celular
- `controllers`: guardam o estado e avisam as telas (Provider)
- `screens`: as telas do app

## Como rodar
1. `flutter pub get`
2. `flutter run -d chrome`

## Autor
Otávio - Entrega 1
