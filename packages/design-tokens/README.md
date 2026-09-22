# @repo/design-tokens

Source de vérité unique des tokens de design du produit. Les tokens sont exportés depuis Figma au
format **DTCG** et compilés en Swift consommable par l'app SwiftUI.

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

## Workflow d'export depuis Figma

1. Dans Figma, exporter les variables au format DTCG (plugin **Tokens Studio** ou export natif des
   Figma Variables).
2. Déposer les fichiers dans `tokens/core/` (primitifs) et `tokens/semantic/` (alias).
3. `pnpm --filter @repo/design-tokens build`
4. Committer `tokens/` **et** `platforms/` dans le même commit.

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
      .font(.titleBold)
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
