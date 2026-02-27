# Manifest Schema Notes (DATA_CONTRACT_V1)

Source of truth: `engineering/DATA_CONTRACT_V1.json`

## Fields
| Field | Type | Description | Client handling |
| --- | --- | --- | --- |
| `version` | `string` | Schema version. Must equal `v1`. | `ManifestValidator` rejects everything else and logs reason. |
| `generatedAt` | `ISO-8601 datetime` | Build timestamp of the manifest. | Parsed via `JSONDecoder.dateDecodingStrategy = .iso8601`. |
| `items[].id` | `string` | Stable content identifier (`item_id` from index). | Used as diffable data source key + MSMessage metadata. |
| `items[].imageUrl` | `https URL` | Full resolution asset. | Downloaded when inserting message. |
| `items[].thumbnailUrl` | `https URL` | Grid thumbnail. | Loaded lazily for cell preview; falls back to `imageUrl` if absent in exporter. |
| `items[].tags` | `string[]` | Search keywords/mood tags. | `HamsterItem.matches` filters over this list. |
| `items[].popularity` | `int >= 0` | Sort weight derived from pipeline `popularity_score`. | Grid sorted desc + tie-breaker by `createdAt`. |
| `items[].createdAt` | `ISO-8601 datetime` | When hamster was created/scraped. | Used for UI tie-breaker + debugging. |
| `items[].source.platform` | `string` | Origin platform (`instagram`). | Display + troubleshooting. Must be lowercase. |
| `items[].source.account` | `string` | Handle/creator. | Searchable text. |
| `items[].source.postId` | `string` | Platform-specific slug. | Helps recover CDN asset lineage. |

## Validation layers
1. **Exporter (`scripts/export-approved-pack.js`)** – maps crawler output to contract fields, enforces type checks before writing.
2. **CI / manual (`scripts/validate-manifest.js`)** – lightweight guard for any manifest artifact.
3. **Runtime (`ManifestValidator`)** – prevents bad remote payloads from poisoning cache; error surfaces to the UI.

## Migration guidance
- For additive fields, bump contract to `v2`, duplicate this file with the new schema, and update `ManifestValidator` + exporter simultaneously.
- The client caches the full manifest JSON, so backwards-incompatible changes require a new binary release.
