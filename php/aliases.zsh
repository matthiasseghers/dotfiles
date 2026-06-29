# Composer
alias c='composer'
alias cu='composer update'
alias ci='composer install'
alias cda='composer dump-autoload'

# Laravel Artisan
alias art='php artisan'
alias mfs='php artisan migrate:fresh --seed'
alias tinker='php artisan tinker'

# Check for leftover dd()/dump() calls before committing
php-dumpcheck() {
  local patterns=(-e '\{\{[ \t]*dump' -e '\{%[ \t]*dump' -e '\b(dd|var_dump|print_r)\(')
  local globs=(--glob '*.php' --glob '*.twig')

  echo "--- Staged changes ---"
  git diff --cached -- '*.php' '*.twig' \
    | rg "${patterns[@]}" -e '^\+' \
    || echo "✓ No dumps in staged changes."

  echo "--- Full codebase ---"
  rg "${patterns[@]}" "${globs[@]}" . \
    || echo "✓ No dumps found in codebase."
}