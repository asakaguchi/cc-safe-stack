# ZShell Configuration for Safe Stack Development
# This configuration is automatically applied to avoid the initial setup wizard

# ============================================================================
# History Settings
# ============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS        # 重複するコマンドは履歴に保存しない
setopt HIST_IGNORE_ALL_DUPS    # 履歴内の重複を削除
setopt HIST_FIND_NO_DUPS       # 履歴検索時に重複を表示しない
setopt HIST_REDUCE_BLANKS      # 余分な空白を削除
setopt SHARE_HISTORY           # 履歴を複数のシェル間で共有

# ============================================================================
# Completion Settings
# ============================================================================
autoload -Uz compinit
compinit

# 補完候補のカラー表示
zstyle ':completion:*' list-colors ''
# 大文字小文字を区別しない補完
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補をメニュー選択可能にする
zstyle ':completion:*' menu select

# ============================================================================
# Key Bindings
# ============================================================================
# Emacsキーバインド（Ctrl+A, Ctrl+E など）
bindkey -e

# 履歴検索
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# ============================================================================
# Paste Settings
# ============================================================================
# bracketed-pasteを無効化（Windowsクリップボードからの貼り付け時の余計なコードを防ぐ）
unset zle_bracketed_paste

# ============================================================================
# Prompt Configuration
# ============================================================================
# シンプルで見やすいプロンプト
# ユーザー名@ホスト名 カレントディレクトリ $
autoload -Uz colors && colors

# Git branch表示関数
git_branch() {
    git branch 2>/dev/null | grep '^*' | colrm 1 2
}

# プロンプト設定（カラー付き）
setopt PROMPT_SUBST
PROMPT='%{$fg[cyan]%}%n@%m%{$reset_color%} %{$fg[yellow]%}%~%{$reset_color%} $(git_branch)
$ '

# ============================================================================
# Aliases
# ============================================================================
# 基本コマンドのエイリアス
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'
alias l='ls -CF'
alias grep='grep --color=auto'

# Git エイリアス
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# 開発コマンド
alias dev='pnpm run dev'
alias build='pnpm run build'
alias test='pnpm run test'
alias lint='pnpm run lint'

# ディレクトリ移動
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ============================================================================
# Environment Variables
# ============================================================================
# エディタ設定
export EDITOR=vim
export VISUAL=vim

# カラー出力の有効化
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# ============================================================================
# Additional Settings
# ============================================================================
# ディレクトリスタックの設定
setopt AUTO_PUSHD           # cd時に自動でディレクトリスタックに追加
setopt PUSHD_IGNORE_DUPS    # 重複したディレクトリは追加しない

# その他の便利な設定
setopt AUTO_CD              # ディレクトリ名だけでcd
setopt CORRECT              # コマンドのスペルミスを訂正
setopt NO_BEEP              # ビープ音を無効化

# ============================================================================
# Welcome Message
# ============================================================================
echo ""
echo "🚀 Safe Stack Development Environment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 Working Directory: $(pwd)"
echo "🐍 Python: $(python3 --version 2>/dev/null || echo 'Not available')"
echo "📦 Node.js: $(node --version 2>/dev/null || echo 'Not available')"
echo "🔧 pnpm: $(pnpm --version 2>/dev/null || echo 'Not available')"
echo ""
echo "💡 Quick Commands:"
echo "   dev    - Start all development servers"
echo "   build  - Build the project"
echo "   test   - Run tests"
echo "   lint   - Run linters"
echo "   claude - Start Claude Code CLI"
echo ""