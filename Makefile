# Convenience wrappers for working on the theme locally.
# All Hugo commands run against exampleSite/ which imports the parent
# theme via a `replace` directive in exampleSite/go.mod.

HUGO        ?= hugo
PORT        ?= 1313
EXAMPLE     := exampleSite
SHOTS       := docs/screenshots
CHROME      ?= google-chrome
WINDOW_SIZE ?= 1440,1200
MOBILE_SIZE ?= 390,1500

.PHONY: help dev build preview clean screenshots tidy check-tokens check-readme test

help: ## Print this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

dev: ## Run Hugo dev server against exampleSite/ at http://localhost:$(PORT)/
	cd $(EXAMPLE) && $(HUGO) server --port $(PORT) --bind 127.0.0.1 --buildDrafts --buildFuture

build: ## Build exampleSite to exampleSite/public/ (sanity check)
	cd $(EXAMPLE) && $(HUGO) --minify

preview: build ## Serve the static build (no live reload)
	cd $(EXAMPLE) && $(HUGO) server --port $(PORT) --bind 127.0.0.1 --renderToDisk

screenshots: ## Capture light + dark hero screenshots into $(SHOTS)/
	@mkdir -p $(SHOTS)
	@cd $(EXAMPLE) && nohup $(HUGO) server --port $(PORT) --bind 127.0.0.1 > /tmp/nht-hugo.log 2>&1 & echo $$! > /tmp/nht-hugo.pid
	@sleep 3
	@$(CHROME) --headless --no-sandbox --disable-gpu --hide-scrollbars \
	  --virtual-time-budget=5000 --window-size=$(WINDOW_SIZE) \
	  --screenshot=$(SHOTS)/hero-light.png \
	  'http://127.0.0.1:$(PORT)/?theme=light' 2>&1 | tail -1
	@$(CHROME) --headless --no-sandbox --disable-gpu --hide-scrollbars \
	  --virtual-time-budget=5000 --window-size=$(WINDOW_SIZE) \
	  --screenshot=$(SHOTS)/hero-dark.png \
	  'http://127.0.0.1:$(PORT)/?theme=dark' 2>&1 | tail -1
	@$(CHROME) --headless --no-sandbox --disable-gpu --hide-scrollbars \
	  --virtual-time-budget=5000 --window-size=$(WINDOW_SIZE) \
	  --screenshot=$(SHOTS)/components-light.png \
	  'http://127.0.0.1:$(PORT)/components/?theme=light' 2>&1 | tail -1
	@$(CHROME) --headless --no-sandbox --disable-gpu --hide-scrollbars \
	  --virtual-time-budget=5000 --window-size=$(WINDOW_SIZE) \
	  --screenshot=$(SHOTS)/components-dark.png \
	  'http://127.0.0.1:$(PORT)/components/?theme=dark' 2>&1 | tail -1
	@$(CHROME) --headless --no-sandbox --disable-gpu --hide-scrollbars \
	  --virtual-time-budget=5000 --window-size=$(WINDOW_SIZE) \
	  --screenshot=$(SHOTS)/docs-light.png \
	  'http://127.0.0.1:$(PORT)/architecture/?theme=light' 2>&1 | tail -1
	@$(CHROME) --headless --no-sandbox --disable-gpu --hide-scrollbars \
	  --virtual-time-budget=5000 --window-size=$(WINDOW_SIZE) \
	  --screenshot=$(SHOTS)/docs-dark.png \
	  'http://127.0.0.1:$(PORT)/architecture/?theme=dark' 2>&1 | tail -1
	@$(CHROME) --headless --no-sandbox --disable-gpu --hide-scrollbars \
	  --virtual-time-budget=5000 --window-size=$(WINDOW_SIZE) \
	  --screenshot=$(SHOTS)/404-light.png \
	  'http://127.0.0.1:$(PORT)/404.html?theme=light' 2>&1 | tail -1
	@$(CHROME) --headless --no-sandbox --disable-gpu --hide-scrollbars \
	  --virtual-time-budget=5000 --window-size=$(WINDOW_SIZE) \
	  --screenshot=$(SHOTS)/404-dark.png \
	  'http://127.0.0.1:$(PORT)/404.html?theme=dark' 2>&1 | tail -1
	@$(CHROME) --headless --no-sandbox --disable-gpu --hide-scrollbars \
	  --virtual-time-budget=5000 --window-size=$(MOBILE_SIZE) \
	  --screenshot=$(SHOTS)/mobile-light.png \
	  'http://127.0.0.1:$(PORT)/architecture/?theme=light' 2>&1 | tail -1
	@kill $$(cat /tmp/nht-hugo.pid) 2>/dev/null || true
	@rm -f /tmp/nht-hugo.pid
	@ls -la $(SHOTS)/*.png

tidy: ## Refresh exampleSite Hugo Modules (rare; needed after editing imports)
	cd $(EXAMPLE) && $(HUGO) mod tidy

check-tokens: ## Diff vendored tokens against upstream nebari-design globals.css (best-effort)
	@echo "Fetching upstream nebari-design globals.css..."
	@UPSTREAM=$$(curl -fsSL \
	  "https://raw.githubusercontent.com/nebari-dev/nebari-design/main/globals.css" \
	  2>/dev/null) || { echo "WARNING: could not fetch upstream globals.css (offline?)"; exit 0; }; \
	VENDORED=$$(awk '/:root|\.dark/{found=1} found{print} /^}$$/{if(found)found=0}' \
	  assets/css/main.css); \
	UPSTREAM_TOKENS=$$(echo "$$UPSTREAM" | awk '/:root|\.dark/{found=1} found{print} /^}$$/{if(found)found=0}'); \
	DIFF=$$(diff <(echo "$$UPSTREAM_TOKENS") <(echo "$$VENDORED") 2>/dev/null); \
	if [ -z "$$DIFF" ]; then \
	  echo "Tokens: in sync with upstream."; \
	else \
	  echo "Tokens: DRIFT DETECTED - diff (upstream vs vendored):"; \
	  echo "$$DIFF"; \
	fi

check-readme: ## Verify README paths/targets still match the repo (drift check)
	bash scripts/check-readme.sh

test: ## Run theme behaviour tests (responsive nav, table wrapping, …)
	HUGO=$(HUGO) bash scripts/test-theme.sh

clean: ## Remove build artifacts
	rm -rf $(EXAMPLE)/public $(EXAMPLE)/resources $(EXAMPLE)/.hugo_build.lock
	rm -rf public resources .hugo_build.lock assets/jsconfig.json
