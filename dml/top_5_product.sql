SELECT
    p.p_nama                  AS produk,
    kp.kp_nama                AS kategori,
    SUM(dt.dt_jumlah)         AS total_qty,
    SUM(dt.dt_subtotal)       AS total_pendapatan
FROM   detail_transaksi dt
JOIN   produk          p  ON p.p_id   = dt.produk_p_id
JOIN   kategori_produk kp ON kp.kp_id = p.kategori_produk_kp_id
GROUP  BY p.p_nama, kp.kp_nama
ORDER  BY total_qty DESC
LIMIT  5;