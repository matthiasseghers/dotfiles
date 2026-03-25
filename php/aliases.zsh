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
  if git diff --cached | rg -q '^\+.*\b(dd|dump|var_dump|print_r)\('; then
    echo "⚠️  Debug dump found in staged changes."
    return 1
  else
    echo "✓ No debug dumps found."
  fi
}
