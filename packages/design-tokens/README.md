# @repo/design-tokens

Source de vérité unique des tokens de design du produit, au format **DTCG**, compilés en Swift
consommable par l'app SwiftUI.

**Fichier Figma source :** [Netflix (Community) (Copy)](https://www.figma.com/design/G8762C57vtIVBYWU6n3OJl/)
— `fileKey` `G8762C57vtIVBYWU6n3OJl`, page unique « Page 1 », 17 écrans iPhone X.

```
Figma (Variables / Tokens Studio)
        │  export JSON DTCG
        ▼
   tokens/core      tokens/semantic
        └──────────────┬──────────────┘
                       │  style-dictionary + formats maison
                       ▼
        platforms/swift/Sources/DesignTokens/*.swift   (versionné)
```

## Arborescence

| Chemin             | Rôle                                                                          |
| ------------------ | ----------------------------------------------------------------------------- |
| `tokens/core/`     | Primitifs bruts, sans sémantique : `core.color.red.60`, `core.dimension.200`. |
| `tokens/semantic/` | Alias vers les primitifs, porteurs d'intention : `color.background.primary`.  |
| `src/formats/`     | Formatters Swift (fonctions pures) et leur adaptateur Style Dictionary.       |
| `platforms/swift/` | Package SPM **généré** — ne jamais éditer à la main.                          |

## Règles

1. **Le code applicatif ne consomme que les tokens `semantic`.** Les tokens `core` ne sortent pas de
   ce package : ils ne sont pas générés en Swift. C'est ce qui permet de rethémer (dark mode,
   co-branding) sans toucher une ligne de Swift.
2. **`tokens/` n'est jamais édité à la main.** On modifie dans Figma, on ré-exporte, on rejoue le
   build. Toute édition manuelle sera écrasée au prochain export.
3. **`platforms/` est généré mais versionné.** Xcode lit des fichiers réels et ne lance pas `pnpm`.
   Le script `tokens:check` échoue en CI si la sortie committée diffère de la régénération.
4. **Convention de nommage :** `categorie.groupe.variante`, en camelCase par segment. La catégorie
   (premier segment) donne le fichier Swift ; le reste donne le nom du membre.
   `color.background.primary` → `Color.backgroundPrimary`, `spacing.md` → `Spacing.md`.

## Provenance des valeurs — à lire avant de modifier

Le fichier Figma **ne contient ni Figma Variables ni styles publiés** : un seul style nommé
(« SF / Subheadline - Semibold ») et aucun auto-layout. Les tokens n'ont donc pas la même origine
selon l'axe, et c'est délibérément explicite :

| Axe                       | Origine                                                                                                                                                                                                     | Fiabilité                                                                                  |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| **Couleurs**              | Extraites de ~1000 fills réels du fichier, comptées et classées par rôle d'usage.                                                                                                                           | **Données Figma.** Les `$description` portent le nombre d'usages.                          |
| **Typographie**           | Les 56 styles du fichier ont des tailles fractionnaires (`20.92117691040039px`) issues de frames mises à l'échelle — inexploitables. Mappés sur les **text styles système iOS**, ce que visait le designer. | **Décision d'équipe**, alignée sur l'intention du fichier.                                 |
| **Espacements**           | Aucun auto-layout dans le fichier → `itemSpacing` et `padding` remontent zéro valeur. Grille **8pt** (Apple HIG).                                                                                           | **Convention d'équipe**, pas une donnée Figma.                                             |
| **Rayons**                | 26 valeurs fractionnaires. Seul `radius.sm = 2px` reprend la valeur dominante réelle (317 usages) ; les autres suivent la grille 8pt.                                                                       | **Mixte**, documenté token par token.                                                      |
| **Couleurs de connexion** | Dégradé de fond, surface et bordure des champs, relevés au pixel sur la maquette de l'écran de connexion fournie séparément.                                                                                | **Mesuré sur maquette**, pas extrait du fichier Figma — chaque `$description` le rappelle. |

Conséquence pratique : on peut **retoucher librement** la typographie et les espacements, ce sont nos
conventions. Toucher aux couleurs, en revanche, c'est s'écarter du design — à faire sciemment.

## Typographie : pourquoi les styles système

Les tokens typographiques ne portent pas de taille en points, mais un **text style iOS**
(`largeTitle`, `headline`, `caption2`…) plus une graisse. L'app hérite du **Dynamic Type** : les
textes suivent les réglages d'accessibilité de l'utilisateur, ce qu'une taille figée interdit.

Un token ne peut pas porter le nom d'un membre `Font` de SwiftUI (`body`, `headline`, `caption`…) :
il masquerait l'API système et `.font(.body)` se résoudrait silencieusement vers le token. Le
formatter **refuse** ces noms (`formatTextStyles`, `src/formats/swift.ts`) — d'où `bodyText`,
`cardTitle`, `captionLabel` plutôt que `body`, `headline`, `caption`.

## Workflow de mise à jour depuis Figma

1. Récupérer l'arbre du fichier : `GET https://api.figma.com/v1/files/G8762C57vtIVBYWU6n3OJl` avec
   un Personal Access Token (scope _File content: read-only_). Le serveur MCP officiel de Figma est
   limité à **20 appels par mois** sur un plan Starter — l'API REST ne l'est pas.
2. Recompter les couleurs par rôle d'usage plutôt que de les relever à l'œil.
3. Mettre à jour `tokens/core/` puis `tokens/semantic/`.
4. `pnpm --filter @repo/design-tokens build`
5. Committer `tokens/` **et** `platforms/` dans le même commit.

## Consommation côté Swift

`platforms/swift` est un package SPM (`Package.swift` fourni). Dans Xcode :
_File → Add Package Dependencies → Add Local…_ et pointer sur
`packages/design-tokens/platforms/swift`.

```swift
import SwiftUI
import DesignTokens

struct HeroTitle: View {
  var body: some View {
    Text("Continuer à regarder")
      .font(.sectionTitle)
      .foregroundStyle(Color.textPrimary)
      .padding(.horizontal, Spacing.md)
      .background(Color.backgroundPrimary)
      .clipShape(.rect(cornerRadius: Radius.md))
  }
}
```

## Scripts

| Commande            | Effet                                                        |
| ------------------- | ------------------------------------------------------------ |
| `pnpm build`        | Régénère `platforms/swift/**` depuis `tokens/**`.            |
| `pnpm test`         | Tests unitaires des formatters Swift.                        |
| `pnpm tokens:check` | Échoue si la sortie générée n'est pas à jour (garde-fou CI). |
| `pnpm check-types`  | Typage TypeScript.                                           |

## Ajouter une plateforme (CSS, TypeScript, Android)

Ajouter une entrée dans `platforms` de `style-dictionary.config.ts`. Les formats Swift maison vivent
dans `src/formats/` ; les formats intégrés de Style Dictionary (`css/variables`, `javascript/es6`)
peuvent être utilisés tels quels sans nouveau code.
