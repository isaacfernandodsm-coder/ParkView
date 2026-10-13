# Vídeo no CarPlay e iOS 27.2 beta

Pesquisa em 13/10/2026. Caso informado: central instalada, vídeo acessado antes por app/navegador e iPhone agora no iOS 27.2 beta. Modelo da central, firmware, app utilizado, beta/build exato e logs ainda não foram informados.

## Resultado da investigação

Há um caminho público para vídeo quando estacionado: AirPlay de mídia em uma central que implemente o recurso, ou um app da categoria CarPlay Video autorizado pela Apple. Não foi encontrado um contorno universal, verificado, capaz de restaurar um navegador livre na tela de qualquer central no iOS 27.2. Instalar um IPA pelo AltStore resolve a distribuição do app de iPhone, mas não concede as permissões especiais nem altera as capacidades da central.

Esta é uma análise documental com um protótipo de diagnóstico. Não é engenharia reversa de um firmware específico: não houve acesso ao iPhone, binários do sistema, app anterior ou logs da central. As notas do 27.2 foram localizadas, mas seu conteúdo integral não ficou acessível pelo mecanismo de consulta; não há base para afirmar que elas confirmam ou excluem a mudança relatada.

## O que está confirmado

**A versão existe.** O índice oficial da Apple lista iOS 27.2 beta 3, compilação 24B5099f, em 05/10/2026. Isso não identifica automaticamente qual beta está instalada no seu aparelho. [1]

**Vídeo continua previsto oficialmente.** A página CarPlay da Apple descreve apps de vídeo e AirPlay para carros compatíveis quando não estão dirigindo. Logo, a falha relatada não demonstra que a categoria inteira tenha sido removida. [2]

**Suporte da central é obrigatório.** Um engenheiro DTS da Apple explica que a central precisa anunciar explicitamente a capacidade de vídeo; uma central comum de áudio/navegação pode não anunciá-la. Ele identifica `CPSessionConfiguration.supportsVideoPlayback` como consulta pública e registra também um problema de tela em branco em betas anteriores do iOS 27. Esse problema anterior não comprova a causa da regressão no 27.2. [3]

**Capacidade não é autorização momentânea.** Um engenheiro de frameworks da Apple esclarece que a disponibilidade de vídeo pode ser retirada a qualquer momento e que o sistema aplica a mudança, com reprodução somente de áudio. O valor `supportsVideoPlayback` informa que a sessão pode suportar vídeo; não informa marcha P nem constitui uma confirmação atual de estacionamento. [4]

**A categoria vídeo não oferece uma tela arbitrária de navegador.** Na apresentação técnica WWDC26, a Apple descreve uma experiência de seleção de conteúdo por templates CarPlay e reprodução por AirPlay. As APIs de templates apresentadas não fornecem um espaço genérico para colocar o WKWebView do iPhone na central. Concluir que o navegador anterior usava um caminho não documentado exige conhecer o app e sua implementação; isso permanece uma hipótese. [5]

**Assinatura importa.** O guia oficial exige obter o entitlement e gerar um perfil com a capacidade CarPlay. A chave de vídeo é `com.apple.developer.carplay-video`. Escrever essa chave num arquivo local não autoriza a assinatura. A documentação do AltStore distingue o Classic, que reassina IPAs e tem capacidades limitadas, da distribuição por marketplace. [6][7]

## Evidências de sintomas semelhantes

Na página do APTV há relatos diretos de usuários sobre falha no 27.2 beta 2 e desaparecimento da aba Quick no CarPlay, datados de 30/09 e 03/10. São evidências de experiências relatadas, não uma análise do código do iOS nem confirmação técnica da Apple. [8]

Nas avaliações do CarTV, um usuário relata falha no 27.2 beta. Em resposta a outro caso, de mensagem de incompatibilidade com vídeo AirPlay em um HB20, o desenvolvedor informa uma correção planejada para 1.1.2. A listagem atual já mostra essa versão, porém o changelog consultado não confirma restauração universal de transmissão no 27.2. Vale verificar o app anterior antes de atribuir tudo ao sistema. [9][10]

## Hipóteses para seu caso

| Hipótese | Por que é plausível | Como distinguir |
|---|---|---|
| O app anterior dependia de uma interface que mudou ou deixou de ser aceita | Você abria um app/navegador na central; há relatos de perda de funções semelhantes | Identificar o app e sua versão; comparar mídia nativa com navegador |
| O iOS passou a negociar/verificar de outra forma a capacidade da central | Suporte precisa ser anunciado pelo equipamento; atualização do iPhone não atualiza o firmware da central | Testar sessão autorizada e capacidade anunciada; confirmar firmware com fabricante |
| A central não está fornecendo uma autorização válida de vídeo estacionado | Parar fisicamente não implica que o iPhone receba o estado correto | Comparar a mesma central com outro iPhone/versão; testar suporte oficial; consultar fabricante |
| Regressão da beta em vídeo, rota ou conexão | Betas anteriores tiveram problemas reconhecidos; a mudança temporal é compatível | Reproduzir com vídeo local e outra central oficialmente compatível; registrar build e logs |
| Restrição ou falha do site/player | YouTube dentro de navegador não equivale a um arquivo MP4/HLS direto | Vídeo local funciona, mas o site não |

Essas hipóteses não têm probabilidades mensuradas. Sem app, modelo e comparação controlada, afirmar que a Apple “fechou uma brecha específica” seria especulação.

## Contornos que podem ser úteis

