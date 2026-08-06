#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ALLOWED_AUTHOR_REGEX="${ALLOWED_AUTHOR_REGEX:-coder5617|noreply\.github\.com}"
TARGET_DIR="${1:-.}"

cd "$TARGET_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}Error: '$TARGET_DIR' is not a git repository.${NC}"
    exit 1
fi

WARNINGS=0
ERRORS=0

log_header() {
    echo -e "\n${BLUE}=====================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}=====================================================${NC}"
}

log_pass() { echo -e "  [${GREEN}PASS${NC}] $1"; }
log_warn() { echo -e "  [${YELLOW}WARN${NC}] $1"; ((WARNINGS++)) || true; }
log_fail() { echo -e "  [${RED}FAIL${NC}] $1"; ((ERRORS++)) || true; }

log_header "Repository Public Release Pre-flight Audit"
echo "Auditing repo at: $(pwd)"
echo "Allowed Author/Email pattern: '$ALLOWED_AUTHOR_REGEX'"

# 1. Git Authors & Committers Audit
log_header "1. Git Authors & Committers"
AUTHORS=$(git log --all --format="%an <%ae>" | sort -u)
UNKNOWN_AUTHORS=$(echo "$AUTHORS" | grep -vE "$ALLOWED_AUTHOR_REGEX" || true)
if [ -z "$UNKNOWN_AUTHORS" ]; then
    log_pass "All git authors/committers match approved identities."
else
    log_fail "Found unapproved author/email signatures in git history:"
    echo "$UNKNOWN_AUTHORS" | while read -r line; do echo -e "      - $line"; done
fi

# 2. Username & Local Path Leaks
log_header "2. Username & Local Path Leaks"
CURRENT_USER=$(whoami)
USER_PATH_MATCHES=$(git grep -i "$CURRENT_USER" 2>/dev/null || true)
if [ -z "$USER_PATH_MATCHES" ]; then
    log_pass "No instances of current local OS username '$CURRENT_USER' found in tracked files."
else
    log_fail "Local username '$CURRENT_USER' found in tracked files:"
    echo "$USER_PATH_MATCHES" | head -n 10 | while read -r line; do echo -e "      - $line"; done
fi

USERS_DIR_MATCHES=$(git grep -i "/Users/" 2>/dev/null || true)
if [ -z "$USERS_DIR_MATCHES" ]; then
    log_pass "No hardcoded '/Users/' absolute paths found."
else
    log_warn "Hardcoded '/Users/' path reference found in tracked files:"
    echo "$USERS_DIR_MATCHES" | head -n 10 | while read -r line; do echo -e "      - $line"; done
fi

# 3. Tracked Sensitive & Build Files
log_header "3. Tracked Sensitive & Build Files"
TRACKED_FILES=$(git ls-files)
DANGEROUS_FILES=$(echo "$TRACKED_FILES" | grep -iE '(\.env|\.pem|\.key|\.p12|\.keystore|id_rsa|id_ed25519|\.DS_Store|node_modules|\.build|\.ai/)' || true)
if [ -z "$DANGEROUS_FILES" ]; then
    log_pass "No dangerous configuration, private keys, or build artifacts tracked in git."
else
    log_fail "Sensitive or build files are currently tracked in git:"
    echo "$DANGEROUS_FILES" | while read -r line; do echo -e "      - $line"; done
fi

# 4. Secrets & Credentials Scan
log_header "4. Credentials & Secret Key Patterns"
PATTERNS=(
    'AKIA[0-9A-Z]{16}'
    'ghp_[a-zA-Z0-9]{36}'
    'gho_[a-zA-Z0-9]{36}'
    'github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}'
    'xox[baprs]-[0-9a-zA-Z]{10,48}'
    'sk-[a-zA-Z0-9]{32,}'
    'sk-ant-[a-zA-Z0-9]{32,}'
    '-----BEGIN (RSA|OPENSSH|EC|PGP|PRIVATE) KEY-----'
)
FOUND_SECRETS=0
for pattern in "${PATTERNS[@]}"; do
    MATCHES=$(git grep -E "$pattern" 2>/dev/null || true)
    if [ -n "$MATCHES" ]; then
        log_fail "Potential secret matched pattern '$pattern':"
        echo "$MATCHES" | head -n 5 | while read -r line; do echo -e "      - $line"; done
        FOUND_SECRETS=1
    fi
done
if [ "$FOUND_SECRETS" -eq 0 ]; then
    log_pass "No high-risk API key patterns or private keys detected."
fi

# 5. Email Addresses in Tracked Code
log_header "5. Email Addresses in Tracked Code"
EMAILS_IN_CODE=$(git grep -E -o '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' 2>/dev/null | grep -vE "$ALLOWED_AUTHOR_REGEX|example\.com|apple\.com|schema\.org" || true)
if [ -z "$EMAILS_IN_CODE" ]; then
    log_pass "No unexpected email addresses found in source code."
else
    log_warn "Email addresses found in source code:"
    echo "$EMAILS_IN_CODE" | head -n 10 | while read -r line; do echo -e "      - $line"; done
fi

# 6. Git Remote URL Audit
log_header "6. Git Remote Configuration"
REMOTES=$(git remote -v || true)
CREDENTIAL_REMOTES=$(echo "$REMOTES" | grep -E 'https?://[^:]+:[^@]+@' || true)
if [ -n "$CREDENTIAL_REMOTES" ]; then
    log_fail "Git remote URL contains embedded credentials (username:password):"
    echo "$CREDENTIAL_REMOTES"
else
    log_pass "Git remote URLs are free of embedded inline credentials."
fi

# 7. Git Commit Messages & History Audit
log_header "7. Git Commit Message & History Leaks"
COMMIT_MSG_LEAKS=$(git log --all --format="%h %s" | grep -i "$CURRENT_USER" || true)
if [ -z "$COMMIT_MSG_LEAKS" ]; then
    log_pass "No local username references in commit messages."
else
    log_warn "Commit messages containing local username '$CURRENT_USER':"
    echo "$COMMIT_MSG_LEAKS" | head -n 10 | while read -r line; do echo -e "      - $line"; done
fi

# Summary
log_header "Audit Summary"
echo -e "Errors  : ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [ "$ERRORS" -gt 0 ]; then
    echo -e "\n${RED}STATUS: FAILED - Resolve errors before publishing repo.${NC}\n"
    exit 1
else
    echo -e "\n${GREEN}STATUS: PASSED - Repository is clean for public release!${NC}\n"
    exit 0
fi
