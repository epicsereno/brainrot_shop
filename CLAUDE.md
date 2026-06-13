# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A meme-merch e-commerce store (the "Brainrot Shop" catalog). **Rails 8.1.3 on Ruby 3.3.8**, PostgreSQL, Hotwire (Turbo + Stimulus), Propshaft assets. JS is bundled with **esbuild** (jsbundling-rails) and CSS with the **Tailwind v4 CLI** (cssbundling-rails) — builds land in `app/assets/builds/`.

## Commands

```bash
bin/setup                 # install gems + JS deps, prepare DB (idempotent)
bin/dev                   # web + JS + CSS watchers via Foreman (Procfile.dev)
bin/rails server -b 127.0.0.1   # web only — the -b is required (see PRoot note)
bin/rails db:seed         # load the catalog (idempotent; defined in db/seeds.rb)

bin/rails test                                  # full Minitest suite
bin/rails test test/models/product_test.rb      # one file
bin/rails test test/models/product_test.rb:42   # one test by line

bin/rubocop               # lint (rails-omakase)
bin/brakeman              # static security scan
bin/bundler-audit         # dependency CVE check

yarn build                # one-off JS bundle (esbuild)
yarn build:css            # one-off Tailwind build
```

## Architecture

The domain is deliberately small and MVP-shaped:

- **`Product`** (`app/models/product.rb`) — `has_many :variants`, `has_one_attached :image`. Slug is auto-generated from the title with collision handling; `to_param` returns the slug, so product URLs are `/products/:slug`. Category is constrained to `Product::CATEGORIES`. Prices are stored as integer cents (`base_price_cents`); `#base_price` converts to dollars.
- **`Variant`** (`app/models/variant.rb`) — `belongs_to :product`. `price_cents` is an optional per-variant override; `#effective_price_cents` falls back to the product's base price. This fallback is the single source of truth for pricing — read it before touching cart totals.
- **`Cart`** (`app/models/cart.rb`) — **not an ActiveRecord model.** It wraps the `{ "variant_id" => quantity }` hash stored in the session, so there's no persistence/checkout yet. Quantities clamp to 1–99. `#line_items` loads the referenced variants in one query. When the payments stage arrives, this is the thing to swap for a DB-backed `Order`.

Routes are just `products#index/show`, a singular `cart#show`, and `cart_items#create/update/destroy` (the cart-mutation endpoints). Cart updates flow through Turbo Streams.

## Not yet wired (scaffolded for later)

- **Devise** — the gem and `config/initializers/devise.rb` exist, but there is **no `User` model and no auth routes** yet. Auth is not active.
- **Stripe** — the gem is in the Gemfile but there are **no code references**. Checkout is unimplemented (the session `Cart` is as far as the flow goes).

Don't assume auth/payments work; they're placeholders for the next stage.

## PRoot / Postgres gotchas

This runs in a Termux/PRoot container. Two things bite repeatedly:

- **The web server must bind `127.0.0.1`** — interface enumeration (`getifaddrs`) fails with `EACCES`, so `Procfile.dev` and any manual `rails server` use `-b 127.0.0.1`. The JS/CSS watchers use `--watch=forever` / `--watch=always` polling for the same reason. Preserve these when editing `Procfile.dev`.
- **Postgres is a hand-started local cluster**, not a managed service: PG17 on `127.0.0.1:5432`, trust auth, `postgres` role, data in `~/pgdata`. If the cluster is down, tests and boot fail with what *looks* like a crash but is really a connection error — start Postgres first. (See the root `CLAUDE.md` and the `brainrot-shop-postgres` / `brainrot-shop-bindev` auto-memories for exact commands.)
