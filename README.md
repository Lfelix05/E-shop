# E-Shop

E-Shop é um app Flutter simples de e-commerce, feito para rodar bem em web/mobile e ser fácil de explicar. O projeto usa produtos da MockShop API, autenticação Firebase, endereço salvo no Firestore e um carrinho em memória.

## Tecnologias

- Flutter com Material 3 para interface.
- Dart como linguagem principal.
- Firebase Core para inicialização do Firebase.
- Firebase Auth para login, cadastro e acesso como visitante anônimo.
- Cloud Firestore para salvar usuários e endereços.
- flutter_dotenv para carregar as chaves do Firebase a partir do `.env`.
- http para consumir a MockShop API.
- crypto para gerar hash da senha antes de salvar o documento do usuário.

## Configuração

O app lê variáveis de ambiente em `.env`. O arquivo precisa seguir o formato de `.env.example`, com as chaves Firebase de web, Android e Windows.

O `.env` está declarado como asset no `pubspec.yaml`, porque `main.dart` executa:

```dart
await dotenv.load(fileName: '.env');
```

## Fluxo do App

1. `WelcomeView` mostra a entrada do app.
2. O usuário pode entrar, criar conta ou continuar como visitante.
3. Após autenticar, o app abre `MainShell`.
4. `MainShell` mantém as abas principais em um `IndexedStack`:
   Home, Carrinho, Checkout e Cliente.
5. A barra inferior usa `NavigationBar` e mostra badge com a quantidade do carrinho.

## Telas

- `welcome.dart`: tela inicial com opções de login, cadastro e visitante.
- `login.dart`: login com Firebase Auth e leitura do usuário em `users/{uid}`.
- `register.dart`: cadastro com Firebase Auth e criação do documento do usuário no Firestore.
- `main_shell.dart`: estrutura principal com navegação inferior.
- `home.dart`: lista produtos da MockShop e filtra por `Men`, `Women` e `Unisex`.
- `product_detail.dart`: mostra detalhes do produto, variantes e botão para adicionar ao carrinho.
- `cart.dart`: mostra itens, quantidade, subtotal, total e ações para continuar comprando ou ir ao checkout.
- `checkout.dart`: mostra resumo do pedido, endereço de entrega e simula a finalização.
- `profile.dart`: mostra o cliente, salva/carrega endereço e permite sair da conta.
- `widgets.dart`: helpers visuais reutilizáveis, como imagem de produto e formatação de preço.

## MockShop API

A integração fica isolada em `lib/services/mock_shop_service.dart`.

O app chama `POST https://mock.shop/api` com GraphQL e busca até 24 produtos. Para cada produto, o service carrega:

- id
- title
- description
- vendor
- productType
- featuredImage
- primeira collection
- menor preço
- até 10 variantes

O parser fica em `Product.fromMockShopNode`. A categoria exibida usa a primeira opção disponível entre collection, productType e vendor. As variantes são representadas por `ProductVariant`.

## Firebase e Banco de Dados

O Firebase é inicializado em `main.dart` usando `DefaultFirebaseOptions.currentPlatform`.

O Firestore é usado em dois pontos:

- `users/{uid}`: criado no cadastro com nome, email e hash da senha.
- `addresses/{userId}`: criado ou atualizado em `Database.saveAddress`.

O endereço é carregado em `Database.getAddress`. O app guarda apenas um endereço por usuário, mantendo o fluxo simples.

## Carrinho e Checkout

O carrinho é controlado por `CartController`, um singleton com `ChangeNotifier`.

Ele mantém os itens apenas em memória. Isso significa que o carrinho é perdido ao recarregar o app. Essa escolha é intencional para manter o projeto simples.

O checkout não faz pagamento real e não grava pedido no banco. Ele valida se existe endereço, simula a conclusão e limpa o carrinho.

## Práticas Usadas

- KISS: estado local simples e `ChangeNotifier` nativo, sem gerenciador externo.
- YAGNI: sem pagamento real, sem persistência de carrinho e sem histórico de pedidos.
- DRY: componentes compartilhados ficam em `widgets.dart`, e acesso a Firestore fica em `Database`.
- Responsabilidades separadas: API em `services`, dados em `models` e telas em `view`.

## Como Rodar

```bash
flutter pub get
flutter run -d chrome
```

Para gerar build web:

```bash
flutter build web
```

## Validação Recomendada

```bash
dart format .
flutter analyze
flutter build web
```

No estado atual, `flutter analyze` não aponta issues e a aplicação compila para web.
