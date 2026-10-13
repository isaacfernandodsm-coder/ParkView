# Gerar o IPA usando somente o navegador do Windows

Foi incluída uma configuração de GitHub Actions para compilar o alvo `ParkView` em um Mac remoto e disponibilizar o IPA para download. Você não precisa ter um Mac. O código permanece um protótipo: a configuração foi verificada localmente, mas a compilação remota ainda não foi executada.

## 1. Enviar o projeto

1. Entre em [github.com](https://github.com/) e crie uma conta, caso ainda não tenha.
2. Crie um repositório chamado `parkview`. Você pode escolher privado; nesse caso a execução usa a franquia de Actions da sua conta e pode ter cobrança se ela for excedida. Runners padrão são gratuitos em repositórios públicos, mas o código fica público. Confira a franquia antes de executar se escolher privado.
3. Extraia este ZIP no Windows. Entre na pasta `ParkView`.
4. No repositório, clique em **Add file → Upload files**. Arraste as pastas `Sources`, `Config`, `Resources`, `ParkView.xcodeproj` e o arquivo `build-ipa-altstore.sh`. Clique em **Commit changes**. Envie os arquivos extraídos; não envie apenas o ZIP.
5. Crie o workflow na raiz do repositório: **Add file → Create new file**. No campo do nome, escreva exatamente `.github/workflows/build-ipa.yml`.
6. Abra `WORKFLOW-PARA-COPIAR.txt` deste pacote no Bloco de Notas, copie todo o conteúdo e cole no editor do GitHub. Clique em **Commit changes** na branch principal.

Se preferir usar Git no PC, também pode enviar diretamente todo o conteúdo da pasta `ParkView`, incluindo `.github`. O workflow deve ficar na raiz do repositório em `.github/workflows/build-ipa.yml`; não em `ParkView/.github/...` dentro do repositório.

## 2. Gerar e baixar

1. Abra a aba **Actions** do repositório.
2. Escolha **Gerar IPA para AltStore**.
3. Clique em **Run workflow → Run workflow**.
4. Aguarde o resultado. Uma execução verde indica que a compilação e o empacotamento passaram, não que o app foi testado no iPhone.
5. Abra a execução e, em **Artifacts**, baixe **ParkView-AltStore**.
6. Extraia o download. Ele terá `ParkView-AltStore.ipa` e um arquivo de checksum SHA256.

Se aparecer uma execução vermelha, abra o passo que falhou ou baixe **ParkView-log**. Envie o log para análise. Nenhum IPA foi gerado neste ambiente; a primeira compilação pode revelar ajustes necessários no Swift/SDK. A configuração atual usa runner macOS 15 padrão e compila somente a variante de iPhone, com APIs públicas disponíveis desde iOS 16.

## 3. Instalar

Transfira o IPA para o iPhone e importe no AltStore Classic. Como você já usa o AltStore, siga o fluxo de instalação que funciona no seu PC. O IPA do workflow é compilado sem assinatura; o AltStore deverá reassiná-lo. Este workflow não pede Apple ID, senha, certificado ou perfil de provisionamento e não precisa dessas credenciais no GitHub.

## O que esse caminho resolve

Ele substitui o Mac local na etapa de compilação. **Não concede o entitlement CarPlay, não transforma uma central incompatível em receptora de vídeo e não envia a página inteira do navegador para o CarPlay.** A variante compilada é navegador/player no iPhone com tentativa normal de AirPlay, não a variante oficial `ParkViewCarPlay`.

O app solicita uma declaração manual de uso estacionado no iPhone. Essa declaração não verifica marcha P. A disponibilidade de imagem na saída CarPlay oficial é controlada pelo iOS e pelo equipamento.

Fontes verificadas em 13/10/2026:

- [GitHub — runners macOS e condições de uso](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
- [GitHub — Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions)
- [GitHub — checkout](https://github.com/actions/checkout)
- [GitHub — upload-artifact](https://github.com/actions/upload-artifact)
- [AltStore — instalação no Windows](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows)
