SELECT p.p_id, p.p_nama, s.s_jumlah AS stok_sekarang, s.s_minimum AS stok_minimum
FROM   produk p
JOIN   stok   s ON s.s_id = p.stok_s_id
WHERE  s.s_jumlah < s.s_minimum
ORDER  BY p.p_id;