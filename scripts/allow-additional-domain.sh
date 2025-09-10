#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Allow additional domain script
# Dynamically adds domains to the firewall whitelist without container rebuild
# Usage: ./scripts/allow-additional-domain.sh domain1.com [domain2.com ...]

if [ $# -eq 0 ]; then
    echo "使用法: $0 domain1.com [domain2.com ...]"
    echo ""
    echo "例:"
    echo "  $0 fc.yahoo.com query1.finance.yahoo.com"
    echo "  $0 api.example.com"
    exit 1
fi

# Check if running in secure mode
if [ "${SECURE_MODE:-}" != "true" ]; then
    echo "ℹ️  セキュアモードが無効のため、ドメイン許可は不要です"
    exit 0
fi

# Check if ipset is available
if ! command -v ipset >/dev/null 2>&1; then
    echo "❌ エラー: ipset が見つかりません（セキュアモード環境が必要）"
    exit 1
fi

# Check if allowed-domains ipset exists
if ! sudo ipset list allowed-domains >/dev/null 2>&1; then
    echo "❌ エラー: allowed-domains ipset が見つかりません"
    echo "ヒント: DevContainer の再ビルドが必要かもしれません"
    exit 1
fi

echo "🌐 追加ドメインを許可リストに追加中..."

SUCCESS_COUNT=0
FAIL_COUNT=0

for domain in "$@"; do
    echo ""
    echo "📡 ドメイン処理中: $domain"
    
    # Strip scheme and path from domain if present
    clean_domain=${domain#http://}
    clean_domain=${clean_domain#https://}
    clean_domain=${clean_domain%%/*}
    
    # Validate domain format
    if [[ ! "$clean_domain" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        echo "  ❌ 無効なドメイン形式: $clean_domain"
        ((FAIL_COUNT++))
        continue
    fi
    
    # Resolve domain to IP addresses
    echo "  🔍 DNS解決中..."
    ips=$(dig +noall +answer A "$clean_domain" | awk '$4 == "A" {print $5}' | sort -u)
    
    if [ -z "$ips" ]; then
        echo "  ⚠️  DNS解決失敗: $clean_domain"
        ((FAIL_COUNT++))
        continue
    fi
    
    # Add each IP to the allowed-domains ipset
    ip_count=0
    while read -r ip; do
        if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            if sudo ipset add allowed-domains "$ip" 2>/dev/null; then
                echo "  ✅ 追加成功: $ip ($clean_domain)"
                ((ip_count++))
            else
                echo "  ℹ️  既に存在: $ip ($clean_domain)"
                ((ip_count++))
            fi
        else
            echo "  ⚠️  無効なIP: $ip"
        fi
    done < <(echo "$ips")
    
    if [ $ip_count -gt 0 ]; then
        ((SUCCESS_COUNT++))
        echo "  ✅ $clean_domain: $ip_count個のIPアドレスを処理"
    else
        ((FAIL_COUNT++))
        echo "  ❌ $clean_domain: 有効なIPが見つかりませんでした"
    fi
done

echo ""
echo "📊 処理結果:"
echo "  成功: ${SUCCESS_COUNT}個のドメイン"
echo "  失敗: ${FAIL_COUNT}個のドメイン"

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo ""
    echo "✅ 許可リストの更新完了"
    echo "🔄 変更はすぐに有効になります（再起動不要）"
    
    # Test connectivity to the first successful domain
    first_domain=$(echo "$@" | cut -d' ' -f1)
    echo ""
    echo "🧪 接続テスト中..."
    if timeout 5 curl -Is "https://$first_domain" >/dev/null 2>&1; then
        echo "✅ $first_domain への接続成功"
    else
        echo "⚠️  $first_domain への接続失敗（他の原因の可能性）"
    fi
else
    echo ""
    echo "❌ すべてのドメイン追加に失敗しました"
    exit 1
fi