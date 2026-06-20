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