**Trocar a interface anterior por reprodução nativa de mídia** pode resolver uma incompatibilidade do navegador se AirPlay de vídeo continuar disponível. É a alternativa implementada no protótipo. Não resolve ausência da capacidade de vídeo da central.

**Atualizar o app anterior ou firmware da central**, conforme a documentação do fornecedor, pode corrigir uma negociação ou um erro de detecção. Não instale firmware de outro modelo e não altere entradas de marcha/freio para simular estacionamento. O modelo exato determina qual atualização se aplica.

**Usar o navegador nativo da própria central**, caso ela seja Android e já ofereça essa função para uso estacionado, é uma via independente do app CarPlay do iPhone. Só o fato de a central ter sido instalada depois não informa seu sistema operacional ou recursos; essa possibilidade precisa ser confirmada.

**Criar um app CarPlay Video oficial** é viável como projeto, mas exige aprovação da categoria, assinatura apropriada e central compatível. Ele oferece seleção de mídia e reprodução autorizada, não a garantia de exibir qualquer site. A instalação via AltStore com um perfil sem essa permissão não substitui o processo.

Não foi encontrado um “ajuste secreto” público e comprovado que um app comum possa executar para forçar suporte a vídeo ou autorizar um navegador livre. Também não foi determinada uma versão para downgrade: isso dependeria do modelo, assinatura disponível e compatibilidade de backup, informações ainda ausentes.

## Diagnóstico recomendado

Primeiro, anote versão/build em Ajustes → Geral → Sobre → Versão do iOS, marca/modelo/firmware da central, nome/versão do app que funcionava e se a conexão usa cabo ou Wi-Fi. Se há adaptador entre o iPhone e a central, inclua seu modelo.

Com o carro estacionado, compare:

| Teste | Resultado | Interpretação limitada |
|---|---|---|
| Padrão local H.264/AAC no iPhone | Falha | Corrigir o protótipo/player antes de investigar transmissão |
| Mesmo padrão para a central | Destino de vídeo ausente | Não há rota de vídeo exposta nesse contexto; ainda não identifica sozinho a causa |
| Mesmo padrão para a central | Som sem imagem | Investigar disponibilidade de vídeo e implementação da central; áudio não prova suporte a vídeo |
| Padrão funciona, YouTube não | Falha específica do site | Investigar o player, WKWebView e compatibilidade de AirPlay do serviço |
| Outro iPhone funciona na mesma central/app | Diferença por versão/aparelho | Indício forte para comparar build/configuração, não prova isolada de mudança intencional |
| Mesmo iPhone funciona em outra central compatível | Diferença por central | Indício para firmware ou implementação do equipamento |

Faça uma comparação por vez, sem mudar app, cabo e firmware simultaneamente. Se a central anuncia capacidade e o teste local falha somente no 27.2, os resultados e logs sustentam um relatório de regressão via Feedback Assistant. Não envie contas, senhas ou cookies ao coletar evidências.

## Entrega do protótipo e limites

O projeto ParkView contém navegador no iPhone com mídia AirPlay permitida, player nativo, seletor de destino e teste local, além de uma variante mínima CarPlay para assinatura autorizada. A aba Diagnóstico evita confundir rota `carAudio`, capacidade de vídeo e estado estacionado.

Não houve compilação no SDK de iOS nem testes em iPhone, AltStore ou central. O ZIP contém código-fonte e instruções para gerar um IPA em Mac com Xcode; não contém um IPA pronto. A confirmação manual de uso estacionado na interface do iPhone não é bloqueio automático de movimento. Na saída CarPlay oficial, o iOS e o veículo continuam responsáveis pela disponibilidade da imagem. O objetivo final — navegador na tela da sua central funcionando no 27.2 — permanece dependente da identificação do equipamento e de uma rota suportada; não foi demonstrado pelo protótipo.

## Fontes primárias

1. [Apple — Releases](https://developer.apple.com/news/releases/)
2. [Apple — CarPlay, incluindo Video in the car](https://developer.apple.com/carplay/)
3. [Apple DTS — suporte de central e bug de tela em branco](https://developer.apple.com/forums/thread/843374)
4. [Apple Frameworks — reprodução, capacidade e estado de disponibilidade](https://developer.apple.com/forums/thread/838529)
5. [Apple WWDC26 — Rev up your CarPlay app](https://developer.apple.com/videos/play/wwdc2026/212/)
6. [Apple — CarPlay Developer Guide, 08/06/2026](https://developer.apple.com/download/files/CarPlay-Developer-Guide.pdf) — trechos indexados sobre chave de entitlement e perfil; PDF integral não extraído nesta pesquisa.
7. [AltStore — PAL versus Classic](https://faq.altstore.io/altstore-pal-v.-altstore-classic)
8. [APTV — listagem, avaliações e histórico do desenvolvedor](https://apps.apple.com/br/app/aptv/id1630403500)
9. [CarTV — avaliações e resposta do desenvolvedor](https://apps.apple.com/br/app/cartv-iptv-m3u-carro/id6800211040?see-all=reviews&platform=ipad)
10. [CarTV — versão e changelog](https://apps.apple.com/br/app/cartv-iptv-m3u-carro/id6800211040)
11. [Apple — allowsAirPlayForMediaPlayback em WKWebViewConfiguration](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/allowsairplayformediaplayback)
12. [Apple — AVRoutePickerView e AirPlay](https://developer.apple.com/videos/play/wwdc2019/501/)
13. [Apple — iOS & iPadOS 27.2 release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27_2-release-notes) — página identificada; conteúdo integral inacessível na consulta.
