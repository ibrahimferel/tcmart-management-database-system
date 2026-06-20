SELECT
    ROUND(AVG(t_total_harga), 2) AS rata_rata_nilai_transaksi,
    SUM(t_total_harga)           AS total_pendapatan_keseluruhan,
    COUNT(*)                     AS total_transaksi
FROM   transaksi;