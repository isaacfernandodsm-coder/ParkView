# ParkView 0.1 — protótipo de navegador e teste de vídeo

O pacote contém código-fonte, um projeto Xcode e um vídeo de teste. **Não contém um IPA compilado.** A compilação e o teste em iPhone/central ainda estão pendentes. O ambiente em que o projeto foi criado é Linux e não possui Xcode nem SDK de iOS.

**Se você não tem Mac:** leia `SEM-MAC.md`. O pacote inclui um workflow para compilar em um Mac remoto do GitHub Actions e baixar o IPA usando o navegador do Windows. A execução remota ainda não foi realizada.

## O que foi implementado

- Navegador HTTPS no iPhone, com atalho para o site móvel do YouTube, voltar e recarregar.
- WKWebView configurado para permitir AirPlay de mídia, caso o site e o destino disponibilizem esse recurso.
- Player AVPlayer/AVPlayerViewController para URLs diretas de mídia compatível e um vídeo de teste local H.264/AAC de 8 segundos.
- Seletor AirPlay que prioriza destinos de vídeo.
- Diagnóstico local de rota de áudio, eventos de player e, na variante CarPlay autorizada, capacidade anunciada pela central.
- Relatório compartilhável sem histórico de URLs, cookies ou links de mídia.
- Variante CarPlay mínima com template de lista e teste de reprodução, condicionada à capacidade oficial de vídeo.

Não é um desbloqueador de CarPlay. O navegador roda no iPhone. A transmissão da mídia é diferente do espelhamento da página. Não há navegador livre renderizado na tela do carro, extração de links do YouTube, acesso a API privada ou substituição do sinal de estacionamento.

## Dois alvos no Xcode

| Alvo / Scheme | Uso | Dependência de assinatura |
|---|---|---|
| `ParkView` | Navegador e player no iPhone; tentativa normal de AirPlay | Pode ser compilado e depois assinado pelo AltStore Classic; não tem entitlement CarPlay |
| `ParkViewCarPlay` | Protótipo do app de vídeo na central compatível, com lista de teste | SDK iOS 27; `com.apple.developer.carplay-video` aprovado pela Apple e incluído no perfil e na assinatura |

Reassinar a variante CarPlay com um perfil pessoal que não possui a permissão não preserva magicamente essa capacidade. O resultado pode ser falha de instalação, ausência do ícone ou falha de abertura. A aprovação de um app por si só não transforma uma central incompatível em receptora de vídeo.

## Como gerar o IPA para o AltStore

Em um Mac com Xcode completo e SDK iOS, extraia o ZIP e abra `ParkView.xcodeproj`. O alvo `ParkView` usa APIs disponíveis desde iOS 16; para o alvo `ParkViewCarPlay`, use Xcode com SDK iOS 27 ou posterior.

Para gerar a variante de iPhone sem assinatura, abra o Terminal na pasta do projeto e execute:

```bash
bash build-ipa-altstore.sh
```

Se a compilação passar, o arquivo será criado em `Output/ParkView-AltStore.ipa`. Copie-o para o iPhone e importe no AltStore Classic, que fará a assinatura segundo as condições da sua conta. A capacidade de instalar esse IPA não concede suporte CarPlay à variante de iPhone.

O script precisa ser executado no Mac; AltServer no Windows pode instalar/reassinar um IPA já compilado, mas não substitui o compilador e o SDK de iOS. Não inclua certificados, senhas ou Apple ID neste projeto.

Para a variante oficial CarPlay, solicite a categoria vídeo para o Bundle ID do alvo, configure a equipe autorizada em Signing & Capabilities, gere o perfil com a capacidade e compile/instale pelo fluxo autorizado do Xcode. Se mudar o Bundle ID, use o mesmo identificador na solicitação e no perfil. Esse processo não foi executado e não há aprovação presumida.

## Como testar, já estacionado

1. Conecte o iPhone à central como normalmente usa o CarPlay.
2. No ParkView, abra **Vídeo / AirPlay → Reproduzir vídeo de teste local**.
3. Confirme o uso estacionado. Essa confirmação é uma declaração manual, não um sensor de movimento ou uma prova de marcha P.
4. Abra o seletor AirPlay e observe se a central aparece como destino de vídeo. Se ela oferecer apenas áudio, isso não confirma compatibilidade com vídeo.
5. Na aba Diagnóstico, compartilhe o relatório para comparar o resultado. A variante de iPhone indicará capacidade CarPlay desconhecida; ela não deve inventar `true`/`false` sem uma sessão autorizada.
6. Só depois teste YouTube na aba Navegador. O controle de AirPlay, quando oferecido, é o do player do site. Disponibilidade, login e playback dentro de WKWebView variam por serviço e precisam ser testados.
7. Com a variante CarPlay autorizada, verifique `supportsVideoPlayback`. Esse valor descreve capacidade, não se o carro está atualmente estacionado. A interrupção de imagem é aplicada pelo sistema/veículo.

O vídeo de teste foi gerado localmente para separar problemas de transmissão de problemas do site ou da conexão de internet. Um arquivo local reproduzindo no iPhone não comprova que a central o aceita por AirPlay.

## Verificação realizada

Foram verificados os arquivos plist e entitlements, a estrutura e referências do projeto Xcode, os schemes, a sintaxe do script de compilação, as trilhas H.264/AAC do vídeo e a integridade do ZIP. Isso não equivale a compilar Swift com o SDK de iOS. Compilação, UI no dispositivo, assinatura AltStore, CarPlay Simulator e teste físico da central estão pendentes.

Leia `ANALISE-CARPLAY-IOS-27.2.md` para evidências, hipóteses e a sequência de diagnóstico.
