-- Validasi Kasir Aktif
UPDATE karyawan
SET k_status = 'resign'
WHERE k_id = 1;

SELECT *
FROM karyawan
WHERE k_id = 1;

INSERT INTO transaksi (
    t_total_bayar,
    t_metode_bayar,
    karyawan_k_id
)
VALUES (
    0,
    'tunai',
    1
);

-- Hitung Subtotal Otomatis
INSERT INTO transaksi (t_total_bayar, t_metode_bayar, karyawan_k_id)
VALUES (0, 'tunai', 2)
RETURNING t_id;

INSERT INTO detail_transaksi (
    dt_jumlah,
    dt_harga_satuan,
    dt_subtotal,
    transaksi_t_id,
    produk_p_id
)
VALUES (
    2,
    0,
    0,
    20005,
    1
);

SELECT *
FROM detail_transaksi
WHERE transaksi_t_id = 20005;

-- Update Total Harga Transaksi
SELECT
    t_id,
    t_total_harga
FROM transaksi
WHERE t_id = 20005;

-- Pengurangan Stok Otomatis
SELECT s.s_jumlah
FROM stok s
JOIN produk p ON p.stok_s_id = s.s_id
WHERE p.p_id = 1;

INSERT INTO detail_transaksi (
    dt_jumlah,
    dt_harga_satuan,
    dt_subtotal,
    transaksi_t_id,
    produk_p_id
)
VALUES (
    3,
    0,
    0,
    20005,
    1
);

-- Pencegahan Stok Negatif
UPDATE stok
SET s_jumlah = -1
WHERE s_id = 1;

-- Peringatan Stok Menipis
SELECT s_id, s_jumlah, s_minimum
FROM stok
WHERE s_id = 1;

UPDATE stok
SET s_jumlah = 19
WHERE s_id = 1;

SELECT *
FROM log_peringatan_stok
ORDER BY lps_tgl DESC
LIMIT 5;

-- Restock Produk
SELECT s.s_jumlah
FROM stok s
JOIN produk p ON p.stok_s_id = s.s_id
WHERE p.p_id = 1;

CALL sp_restock(1, 50);

-- Batalkan Transaksi
INSERT INTO transaksi (t_total_bayar, t_metode_bayar, karyawan_k_id)
VALUES (0, 'tunai', 2)
RETURNING t_id;

CALL sp_batalkan_transaksi(20008);

SELECT *
FROM transaksi
WHERE t_id = 20008;

-- Hitung Kembalian
SELECT *
FROM fn_hitung_kembalian(
    1,
    275000
);

-- Produk Terlaris
SELECT *
FROM fn_produk_terlaris(
    '2026-01-01',
    '2026-12-31',
    5
);

-- Laporan Penjualan
SELECT *
FROM fn_laporan_penjualan(
    '2026-01-01',
    '2026-12-31'
);