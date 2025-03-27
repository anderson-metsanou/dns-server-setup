$TTL 604800
@   IN  SOA  omega.anderson237.com. admin.anderson237.com. (
        2025032701  ; Serial
        604800      ; Refresh
        86400       ; Retry
        2419200     ; Expire
        604800 )    ; Negative Cache TTL

; Name Server
@   IN  NS  omega.anderson237.com.

; A Records
omega IN  A   192.168.122.166
www IN  A   192.168.122.166
mail IN  A   192.168.122.166

; MX Record (Mail Server)
@   IN  MX  10 mail.anderson237.com.
