# INDEXER_CONFIG_V1.md

App: OpenClaw Hamster iMessage
Template Base: INDEXER_TEMPLATE_V1

## Source
- platform: Instagram
- account: almarts27
- scope: public posts accessible via allowed session

## Relevance Gate
A post is relevant if ANY slide contains hamster drawing content.

## Extraction
For each relevant post:
- collect all slides/media
- capture caption, post URL, timestamp
- store checksum per slide

## Tag Schema
- hamster_type
- expression
- outfit/accessories
- setting
- art_style
- mood
- meme_intent

## Search Behavior
- fuzzy text + embedding hybrid
- query examples: "sad hoodie hamster", "angry hamster night"

## Ranking
- default: relevance + popularity + recency
- user can toggle sort: latest | popular | semantic-best

## Update Cadence (initial)
- light watch: every 4h
- deep process: only new/changed posts
- daily rebuild: 1x overnight

## Outputs
- index db/json for iMessage app consumption
- asset manifest
- daily changes summary

## Constraints
- do not process private/blocked content without valid session access
- avoid full-history rescans unless manually triggered
