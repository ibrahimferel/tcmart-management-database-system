DROP TABLE IF EXISTS detail_transaksi CASCADE;
DROP TABLE IF EXISTS transaksi        CASCADE;
DROP TABLE IF EXISTS produk           CASCADE;
DROP TABLE IF EXISTS stok             CASCADE;
DROP TABLE IF EXISTS kategori_produk  CASCADE;
DROP TABLE IF EXISTS karyawan         CASCADE;

CREATE TABLE kategori_produk (
    kp_id    SERIAL       PRIMARY KEY,
    kp_nama  VARCHAR(50)  NOT NULL
);

COMMENT ON TABLE  kategori_produk         IS 'Menyimpan kategori produk TCMart';
COMMENT ON COLUMN kategori_produk.kp_id   IS 'Primary Key kategori';
COMMENT ON COLUMN kategori_produk.kp_nama IS 'Nama kategori';

CREATE TABLE stok (
    s_id         SERIAL    PRIMARY KEY,
    s_jumlah     INT       NOT NULL DEFAULT 0 CHECK (s_jumlah >= 0),
    s_minimum    INT       NOT NULL DEFAULT 0 CHECK (s_minimum >= 0),
    s_tgl_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE  stok              IS 'Menyimpan jumlah stok dan batas minimum tiap produk';
COMMENT ON COLUMN stok.s_id         IS 'Primary Key stok';
COMMENT ON COLUMN stok.s_jumlah     IS 'Jumlah stok saat ini';
COMMENT ON COLUMN stok.s_minimum    IS 'Batas minimum stok';
COMMENT ON COLUMN stok.s_tgl_update IS 'Waktu terakhir stok diperbarui';

CREATE TABLE produk (
    p_id                  SERIAL        PRIMARY KEY,
    p_nama                VARCHAR(100)  NOT NULL,
    p_barcode             VARCHAR(50)   NOT NULL UNIQUE,
    p_harga_jual          DECIMAL(10,2) NOT NULL CHECK (p_harga_jual >= 0),
    p_harga_beli          DECIMAL(10,2) NOT NULL CHECK (p_harga_beli >= 0),
    p_satuan              VARCHAR(20)   NOT NULL CHECK (p_satuan IN ('pcs','kg','liter')),
    kategori_produk_kp_id INT           NOT NULL REFERENCES kategori_produk(kp_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    stok_s_id             INT           NOT NULL UNIQUE REFERENCES stok(s_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

COMMENT ON TABLE  produk                        IS 'Data produk yang dijual di TCMart';
COMMENT ON COLUMN produk.p_id                   IS 'Primary Key produk';
COMMENT ON COLUMN produk.p_barcode              IS 'Kode barcode unik produk';
COMMENT ON COLUMN produk.p_harga_jual           IS 'Harga jual ke konsumen (harga terkini)';
COMMENT ON COLUMN produk.p_harga_beli           IS 'Harga beli dari supplier (harga terkini)';
COMMENT ON COLUMN produk.p_satuan               IS 'Satuan penjualan';
COMMENT ON COLUMN produk.kategori_produk_kp_id  IS 'FK ke kategori_produk';
COMMENT ON COLUMN produk.stok_s_id              IS 'FK ke stok relasi 1:1';

CREATE TABLE karyawan (
    k_id     SERIAL      PRIMARY KEY,
    k_nama   VARCHAR(100) NOT NULL,
    k_no_hp  VARCHAR(15),
    k_status VARCHAR(10)  NOT NULL DEFAULT 'aktif' CHECK (k_status IN ('aktif','resign'))
);

COMMENT ON TABLE  karyawan         IS 'Data kasir TCMart';
COMMENT ON COLUMN karyawan.k_id    IS 'Primary Key karyawan';
COMMENT ON COLUMN karyawan.k_status IS 'Status aktif/resign';

CREATE TABLE transaksi (
    t_id           SERIAL        PRIMARY KEY,
    t_tgl          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    t_total_harga  DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (t_total_harga >= 0),
    t_total_bayar  DECIMAL(10,2) NOT NULL             CHECK (t_total_bayar >= 0),
    t_kembalian    DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (t_kembalian >= 0),
    t_metode_bayar VARCHAR(10)   NOT NULL CHECK (t_metode_bayar IN ('tunai','debit','QRIS')),
    karyawan_k_id  INT           NOT NULL REFERENCES karyawan(k_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

COMMENT ON TABLE  transaksi                IS 'Data transaksi penjualan';
COMMENT ON COLUMN transaksi.t_total_harga  IS 'Total harga';
COMMENT ON COLUMN transaksi.t_total_bayar  IS 'Jumlah uang yang dibayarkan pelanggan';
COMMENT ON COLUMN transaksi.t_kembalian    IS 'Kembalian';
COMMENT ON COLUMN transaksi.t_metode_bayar IS 'Metode bayar';
COMMENT ON COLUMN transaksi.karyawan_k_id  IS 'FK ke karyawan (kasir yang melayani)';

CREATE TABLE detail_transaksi (
    dt_id           SERIAL        PRIMARY KEY,
    dt_jumlah       INT           NOT NULL CHECK (dt_jumlah > 0),
    dt_harga_satuan DECIMAL(10,2) NOT NULL CHECK (dt_harga_satuan >= 0),
    dt_subtotal     DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (dt_subtotal >= 0),
    transaksi_t_id  INT           NOT NULL REFERENCES transaksi(t_id) ON UPDATE CASCADE ON DELETE CASCADE,
    produk_p_id     INT           NOT NULL REFERENCES produk(p_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

COMMENT ON TABLE  detail_transaksi                IS 'Rincian item per transaksi';
COMMENT ON COLUMN detail_transaksi.dt_harga_satuan IS 'Harga pada saat transaksi terjadi';
COMMENT ON COLUMN detail_transaksi.dt_subtotal     IS 'dt_jumlah x dt_harga_satuan';

