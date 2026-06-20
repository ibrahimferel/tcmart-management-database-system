TRUNCATE detail_transaksi, transaksi, produk, stok, karyawan, kategori_produk RESTART IDENTITY CASCADE;

-- Kategori produk (5)
INSERT INTO kategori_produk (kp_nama) VALUES
('Sembako'), ('Minuman'), ('Snack'), ('Produk Segar'), ('Perlengkapan Rumah Tangga');

-- Karyawan (10)
INSERT INTO karyawan (k_nama, k_no_hp, k_status)
SELECT
    'Karyawan ' || i,
    '08' || LPAD((random() * 9999999999)::bigint::text, 10, '0'),
    CASE WHEN random() < 0.85 THEN 'aktif' ELSE 'resign' END
FROM generate_series(1, 10) AS i;

-- Stok (200)
INSERT INTO stok (s_jumlah, s_minimum, s_tgl_update)
SELECT
    (random() * 500 + 10)::int,
    (random() * 20 + 5)::int,
    NOW() - (random() * 30 || ' days')::interval
FROM generate_series(1, 200);

-- Produk (200)
INSERT INTO produk (p_nama, p_barcode, p_harga_jual, p_harga_beli, p_satuan, kategori_produk_kp_id, stok_s_id)
SELECT
    'Produk ' || i,
    'BRC' || LPAD(i::text, 7, '0'),
    ROUND((random() * 95000 + 5000)::numeric, 2),
    ROUND((random() * 70000 + 3000)::numeric, 2),
    (ARRAY['pcs', 'kg', 'liter'])[floor(random() * 3 + 1)::int],
    floor(random() * 5 + 1)::int,
    i
FROM generate_series(1, 200) AS i;

-- Transaksi (20.000)
INSERT INTO transaksi (t_tgl, t_total_harga, t_total_bayar, t_kembalian, t_metode_bayar, karyawan_k_id)
SELECT
    NOW() - (random() * 365 || ' days')::interval,
    0, 0, 0,
    (ARRAY['tunai', 'debit', 'QRIS'])[floor(random() * 3 + 1)::int],
    (SELECT k_id FROM karyawan WHERE k_status = 'aktif' ORDER BY random() LIMIT 1)
FROM generate_series(1, 20000);

-- Detail transaksi (30.000)
INSERT INTO detail_transaksi (dt_jumlah, dt_harga_satuan, dt_subtotal, transaksi_t_id, produk_p_id)
SELECT
    qty,
    p.p_harga_jual,
    (qty * p.p_harga_jual),
    floor(random() * 20000 + 1)::int,
    p.p_id
FROM (
    SELECT i, (random() * 9 + 1)::int AS qty,
           floor(random() * 200 + 1)::int AS pid
    FROM generate_series(1, 30000) AS i
) sub
JOIN produk p ON p.p_id = sub.pid;

-- Update total_harga transaksi
UPDATE transaksi t
SET t_total_harga = sub.total
FROM (
    SELECT transaksi_t_id, SUM(dt_subtotal) AS total
    FROM detail_transaksi
    GROUP BY transaksi_t_id
) sub
WHERE t.t_id = sub.transaksi_t_id;

-- Update total_bayar dan kembalian
UPDATE transaksi
SET t_total_bayar = CASE
        WHEN t_metode_bayar = 'tunai' THEN CEIL(t_total_harga / 10000) * 10000
        ELSE t_total_harga
    END,
    t_kembalian = CASE
        WHEN t_metode_bayar = 'tunai' THEN CEIL(t_total_harga / 10000) * 10000 - t_total_harga
        ELSE 0
    END;